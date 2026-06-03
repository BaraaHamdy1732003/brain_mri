# Brain MRI AI Assistant

A full-stack **medical imaging application** for automated **brain MRI anomaly detection** and **AI medical consultation**.

The system allows users to upload MRI scans, receive AI predictions, store results securely, and ask an AI assistant for medical explanations.

The project includes:

- Flask Backend for MRI processing and inference  
- Flutter Mobile App for cross-platform interaction  
- Supabase for authentication and storage  
- Ollama LLM for AI medical consultation  

---
# Datasets

The model used in this project was trained and evaluated using the following publicly available datasets:

- [Brain Cancer - MRI Dataset](https://www.kaggle.com/datasets/orvile/brain-cancer-mri-dataset) - Contains MRI images for brain cancer classification.
- [Brain MRI Images](https://www.kaggle.com/datasets/ashfakyeafi/brain-mri-images) - A collection of brain MRI images for tumor detection.

# Features

- Automated Brain MRI anomaly detection
- AI medical consultation using Ollama
- Prediction confidence scoring
- MRI scan history tracking
- Secure user authentication via Supabase
- Multi-language support
  - English
  - Arabic
  - Russian
- Cross-platform mobile application
  - Android
  - iOS
- Local and cloud storage integration

---

# System Architecture

```
Flutter Mobile App
        |
        v
     Flask API
        |
        v
 MRI Detection Model
        |
        v
   Prediction Result
        |
        +--------------------+
        |                    |
        v                    v
     Supabase           Ollama LLM
(Authentication +       AI Medical
   Storage)              Assistant
```

---

# Tech Stack

## Backend

- Python
- Flask
- NumPy
- OpenCV / PIL
- Ollama
- REST API

## AI Stack

### MRI Detection

- TensorFlow / PyTorch model
- Image preprocessing
- Confidence scoring

### AI Medical Chat Assistant

- Ollama LLM
- Context-aware medical explanation

---

# Mobile Application

Built with **Flutter**

Technologies used:

- Flutter
- Provider (state management)
- Supabase
- HTTP package
- Material UI

### AI Layer

- Local LLM via Ollama  
- Model used: `glm-4.6:cloud`  
- Medical prompt engineering

---

# Prerequisites

Before running the project install:

- Python **3.10+**
- Flutter **3.16+**
- Android Studio
- **JDK 17**
- **Ollama**
- **Supabase account**

---

# Project Structure

```
brain_mri/
│
backend
├── app.py
├── converter.py
└── requirements.txt
│
lib
├── app.dart
├── l10n
│   ├── app_localizations.dart
│   └── language_provider.dart
├── main.dart
├── routes.dart
├── screens
│   ├── analysis
│   │   └── analysis_screen.dart
│   ├── auth
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── chat
│   │   └── chat_screen.dart
│   ├── home
│   │   ├── history_screen.dart
│   │   ├── home_screen.dart
│   │   ├── profile_screen.dart
│   │   └── result_screen.dart
│   └── splash_screen.dart
├── services
│   ├── auth_service.dart
│   ├── chatbot_service.dart
│   ├── last_prediction_store.dart
│   ├── local_storage.dart
│   ├── mri_api_service.dart
│   ├── mri_context.dart
│   └── supabase_service.dart
├── test_connection.dart
├── utils
│   └── theme.dart
└── widgets
    ├── custom_button.dart
    ├── input_field.dart
    ├── language_switcher.dart
    ├── prediction_tile.dart
    └── profile_widget.dart

```

---

# Backend Setup

Navigate to backend folder:

```
cd backend
```

Install dependencies:

```
pip install -r requirements.txt
```

Run the Flask server:

```
python app.py
```

Backend will run at:

```
http://127.0.0.1:5000
```

---

# Running the Mobile App

Navigate to project root and run:

```
flutter pub get
flutter run
```

---

# Development Workflow

1. Start **Ollama**
2. Start **Flask backend**
3. Run **Flutter app**
4. Upload MRI scan
5. View prediction
6. Ask AI assistant for explanation

---

# License

This project is **proprietary software** developed for **academic and research purposes**.

All rights reserved.