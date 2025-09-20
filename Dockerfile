FROM python:3.9

WORKDIR /app/backend

# Copy requirements first for caching
COPY requirements.txt /app/backend

# Install system dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config netcat \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install mysqlclient
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . /app/backend

EXPOSE 8000

# Command to wait for MySQL, run migrations, then start Gunicorn
CMD sh -c "until nc -z db 3306; do echo 'Waiting for MySQL'; sleep 2; done && python manage.py migrate --noinput && gunicorn notesapp.wsgi --bind 0.0.0.0:8000"

