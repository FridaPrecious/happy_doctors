FROM python:3.9-slim

# Install system packages (required for OpenCV and others)
RUN apt-get update && apt-get install -y \
    libgl1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Download models from Google Drive
RUN mkdir -p pneumonia_backend/models \
 && curl -L "https://drive.google.com/uc?export=download&id=1_wGR1YAjwecZEwgjBRkM_NMvERiGX7XE" -o pneumonia_backend/models/best_pneumonia_model.pth \
 && curl -L "https://drive.google.com/uc?export=download&id=1xaoVTmA1uk9T7GQm4Ft1Ak1tr6yFElZu" -o pneumonia_backend/models/second_model.h5 \
 && curl -L "https://drive.google.com/uc?export=download&id=1lOdLs6_5p4QUYemvmnIayMb0y6q4DVnj" -o pneumonia_backend/models/third_model.h5

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Run your app
CMD ["python", "pneumonia_backend/app.py"]
