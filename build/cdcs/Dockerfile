ARG PYTHON_VERSION
FROM python:$PYTHON_VERSION
LABEL maintainer="National Institute of Standards and Technology"

ARG CDCS_REPO
ARG BRANCH
ARG PROJECT_NAME
ARG PIP_CONF

# Directory in container for project source files
ENV DOCKYARD_SRVPROJ="/srv/curator"

# Install necessary packages
RUN apt-get update && apt-get install -y \
    netcat vim python curl git dnsutils gettext \
    libxml2-dev libxslt-dev python-dev lib32z1-dev libssl-dev \
    postgresql-client

# Setup pip
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" \
    && python get-pip.py
RUN mkdir -p /root/.config/pip
COPY pip/$PIP_CONF/pip.conf /root/.config/pip

# Install uwsgi
RUN pip install uwsgi psycopg2

# Clone git repo
RUN git clone $CDCS_REPO $DOCKYARD_SRVPROJ
RUN cd $DOCKYARD_SRVPROJ \
    && git checkout $BRANCH

# Install requirements
WORKDIR $DOCKYARD_SRVPROJ
RUN pip install -r requirements.txt
RUN pip install -r requirements.core.txt

# Get entrypoint ready for the image
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Create folder for uwsgi socket
RUN mkdir /tmp/curator
# Create folder for static files
RUN mkdir $DOCKYARD_SRVPROJ/static.prod

# Create unprivileged user
RUN groupadd cdcs && \
    adduser cdcs --disabled-password --gecos '' --ingroup cdcs  && \
    chown -R cdcs:cdcs $DOCKYARD_SRVPROJ /tmp/curator

USER cdcs


ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["curator"]
