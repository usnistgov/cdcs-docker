"""Automatically register audit middleware when the backend starts."""

from __future__ import annotations

import os
import logging

try:
    from customizations.audit_middleware import AuditLoggerMiddleware, FileAuditSink
    from app import main as app_main
except Exception as exc:  # pragma: no cover - guard against import issues
    logging.getLogger("audit").error("Audit middleware failed to import: %%s", exc)
else:
    secret = os.environ.get("AUDIT_SECRET")
    if not secret:
        logging.getLogger("audit").warning("AUDIT_SECRET not set; audit middleware skipped")
    else:
        log_path = os.environ.get("AUDIT_LOG_PATH", "/app/backend/data/audit/audit.log")
        sink = FileAuditSink(log_path)
        app_main.app.add_middleware(
            AuditLoggerMiddleware,
            secret_key=secret,
            sink=sink,
        )
        logging.getLogger("audit").info("Audit middleware enabled, logging to %%s", log_path)
