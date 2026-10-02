FROM python:3.11-slim

# Install PostgreSQL client libraries for psycopg support
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Ensure libpq.so.5 is linked and cached for dynamic linking
RUN find /usr/lib*/ -name "*libpq*" -exec ldconfig -v {} \; 2>/dev/null || true

WORKDIR /app

# Install psycopg2-binary and psycopg for modern Python 3.x compatibility
RUN pip install --no-cache-dir psycopg2-binary psycopg

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py ./main.py
COPY api/ ./api/
COPY app/ ./app/

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
