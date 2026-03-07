# Brain MRI AI Assistant

This project provides a full-stack medical imaging application for automated brain MRI anomaly detection and AI consultation.
It consists of a Flask backend for MRI processing and AI inference, and a Flutter mobile application for cross-platform user interaction.

The system enables users to upload MRI scans, receive automated predictions, store history securely, and consult an AI medical assistant powered by Ollama.

## Features
- Automated brain MRI anomaly detection
- AI-powered medical consultation (Ollama integration)
- Prediction confidence scoring
- MRI scan history tracking
- User authentication (Supabase)
- Multi-language support (English & Arabic & Russian)
- Cross-platform mobile app (Android & IOS)
- Local and cloud storage integration

## Architecture Overview
- Mobile App (Flutter)
- Flask Backend API
- AI Model (MRI Detection)
- Ollama LLM (Medical Chat Assistant)
- Supabase (Authentication + Storage)

## Setup
- - Prerequisites

- Python 3.10+
- Flutter 3.16+
- Android Studio
- JDK 17
- Ollama installed
- Supabase account

## Project Structure
<  brain_mri/
│
├── backend/
│   ├── app.py                    # Flask backend API
│   ├── requirements.txt          # Python dependencies
│   └── OAS2_0001_MR2_z_slice_102.jpg
│
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── routes.dart
│   │
│   ├── models/
│   │   └── user_model.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── chatbot_service.dart
│   │   ├── mri_api_service.dart
│   │   ├── supabase_service.dart
│   │   ├── local_storage.dart
│   │   ├── mri_context.dart
│   │   └── last_prediction_store.dart
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   ├── home/
│   │   └── chat/
│   │
│   ├── widgets/
│   ├── utils/
│   └── l10n/
│
└── android/
>

## AI Stack

MRI Detection
- TensorFlow / PyTorch model
- Image preprocessing
- Confidence scoring

AI Chat Assistant
- Ollama 
- Context-aware medical explanation

## Backend

- Flask
- Python
- NumPy
- OpenCV / PIL
- Ollama
- REST API

## Mobile App
- Flutter
- Provider state management
- Supabase
- HTTP package
- Material UI
- AI Layer
- Local LLM via Ollama 'glm-4.6:cloud'
- Medical prompt engineering
 
## Accessing the Application
Backend API:
< http://127.0.0.1:5000
>

## Development Workflow
1. Start Ollama
2. Start Flask backend
3. Run Flutter app
4. Upload MRI
5. View prediction
6. Ask AI assistant for explanation

## License
This project is proprietary software developed for academic and research purposes.
All rights reserved.