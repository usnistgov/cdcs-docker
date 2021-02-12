""" CI Settings
"""
from .settings import *

MONITORING_SERVER_URI = os.environ["MONITORING_SERVER_URI"] if "MONITORING_SERVER_URI" in os.environ else None
if MONITORING_SERVER_URI:
    ELASTIC_APM = {
        "SERVICE_NAME": os.environ["SERVER_NAME"] if "SERVER_NAME" in os.environ else "Curator",
        "SERVER_URL": MONITORING_SERVER_URI,
        # Use if APM Server requires a token
        # 'SECRET_TOKEN': '',
    }
    if "elasticapm.contrib.django" not in INSTALLED_APPS:
        INSTALLED_APPS = INSTALLED_APPS + ("elasticapm.contrib.django",)
    if "elasticapm.contrib.django.middleware.TracingMiddleware" not in MIDDLEWARE:
        # Make sure that it is the first middleware in the list.
        MIDDLEWARE = (
            "elasticapm.contrib.django.middleware.TracingMiddleware",
        ) + MIDDLEWARE
    if "elasticapm.errors" not in LOGGING["loggers"]:
        # https://www.elastic.co/guide/en/apm/agent/python/current/django-support.html#django-logging
        # Log errors from the Elastic APM module to the console (recommended)
        set_generic_logger(LOGGING, "elasticapm.errors", "ERROR", ["console"])
    if (
        "elasticapm.contrib.django.context_processors.rum_tracing"
        not in TEMPLATES[0]["OPTIONS"]["context_processors"]
    ):
        TEMPLATES[0]["OPTIONS"]["context_processors"].append(
            "elasticapm.contrib.django.context_processors.rum_tracing"
        )
