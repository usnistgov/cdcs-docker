""" Allauth Settings
"""

from .settings import *  # noqa


ENABLE_ALLAUTH = os.getenv("ENABLE_ALLAUTH", "False").lower() == "true"
""" boolean: enable Django-allauth
"""

ENABLE_ALLAUTH_LOCAL_MFA = (
    os.getenv("ENABLE_ALLAUTH_LOCAL_MFA", "False").lower() == "true"
)
""" boolean: enable local MFA for Django-allauth
"""

ALLAUTH_ACCOUNT_REQUESTS_FOR_NEW_USERS = (
    os.getenv("ALLAUTH_ACCOUNT_REQUESTS_FOR_NEW_USERS", "False").lower()
    == "true"
)
""" :py:class:`bool`: Signing up with Django-allauth create a CDCS account requests
"""


if ENABLE_ALLAUTH:  # noqa: F405 (core setting)
    for app in [
        "allauth",
        "allauth.account",
        "allauth.socialaccount",
    ]:
        if app not in INSTALLED_APPS:
            INSTALLED_APPS = INSTALLED_APPS + (app,)

    if "allauth.account.middleware.AccountMiddleware" not in MIDDLEWARE:
        MIDDLEWARE = MIDDLEWARE + (
            "allauth.account.middleware.AccountMiddleware",
        )

    AUTHENTICATION_BACKENDS = (
        "django.contrib.auth.backends.ModelBackend",
        "allauth.account.auth_backends.AuthenticationBackend",
    )

    SOCIALACCOUNT_PROVIDERS = dict()
    SOCIALACCOUNT_AUTO_SIGNUP = True # False to use CDCS signup form with captch and account request
    
    # Account adapter creates a user account request
    ACCOUNT_ADAPTER = (
        "core_main_app.utils.allauth.cdcs_adapter.CDCSAccountAdapter"
    )
    ACCOUNT_FORMS = {'signup': "core_main_app.utils.allauth.forms.CoreAccountSignupForm"}
    SOCIALACCOUNT_FORMS = {'signup': "core_main_app.utils.allauth.forms.CoreSocialAccountSignupForm"}
    ACCOUNT_SIGNUP_FIELDS = ['email*', 'username*', 'password1*', 'password2*']
    ACCOUNT_SESSION_REMEMBER = False
    ACCOUNT_LOGOUT_ON_GET = True
    ACCOUNT_SIGNUP_FORM_HONEYPOT_FIELD = os.getenv(
        "ACCOUNT_SIGNUP_FORM_HONEYPOT_FIELD", "organization"
    )
    LOGIN_URL = "account_login"
    LOGIN_REDIRECT_URL = "/"
    LOGOUT_REDIRECT_URL = "/"

    if ENABLE_SAML2_SSO_AUTH:  # noqa: F405 (core setting)
        from core_main_app.utils.allauth.saml import (
            load_allauth_saml_conf_from_env,
        )

        if "allauth.socialaccount.providers.saml" not in INSTALLED_APPS:
            INSTALLED_APPS = INSTALLED_APPS + (
                "allauth.socialaccount.providers.saml",
            )
        SOCIALACCOUNT_PROVIDERS["saml"] = load_allauth_saml_conf_from_env()

    if ENABLE_ALLAUTH_LOCAL_MFA:  # noqa: F405 (core setting)
        # local MFA
        for app in ["allauth.mfa", "django.contrib.humanize"]:
            if app not in INSTALLED_APPS:
                INSTALLED_APPS = INSTALLED_APPS + (app,)
        MFA_SUPPORTED_TYPES = ["webauthn"]
        # Optional: enable support for logging in using a (WebAuthn) passkey.
        MFA_PASSKEY_LOGIN_ENABLED = True
