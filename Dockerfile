# Use a specific working Python version
FROM python:3.10-slim

# Install system libraries (needed by some packages like OpenCV or Torch)
RUN apt-get update && apt-get install -y \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory in the container
WORKDIR /app

# Copy all files from your project to the container
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Run your app (adjust path if needed)
CMD ["python", "pneumonia_backend/app.py"]

