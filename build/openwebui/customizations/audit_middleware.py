"""Prototype audit logging middleware for OpenWebUI.

The repository's Dockerfile copies this module into `/app/customizations` and
loads it via `sitecustomize.py`. When `AUDIT_SECRET` is set, the middleware
captures full request and response bodies for `/api/chat/completions`, hashes
user identifiers, and writes JSONL audit records.

Extend `extract_user_id` to integrate with your organization's authentication
headers.
"""

from __future__ import annotations

import asyncio
import hmac
import json
import logging
from datetime import datetime, timezone
from hashlib import sha256
from pathlib import Path
from typing import Any, Dict, Optional

from starlette.types import ASGIApp, Message, Receive, Scope, Send

logger = logging.getLogger("audit")


class FileAuditSink:
    """Persist audit events as JSONL entries on disk."""

    def __init__(self, path: str | Path) -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)

    async def write(self, record: Dict[str, Any]) -> None:
        line = json.dumps(record, separators=(",", ":")) + "\n"

        def _write() -> None:
            with self.path.open("a", encoding="utf-8") as fh:
                fh.write(line)

        await asyncio.to_thread(_write)


class AuditLoggerMiddleware:
    """FastAPI/Starlette middleware that audits chat traffic."""

    def __init__(
        self,
        app: ASGIApp,
        *,
        secret_key: str,
        sink: FileAuditSink,
        target_path: str = "/api/chat/completions",
    ) -> None:
        self.app = app
        self.secret_key = secret_key.encode("utf-8")
        self.sink = sink
        self.target_path = target_path

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope.get("type") != "http" or scope.get("path") != self.target_path:
            await self.app(scope, receive, send)
            return

        request_body = bytearray()
        response_body = bytearray()
        status_code: Optional[int] = None

        async def receive_wrapper() -> Message:
            message = await receive()
            if message["type"] == "http.request":
                request_body.extend(message.get("body", b""))
            return message

        async def send_wrapper(message: Message) -> None:
            nonlocal status_code
            if message["type"] == "http.response.start":
                status_code = message.get("status")
            elif message["type"] == "http.response.body":
                response_body.extend(message.get("body", b""))
            await send(message)

        await self.app(scope, receive_wrapper, send_wrapper)

        try:
            record = self._build_record(scope, bytes(request_body), bytes(response_body), status_code)
            await self.sink.write(record)
        except Exception as exc:  # pragma: no cover - keep audit from breaking chats
            logger.exception("Failed to write audit record: %s", exc)

    def _build_record(
        self,
        scope: Scope,
        request_body: bytes,
        response_body: bytes,
        status_code: Optional[int],
    ) -> Dict[str, Any]:
        now = datetime.now(tz=timezone.utc).isoformat()
        user_id = self.extract_user_id(scope)
        anonymized_user = self.anonymize_user_id(user_id)

        return {
            "timestamp": now,
            "path": scope.get("path"),
            "method": scope.get("method"),
            "user": anonymized_user,
            "status": status_code,
            "request": self.decode_payload(request_body),
            "response": self.decode_payload(response_body),
        }

    def extract_user_id(self, scope: Scope) -> str:
        headers = {k.decode("latin-1"): v.decode("latin-1") for k, v in scope.get("headers", [])}
        return headers.get("x-user-id", "anonymous")

    def anonymize_user_id(self, user_id: str) -> str:
        digest = hmac.new(self.secret_key, msg=user_id.encode("utf-8"), digestmod=sha256).hexdigest()
        return f"user::{digest[:16]}"

    @staticmethod
    def decode_payload(payload: bytes) -> Any:
        if not payload:
            return None
        try:
            return json.loads(payload)
        except json.JSONDecodeError:
            return payload.decode("utf-8", errors="replace")
