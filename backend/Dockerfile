FROM python:3.12-slim

WORKDIR /app

RUN useradd --create-home --uid 1000 app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY lambda/ ./lambda/
COPY server.py .

USER app
EXPOSE 8080
ENV PORT=8080
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT} --workers 1 --threads 4 server:app"]
