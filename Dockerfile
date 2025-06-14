FROM python:3.10.13-slim  # Force Python 3.10.13

# Install system dependencies (required for torch/tensorflow)
RUN apt-get update && apt-get install -y \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN pip install --upgrade pip && pip install -r requirements.txt

CMD ["python", "pneumonia_backend/app.py"]