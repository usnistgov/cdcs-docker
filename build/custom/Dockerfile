ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_VERSION
FROM $BASE_IMAGE_NAME:$BASE_IMAGE_VERSION as custom
LABEL maintainer="National Institute of Standards and Technology"

# Get args
ARG PROJECT_NAME

# Switch to root user
USER root

# Install additional linux packages
COPY packages.txt /tmp/packages.txt
RUN apt-get update \
    && xargs -a /tmp/packages.txt \
    apt-get --no-install-recommends install -y \
    && rm -rf /var/lib/apt/lists/*
RUN rm /tmp/packages.txt

# Install additional python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
RUN rm /tmp/requirements.txt

# Add custom settings to project/settings.py
COPY settings.py /tmp/settings.py
RUN cat /tmp/settings.py >> $DOCKYARD_SRVPROJ/${PROJECT_NAME}/settings.py
RUN rm /tmp/settings.py

# Switch back to cdcs user
USER cdcs