import os
import tensorflow as tf
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image

app = Flask(__name__)
CORS(app)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_PATH = os.path.join(
    BASE_DIR,
    "..",
    "assets",
    "model",
    "best_densenet_model.tflite"
)

LABELS = [
    "brain_glioma",
    "brain_menin",
    "brain_tumor",
    "normal"
]

IMG_SIZE = 224

try:
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    print("✅ TFLite model loaded")
except Exception as e:
    print("❌ Model loading failed:", e)
    raise e

def preprocess_image(image: Image.Image):
    image = image.convert("RGB")
    image = image.resize((IMG_SIZE, IMG_SIZE))
    image = np.array(image, dtype=np.float32)
    image = image / 255.0
    image = np.expand_dims(image, axis=0)
    return image
@app.route("/", methods=["GET"])
def health():
    return jsonify({"status": "MRI API running"}), 200


@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "Image file is required"}), 400

    try:
        file = request.files["image"]
        image = Image.open(file)

        input_data = preprocess_image(image)

        interpreter.set_tensor(input_details[0]["index"], input_data)
        interpreter.invoke()

        output = interpreter.get_tensor(output_details[0]["index"])[0]

        predicted_index = int(np.argmax(output))
        confidence = float(output[predicted_index])

        return jsonify({
            "label": LABELS[predicted_index],
            "confidence": round(confidence, 4),
            "probabilities": {
                LABELS[i]: round(float(output[i]), 4)
                for i in range(len(LABELS))
            }
        })

    except Exception as e:
        print("❌ Prediction error:", e)
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    print("🚀 Starting MRI Flask API...")
    app.run(
        host="127.0.0.1",
        port=5000,
        debug=True,
        use_reloader=False
    )
