FROM python:3.11-slim

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN pip install --no-cache-dir fastapi uvicorn[standard] aiomqtt pydantic

COPY main.py /app/main.py
COPY .env /app/.env

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]