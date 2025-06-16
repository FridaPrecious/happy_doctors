FROM python:3.9-slim

# Install system packages and gdown
RUN apt-get update && apt-get install -y \
    libgl1 \
    && pip install gdown \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Download models from Google Drive using gdown
RUN mkdir -p pneumonia_backend/models \
 && gdown --id 1_wGR1YAjwecZEwgjBRkM_NMvERiGX7XE -O pneumonia_backend/models/best_pneumonia_model.pth \
 && gdown --id 1xaoVTmA1uk9T7GQm4Ft1Ak1tr6yFElZu -O pneumonia_backend/models/second_model.h5 \
 && gdown --id 1lOdLs6_5p4QUYemvmnIayMb0y6q4DVnj -O pneumonia_backend/models/third_model.h5

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Run the app
CMD ["python", "pneumonia_backend/app.py"]
