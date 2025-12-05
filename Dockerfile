# Set the python version as a build-time argument
ARG PYTHON_VERSION=3.12-slim-bullseye
FROM python:${PYTHON_VERSION}

# Create a virtual environment
RUN python -m venv /opt/venv
ENV PATH=/opt/venv/bin:$PATH

# Upgrade pip
RUN pip install --upgrade pip

# Python environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# OS dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libjpeg-dev \
    libcairo2 \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Working directory
RUN mkdir -p /code
WORKDIR /code

# Copy requirements and project
COPY requirements.txt /tmp/requirements.txt
COPY ./src /code

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r /tmp/requirements.txt
RUN pip install gunicorn rav --upgrade

# Environment variables
ARG DJANGO_SECRET_KEY
ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}

ARG DJANGO_DEBUG=0
ENV DJANGO_DEBUG=${DJANGO_DEBUG}

# Pull static files
COPY ./rav.yaml /tmp/rav.yaml
RUN rav download staticfiles_prod -f /tmp/rav.yaml

# Collect static files
RUN python manage.py collectstatic --noinput || true

# Project name
ARG PROJ_NAME="cfehome"

# -----------------------------------------------------
# Runtime script that runs migrations at container START
# -----------------------------------------------------
RUN printf "#!/bin/bash\n" > /code/paracord_runner.sh \
    && printf "RUN_PORT=\"\${PORT:-8000}\"\n" >> /code/paracord_runner.sh \
    && printf "echo 'Running migrations...'\n" >> /code/paracord_runner.sh \
    && printf "python manage.py migrate --noinput\n" >> /code/paracord_runner.sh \
    && printf "echo 'Starting Gunicorn...'\n" >> /code/paracord_runner.sh \
    && printf "gunicorn ${PROJ_NAME}.wsgi:application --bind \"0.0.0.0:\$RUN_PORT\"\n" >> /code/paracord_runner.sh

# Make the script executable
RUN chmod +x /code/paracord_runner.sh

# Clean up
RUN apt-get remove --purge -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Expose port
EXPOSE 8000

# Start container
CMD ["./paracord_runner.sh"]
