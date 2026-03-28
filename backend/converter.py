import tensorflow as tf
h5_model_path = "assets/model/best_densenet_model.h5"          
tflite_model_path = "assets/model/best_densenet_model.tflite"  

model = tf.keras.models.load_model(h5_model_path)
print("✅ Keras model loaded successfully.")

converter = tf.lite.TFLiteConverter.from_keras_model(model)

converter.optimizations = [tf.lite.Optimize.DEFAULT]


tflite_model = converter.convert()
print("✅ Model converted to TFLite format.")

with open(tflite_model_path, "wb") as f:
    f.write(tflite_model)

print(f"🎉 TFLite model saved as: {tflite_model_path}")
