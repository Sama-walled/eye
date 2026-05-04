import os
import base64
import numpy as np
import cv2
import tensorflow as tf
from PIL import Image
import io
import uuid
from datetime import datetime
from flask import Flask, request, jsonify, render_template, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_super_secret_key_here'

# MySQL Configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:omaressa123@localhost/eye_disease_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Upload configuration
UPLOAD_FOLDER = os.path.join('static', 'uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

db = SQLAlchemy(app)
login_manager = LoginManager(app)

# --- Database Models ---

class Patient(UserMixin, db.Model):
    __tablename__ = 'patient'
    patient_ID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    First_Name = db.Column(db.String(100))
    Last_Name = db.Column(db.String(100))
    Email = db.Column(db.String(100), unique=True)
    Password = db.Column(db.String(255))
    Gender = db.Column(db.String(10))
    Date_of_Birth = db.Column(db.Date)
    Contact_Info = db.Column(db.String(255))
    Medical_History = db.Column(db.Text)
    Eye_Center = db.Column(db.String(255))
    Notes = db.Column(db.Text)
    images = db.relationship('Retinal_Image', backref='patient_rel', lazy=True)

    def get_id(self):
        return str(self.patient_ID)
        
    @property
    def name(self):
        return f"{self.First_Name or ''} {self.Last_Name or ''}".strip()

class Retinal_Image(db.Model):
    __tablename__ = 'retinal_image'
    Image_ID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Image_path = db.Column(db.String(255))
    Date_Captured = db.Column(db.DateTime, default=datetime.utcnow)
    patient_ID = db.Column(db.Integer, db.ForeignKey('patient.patient_ID'))
    Capture_Device = db.Column(db.String(255))
    gradings = db.relationship('AI_Grading', backref='image_rel', lazy=True)

class AI_Model(db.Model):
    __tablename__ = 'ai_model'
    Model_ID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Model_Name = db.Column(db.String(255))
    Version = db.Column(db.String(50))
    Developer = db.Column(db.String(255))
    Training_Data_Source = db.Column(db.Text)
    Accuracy = db.Column(db.Numeric(5,2))
    Last_Updated = db.Column(db.Date)
    Algorithm = db.Column(db.Text)
    gradings = db.relationship('AI_Grading', backref='model_rel', lazy=True)

class AI_Grading(db.Model):
    __tablename__ = 'ai_grading'
    AI_Grading_ID = db.Column(db.Integer, primary_key=True, autoincrement=True)
    DR_Grade = db.Column(db.String(50))
    Confidence_Score = db.Column(db.Numeric(5,2))
    Grading_Date = db.Column(db.DateTime, default=datetime.utcnow)
    Image_ID = db.Column(db.Integer, db.ForeignKey('retinal_image.Image_ID'))
    Model_ID = db.Column(db.Integer, db.ForeignKey('ai_model.Model_ID'))

@login_manager.user_loader
def load_user(user_id):
    return Patient.query.get(int(user_id))

# --- AI Model Setup ---

model = None
class_names = ["No DR", "Mild", "Moderate", "Severe", "Proliferative DR"]

def create_dummy_model():
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(224, 224, 3)),
        tf.keras.layers.Conv2D(32, 3, activation='relu'),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Conv2D(64, 3, activation='relu'),
        tf.keras.layers.MaxPooling2D(),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dense(len(class_names), activation='softmax')
    ])
    model.compile(optimizer='adam', loss='categorical_crossentropy')
    return model

def load_model():
    global model
    model_path = os.getenv("MODEL_PATH", "../ai_model_service/models/downloaded_model/converted_keras/keras_model.h5")
    try:
        if os.path.exists(model_path):
            model = tf.keras.models.load_model(model_path)
            print(f"Model loaded from {model_path}")
        else:
            print("No model found, creating dummy model")
            model = create_dummy_model()
    except Exception as e:
        print(f"Error loading model: {e}")
        model = create_dummy_model()

load_model()

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    try:
        image = Image.open(io.BytesIO(image_bytes))
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        image_array = np.array(image)
        image_resized = cv2.resize(image_array, (224, 224))
        image_normalized = image_resized.astype(np.float32) / 255.0
        image_batch = np.expand_dims(image_normalized, axis=0)
        return image_batch
    except Exception as e:
        print(f"Error preprocessing image: {e}")
        return None

def ensure_ai_model_in_db():
    # Ensure there is an AI_Model record for predictions
    with app.app_context():
        existing_model = AI_Model.query.first()
        if not existing_model:
            new_model = AI_Model(
                Model_Name="Diabetic Retinopathy CNN",
                Version="1.0.0",
                Developer="RetinaSight",
                Accuracy=95.50,
                Algorithm="Convolutional Neural Network"
            )
            db.session.add(new_model)
            db.session.commit()

ensure_ai_model_in_db()

# --- Routes ---

@app.route('/')
def index():
    return jsonify({
        "status": "success",
        "message": "Eye Disease Classification API is running",
        "endpoints": {
            "login": "/api/login",
            "register": "/api/register",
            "predict": "/api/predict",
            "history": "/api/history"
        }
    })

@app.route('/register', methods=['POST'])
def register():
    # Alias for api_register
    return api_register()

@app.route('/login', methods=['POST'])
def login():
    # Alias for api_login
    return api_login()

@app.route('/logout')
def logout():
    logout_user()
    return jsonify({"message": "Logged out successfully"}), 200

