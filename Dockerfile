FROM python:3.9-slim

# Install system dependencies and gdown
RUN apt-get update && apt-get install -y \
    libgl1 \
    curl \
    && pip install --no-cache-dir gdown \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Download models from Google Drive using gdown
RUN mkdir -p pneumonia_backend/models \
 && gdown --id 1_wGR1YAjwecZEwgjBRkM_NMvERiGX7XE -O pneumonia_backend/models/best_pneumonia_model.pth \
 && gdown --id 1xaoVTmA1uk9T7GQm4Ft1Ak1tr6yFElZu -O pneumonia_backend/models/xray-classifier.h5 \
 && gdown --id 1lOdLs6_5p4QUYemvmnIayMb0y6q4DVnj -O pneumonia_backend/models/stage-classifier.h5

# Install Python packages
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Expose default Flask port
EXPOSE 5000

# Run your app
CMD ["python", "pneumonia_backend/app.py"]
