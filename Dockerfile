FROM python:3.9-slim

# Install system packages and gdown
RUN apt-get update && apt-get install -y \
    libgl1 \
    curl \
    && pip install --no-cache-dir gdown \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Download each model separately using gdown
RUN mkdir -p pneumonia_backend/models

RUN gdown --fuzzy "https://drive.google.com/file/d/1_wGR1YAjwecZEwgjBRkM_NMvERiGX7XE/view?usp=sharing" -O pneumonia_backend/models/best_pneumonia_model.pth
RUN gdown --fuzzy "https://drive.google.com/file/d/1xaoVTmA1uk9T7GQm4Ft1Ak1tr6yFElZu/view?usp=sharing" -O pneumonia_backend/models/xray-classifier.h5
RUN gdown --fuzzy "https://drive.google.com/file/d/1lOdLs6_5p4QUYemvmnIayMb0y6q4DVnj/view?usp=sharing" -O pneumonia_backend/models/stage-classifier.h5

# Install Python packages
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Expose Flask port
EXPOSE 5000

# Run the app
CMD ["python", "pneumonia_backend/app.py"]
