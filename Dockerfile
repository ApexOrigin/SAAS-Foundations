FROM python:3.12-slim-bullseye

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

ENV DATABASE_URL="postgresql://neondb_owner:npg_8ld4ncGrsxoP@ep-floral-silence-aflaaoed-pooler.c-2.us-west-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
# Install required system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
    libjpeg-dev libcairo2 libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install python deps
COPY src/requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY src/ /app/

# Collect static (safe for SQLite)
RUN python manage.py collectstatic --noinput || true

EXPOSE 8000

# 🚀 MOST IMPORTANT FIX:
# Run migrations *at runtime*, not at build.
CMD ["sh", "-c", "python manage.py migrate --noinput && gunicorn cfehome.wsgi:application --bind 0.0.0.0:8000"]
