import os
from flask import Flask, render_template, request
from pipeline import full_pipeline
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'

# Create upload folder if not exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/analyze', methods=['POST'])
def analyze():
    if 'image' not in request.files:
        return render_template('index.html', result="Error: No file part")
    
    file = request.files['image']
    if file.filename == '':
        return render_template('index.html', result="Error: No selected file")
    
    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    result = full_pipeline(filepath)
    return render_template('index.html', result=result)

if __name__ == "__main__":
    app.run(debug=True)