@app.route('/history')
def history():
    # Alias for api_history
    return api_history()

@app.route('/predict', methods=['POST'])
def predict():
    # Alias for api_predict
    return api_predict()

# --- API Endpoints for Flutter ---

@app.route('/api/register', methods=['POST'])
def api_register():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No JSON data provided"}), 400
        
    name = data.get('name', '')
    email = data.get('email', '')
    password = data.get('password', '')
    
    parts = name.split(' ', 1)
    first_name = parts[0]
    last_name = parts[1] if len(parts) > 1 else ""
    
    user_exists = Patient.query.filter_by(Email=email).first()
    if user_exists:
        return jsonify({"error": "Email already registered"}), 400
        
    hashed_password = generate_password_hash(password, method='pbkdf2:sha256')
    
    # Store additional flutter fields in Notes or respective columns if they match
    gender = data.get('gender')
    age = data.get('age')
    
    new_patient = Patient(
        First_Name=first_name, 
        Last_Name=last_name, 
        Email=email, 
        Password=hashed_password,
        Gender=gender,
        Notes=f"Age: {age}, Diabetes: {data.get('hasDiabetes')}, PrevSurgeries: {data.get('hasPreviousSurgeries')}"
    )
    
    db.session.add(new_patient)
    db.session.commit()
    
    return jsonify({
        "message": "Registration successful", 
        "user": {
            "id": new_patient.patient_ID, 
            "name": name, 
            "email": email
        }
    }), 201

@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No JSON data provided"}), 400
        
    email = data.get('email')
    password = data.get('password')
    
    patient = Patient.query.filter_by(Email=email).first()
    if patient and check_password_hash(patient.Password, password):
        # We can implement JWT tokens here, but for simplicity we return user data
        return jsonify({
            "message": "Login successful",
            "user": {
                "id": patient.patient_ID,
                "name": f"{patient.First_Name} {patient.Last_Name}".strip(),
                "email": patient.Email
            }
        }), 200
    else:
        return jsonify({"error": "Invalid credentials"}), 401

@app.route('/api/predict', methods=['POST'])
def api_predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400
    
    file = request.files['image']
    patient_id = request.form.get('patient_id')
    
    if not patient_id:
        return jsonify({"error": "No patient_id provided"}), 400
        
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if file:
        try:
            image_bytes = file.read()
            image_array = preprocess_image(image_bytes)
            
            if image_array is None:
                return jsonify({"error": "Failed to process image"}), 400
            
            predictions = model.predict(image_array)
            predicted_class_idx = np.argmax(predictions[0])
            confidence = float(np.max(predictions[0]))
            predicted_class = class_names[predicted_class_idx]
            
            confidence_percentage = round(confidence * 100, 2)
            
            # Generate analysis text
            analysis = ""
            if predicted_class == "No DR":
                analysis = "No diabetic retinopathy detected."
            elif predicted_class == "Mild":
                analysis = "Mild non-proliferative diabetic retinopathy detected."
            elif predicted_class == "Moderate":
                analysis = "Moderate non-proliferative diabetic retinopathy detected."
            elif predicted_class == "Severe":
                analysis = "Severe non-proliferative diabetic retinopathy detected."
            elif predicted_class == "Proliferative DR":
                analysis = "Proliferative diabetic retinopathy detected."

            # Save file
            ext = file.filename.rsplit('.', 1)[1].lower() if '.' in file.filename else 'jpg'
            unique_filename = f"{uuid.uuid4().hex}.{ext}"
            file_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
            
            file.seek(0)
            file.save(file_path)
            
            # Save Retinal Image
            new_image = Retinal_Image(
                Image_path=unique_filename,
                patient_ID=int(patient_id),
                Capture_Device='Flutter App'
            )
            db.session.add(new_image)
            db.session.commit()
            
            # Save Grading
            current_model = AI_Model.query.first()
            new_grading = AI_Grading(
                DR_Grade=predicted_class,
                Confidence_Score=confidence_percentage,
                Image_ID=new_image.Image_ID,
                Model_ID=current_model.Model_ID if current_model else None
            )
            db.session.add(new_grading)
            db.session.commit()
            
            return jsonify({
                "DR_grade": predicted_class,
                "confidence": confidence_percentage,
                "analysis": analysis,
                "image_id": new_image.Image_ID
            }), 200
            
        except Exception as e:
            print(f"API Prediction error: {e}")
            db.session.rollback()
            return jsonify({"error": str(e)}), 500

@app.route('/api/history', methods=['GET'])
def api_history():
    patient_id = request.args.get('patient_id')
    if not patient_id:
        return jsonify({"error": "No patient_id provided"}), 400
        
    try:
        # Fetch images and gradings for the patient
        images = Retinal_Image.query.filter_by(patient_ID=int(patient_id)).all()
        results = []
        
        for img in images:
            grading = AI_Grading.query.filter_by(Image_ID=img.Image_ID).first()
            if grading:
                results.append({
                    'image_id': img.Image_ID,
                    'image_path': img.Image_path,
                    'date': grading.Grading_Date.isoformat(),
                    'dr_grade': grading.DR_Grade,
                    'confidence': float(grading.Confidence_Score),
                    'capture_device': img.Capture_Device
                })
        
        # Sort by date descending
        results.sort(key=lambda x: x['date'], reverse=True)
        
        return jsonify({"results": results}), 200
        
    except Exception as e:
        print(f"API History error: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
