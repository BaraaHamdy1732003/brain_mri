import tensorflow as tf

# === Path to your model ===
h5_model_path = "assets/model/brain_mri_4class_balanced_model.h5"           # Your input .h5 model file
tflite_model_path = "assets/model/brain_mri_4class_balanced_model.tflite"   # Output .tflite model file

# === Load the .h5 model ===
model = tf.keras.models.load_model(h5_model_path)
print("✅ Keras model loaded successfully.")

# === Convert to TensorFlow Lite format ===
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# (Optional) Enable optimizations for smaller model size
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# === Convert ===
tflite_model = converter.convert()
print("✅ Model converted to TFLite format.")

# === Save the .tflite model ===
with open(tflite_model_path, "wb") as f:
    f.write(tflite_model)

print(f"🎉 TFLite model saved as: {tflite_model_path}")
