import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"  # Disable oneDNN for faster loading

import torch
import torchvision.models as models
import torch.nn as nn
from tensorflow.keras.models import load_model
from torchvision import transforms
from PIL import Image
import numpy as np

# ✅ Resolve paths safely
BASE_DIR = os.path.dirname(__file__)
model1_path = os.path.join(BASE_DIR, 'models', 'best_pneumonia_model.pth')
model2_path = os.path.join(BASE_DIR, 'models', 'xray-classifier.h5')
model3_path = os.path.join(BASE_DIR, 'models', 'best_model.h5')

# 🔵 Model 1: PyTorch Pneumonia Presence Detector
class PneumoniaDetector(nn.Module):
    def __init__(self):
        super(PneumoniaDetector, self).__init__()
        self.model = models.resnet18(pretrained=False)
        self.model.fc = nn.Linear(self.model.fc.in_features, 2)  # Binary classification

    def forward(self, x):
        return self.model(x)

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# 🔹 Load PyTorch model
model_pytorch = PneumoniaDetector().to(device)
state_dict = torch.load(model1_path, map_location=device)
model_pytorch.model.load_state_dict(state_dict)
model_pytorch.eval()

# 🔹 Load Keras models
model_xray_verifier = load_model(model2_path)
model_stage_classifier = load_model(model3_path)

# 🔵 Preprocessing Functions
def preprocess_for_pytorch(image_path):
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                             std=[0.229, 0.224, 0.225])
    ])
    image = Image.open(image_path).convert("RGB")
    tensor = transform(image).unsqueeze(0).to(device)
    return tensor

def preprocess_for_keras(image_path):
    image = Image.open(image_path).convert("RGB").resize((224, 224))
    image = np.array(image) / 255.0
    return np.expand_dims(image, axis=0)

# 🔵 Full Combined Pipeline
def full_pipeline(image_path):
    # 1. Check if it's a chest X-ray
    xray_input = preprocess_for_keras(image_path)
    xray_pred = model_xray_verifier.predict(xray_input, verbose=0)
    if np.argmax(xray_pred) != 1:  # class 1 = chest X-ray
        return "❌ Error: The uploaded image is not a chest X-ray."

    # 2. Check for pneumonia
    input_tensor = preprocess_for_pytorch(image_path)
    with torch.no_grad():
        output = model_pytorch(input_tensor)
        predicted = torch.argmax(output, dim=1).item()

    if predicted == 0:
        return "✅ Result: Normal - No Pneumonia Detected."

    # 3. Predict pneumonia stage
    stage_pred = model_stage_classifier.predict(xray_input, verbose=0)
    stage_index = np.argmax(stage_pred)
    stages = ['Congestion', 'Red Hepatization', 'Grey Hepatization', 'Resolution']
    return f"🩺 Result: Pneumonia Detected. Stage: {stages[stage_index]}"

# ✅ Confirm loading
print("✅ All 3 models loaded successfully.")

# 🧪 Testing (Optional)
if __name__ == "__main__":
    print(full_pipeline(os.path.join(BASE_DIR, 'normal_xray.jpeg')))
    print(full_pipeline(os.path.join(BASE_DIR, 'red_hepatization.jpeg')))
    print(full_pipeline(os.path.join(BASE_DIR, 'non_xray.jpg')))
