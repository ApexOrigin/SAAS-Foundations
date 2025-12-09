FROM python:3.12-slim-bullseye

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/opt/venv/bin:$PATH

# Create virtual environment
RUN python -m venv /opt/venv

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libpq-dev \
    libjpeg-dev \
    libcairo2 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
RUN mkdir -p /code
WORKDIR /code

# Install Python dependencies
COPY src/requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt

# Copy application code
COPY src/ /code/

# Collect static files (safe to ignore if not configured)
RUN python manage.py collectstatic --noinput || true

EXPOSE 8000

# Run migrations then start Gunicorn
CMD ["sh", "-c", "python manage.py migrate --noinput 2>&1 || true && gunicorn cfehome.wsgi:application --bind 0.0.0.0:8000 --workers 3 --timeout 60"]