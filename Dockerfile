# Use slim Python 3.9 image
FROM python:3.9-slim

# Install system libraries needed by some ML packages
RUN apt-get update && apt-get install -y \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files into container
COPY . .

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Run the Flask app
CMD ["python", "pneumonia_backend/app.py"]
