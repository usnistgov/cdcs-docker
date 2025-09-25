""" Test Settings
"""
from .settings import *  # import default settings from image

# TODO: Add or override settings below
ENABLE_JSON_SCHEMA_SUPPORT = True
BACKWARD_COMPATIBILITY_DATA_XML_CONTENT = False
ALLOW_MULTIPLE_SCHEMAS = True # only required for registries

# Enable development niceties for local iteration
DEBUG = True
TEMPLATES[0]["OPTIONS"]["debug"] = True
