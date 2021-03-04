""" Test Settings
"""
import os

from mongoengine.connection import connect, disconnect

from .settings import *  # import default settings from image

# Add new settings or override ones already defined below

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]
# SECURITY WARNING: only list host/domain names that this Django site can serve
ALLOWED_HOSTS = os.environ["ALLOWED_HOSTS"].split(",") if "ALLOWED_HOSTS" in os.environ else []
# SERVER URI
SERVER_URI = os.environ["SERVER_URI"]

# Override all databases settings from settings.py
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql_psycopg2",
        "HOST": os.environ["POSTGRES_HOST"] if "POSTGRES_HOST" in os.environ else None,
        "PORT": int(os.environ["POSTGRES_PORT"]) if "POSTGRES_PORT" in os.environ else 5432,
        "NAME": os.environ["POSTGRES_DB"] if "POSTGRES_DB" in os.environ else None,
        "USER": os.environ["POSTGRES_USER"] if "POSTGRES_USER" in os.environ else None,
        "PASSWORD": os.environ["POSTGRES_PASS"] if "POSTGRES_PASS" in os.environ else None,
    }
}

disconnect() # disconnect any existing connection
MONGO_HOST = os.environ["MONGO_HOST"] if "MONGO_HOST" in os.environ else ""
MONGO_PORT = os.environ["MONGO_PORT"] if "MONGO_PORT" in os.environ else "27017"
MONGO_DB = os.environ["MONGO_DB"] if "MONGO_DB" in os.environ else ""
MONGO_USER = os.environ["MONGO_USER"] if "MONGO_USER" in os.environ else ""
MONGO_PASS = os.environ["MONGO_PASS"] if "MONGO_PASS" in os.environ else ""
MONGODB_URI = (
    f"mongodb://{MONGO_USER}:{MONGO_PASS}@{MONGO_HOST}:{MONGO_PORT}/{MONGO_DB}"
)
connect(MONGO_DB, host=MONGODB_URI)


BROKER_TRANSPORT_OPTIONS = {
    "visibility_timeout": 3600,
    "fanout_prefix": True,
    "fanout_patterns": True,
}
REDIS_HOST = os.environ["REDIS_HOST"] if "REDIS_HOST" in os.environ else ""
REDIS_PORT = os.environ["REDIS_PORT"] if "REDIS_PORT" in os.environ else "6379"
REDIS_PASS = os.environ["REDIS_PASS"] if "REDIS_PASS" in os.environ else None
REDIS_URL = f"redis://:{REDIS_PASS}@{REDIS_HOST}:{REDIS_PORT}"

BROKER_URL = REDIS_URL
CELERY_RESULT_BACKEND = REDIS_URL
DEFENDER_REDIS_URL = REDIS_URL