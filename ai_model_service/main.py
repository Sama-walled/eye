from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import base64
import numpy as np
from PIL import Image
import io
import cv2
import tensorflow as tf
from typing import Dict, Any
import logging
import os
import time
import asyncio
import sys
from pathlib import Path

# Add MLOps services path
sys.path.append(str(Path(__file__).parent.parent / 'mlops_system' / 'services'))
from prediction_logger import PredictionLogger, PredictionEvent, PredictionLoggingMiddleware
from model_registry import ModelRegistryService

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Eye Disease AI Service",
    description="AI service for detecting eye diseases from retinal images",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class PredictionRequest(BaseModel):
    image_data: str  # Base64 encoded image

class PredictionResponse(BaseModel):
    DR_grade: str
    confidence: float
    processing_time: float

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    service: str

# Global variables
model = None
model_registry_id = None
model_version = "1.0.0"
class_names = ["No DR", "Mild", "Moderate", "Severe", "Proliferative DR"]

# MLOps services
prediction_logger = None
model_registry = None
logging_middleware = None

def load_model():
    """Load the pre-trained AI model"""
    global model, model_registry_id, model_version
    try:
        # Initialize MLOps services
        initialize_mlops_services()
        
        # Get production model from registry
        production_model = model_registry.get_production_model("eye_disease_classifier")
        
        if production_model:
            model_path = production_model['file_path']
            model_version = production_model['model_version']
            model_registry_id = production_model['id']
            logger.info(f"Loading production model: {model_version}")
        else:
            # Fallback to default model path
            model_path = os.getenv("MODEL_PATH", "/app/models/downloaded_model/converted_keras/keras_model.h5")
            model_version = "1.0.0"
            logger.warning("No production model found, using fallback model")
        
        if os.path.exists(model_path):
            model = tf.keras.models.load_model(model_path)
            logger.info(f"Model loaded from {model_path}")
        else:
            # Create a simple dummy model for demonstration
            logger.warning("No model found, creating dummy model")
            model = create_dummy_model()
        
        return True
    except Exception as e:
        logger.error(f"Error loading model: {e}")
        return False

def initialize_mlops_services():
    """Initialize MLOps services"""
    global prediction_logger, model_registry, logging_middleware
    
    try:
        # Initialize services
        database_url = os.getenv("DATABASE_URL", "postgresql://postgres:postgres123@localhost:5432/EyeDiseaseDB")
        redis_url = os.getenv("REDIS_URL", "redis://localhost:6379")
        model_storage_path = os.getenv("MODEL_STORAGE_PATH", "/tmp/mlops/models")
        
        model_registry = ModelRegistryService(database_url, model_storage_path)
        prediction_logger = PredictionLogger(database_url, redis_url)
        logging_middleware = PredictionLoggingMiddleware(prediction_logger)
        
        # Start prediction logger background processing
        asyncio.create_task(prediction_logger.start_background_processing())
        
        logger.info("MLOps services initialized successfully")
        
    except Exception as e:
        logger.error(f"Error initializing MLOps services: {e}")
        # Continue without MLOps if initialization fails

def create_dummy_model():
    """Create a dummy model for demonstration purposes"""
    # This is a placeholder - in production, use your actual trained model
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

def preprocess_image(image_data: str) -> np.ndarray:
    """Preprocess the base64 encoded image for model prediction"""
    try:
        # Decode base64 image
        image_bytes = base64.b64decode(image_data)
        image = Image.open(io.BytesIO(image_bytes))
        
        # Convert to RGB if necessary
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Convert to numpy array
        image_array = np.array(image)
        
        # Resize to model input size (224x224)
        image_resized = cv2.resize(image_array, (224, 224))
        
        # Normalize pixel values
        image_normalized = image_resized.astype(np.float32) / 255.0
        
        # Add batch dimension
        image_batch = np.expand_dims(image_normalized, axis=0)
        
        return image_batch
        
    except Exception as e:
        logger.error(f"Error preprocessing image: {e}")
        raise HTTPException(status_code=400, detail="Invalid image data")

def predict_disease(image_array: np.ndarray) -> Dict[str, Any]:
    """Make prediction using the loaded model"""
    try:
        # Make prediction
        predictions = model.predict(image_array)
        
        # Get predicted class and confidence
        predicted_class_idx = np.argmax(predictions[0])
        confidence = float(np.max(predictions[0]))
        predicted_class = class_names[predicted_class_idx]
        
        return {
            "DR_grade": predicted_class,
            "confidence": confidence
        }
        
    except Exception as e:
        logger.error(f"Error making prediction: {e}")
        raise HTTPException(status_code=500, detail="Prediction failed")

@app.on_event("startup")
async def startup_event():
    """Initialize the service on startup"""
    logger.info("Starting Eye Disease AI Service...")
    success = load_model()
    if success:
        logger.info("AI Service started successfully")
    else:
        logger.error("Failed to load model")

@app.get("/", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        model_loaded=model is not None,
        service="Eye Disease AI Service"
    )

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """Predict eye disease from retinal image"""
    start_time = time.time()
    
    try:
        # Validate model is loaded
        if model is None:
            raise HTTPException(status_code=503, detail="Model not loaded")
        
        # Preprocess image
        image_array = preprocess_image(request.image_data)
        
        # Make prediction
        result = predict_disease(image_array)
        
        processing_time = time.time() - start_time
        inference_latency_ms = int(processing_time * 1000)
        
        # Log prediction if MLOps services are available
        if prediction_logger and model_registry_id:
            await _log_prediction(
                request_data=request.dict(),
                response_data=result,
                inference_start_time=start_time,
                inference_latency_ms=inference_latency_ms
            )
        
        return PredictionResponse(
            DR_grade=result["DR_grade"],
            confidence=result["confidence"],
            processing_time=processing_time
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error during prediction: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

async def _log_prediction(self, request_data: Dict[str, Any], response_data: Dict[str, Any], 
                        inference_start_time: float, inference_latency_ms: int):
    """Log prediction with MLOps"""
    try:
        prediction_event = PredictionEvent(
            prediction_id=str(uuid.uuid4()),
            model_registry_id=model_registry_id,
            image_id=request_data.get('image_id'),
            patient_id=request_data.get('patient_id'),
            prediction_label=response_data.get('DR_grade', 'unknown'),
            confidence_score=response_data.get('confidence', 0.0),
            inference_latency_ms=inference_latency_ms,
            input_features={
                'image_size': len(request_data.get('image_data', '')),
                'model_version': model_version
            },
            preprocessing_metadata={
                'input_shape': (224, 224, 3),
                'normalization': 'pixel_values_0_to_1'
            },
            model_version=model_version,
            request_source="api",
            device_info=request_data.get('device_info'),
            batch_prediction_id=None
        )
        
        await prediction_logger.log_prediction(prediction_event)
        
    except Exception as e:
        logger.error(f"Error logging prediction: {e}")
        # Don't fail the prediction if logging fails

@app.get("/model/info")
async def model_info():
    """Get model information"""
    return {
        "model_loaded": model is not None,
        "model_version": model_version,
        "model_registry_id": model_registry_id,
        "input_shape": (224, 224, 3) if model else None,
        "classes": class_names,
        "service_version": "1.0.0",
        "mlops_enabled": prediction_logger is not None
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
