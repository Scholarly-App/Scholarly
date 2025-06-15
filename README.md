# Scholarly: AI Driven Smart Learning Assistant

## 📘 Project Description

In the modern educational era, students often struggle to maintain focus whilst watching long video lectures or learning via a textbook. The main problem here is retaining focus while studying.

**Scholarly** aims to solve this problem by developing an innovative educational app to revolutionize how students comprehend and interact with learning-based content.

Scholarly enables students to upload a book and automatically generate a personalized learning roadmap based on their uploaded content. The generated roadmap will act as a study plan and will allow students to track their progress as they move forward.

For each topic in the roadmap, the app will provide both detailed and summarized explanations, ensuring an efficient and effective learning experience. Additionally, students will be able to generate short educational videos (reels) for their selected topics. The main objective of these reels will be to make complex topics easier to understand and learn them with great speed and accuracy, without losing focus.

Furthermore, the app also features MCQ-based quiz generation, allowing students to assess their knowledge and understanding of each selected topic.

The core objective of this project is to solve students’ issue of losing focus whilst studying by combining traditional study methods with cutting-edge AI technology, making education more interactive, personalized, and efficient.

---

## 🛠 Tech Stack

- Python
- Flutter
- Dart
- Flask API
- Google Cloud Platform
- Kaggle
- Firebase
- Android Studio

---

## 🚀 Features

- ✅ User Registration and Authentication
- ✅ User Dashboard and Analytics
- ✅ Upload Book
- ✅ Automatic Roadmap Generation
- ✅ Content Based Textual Explanations
- ✅ Topic Based Summary Generation
- ✅ Topic Based Short Videos (Reels) Generation
- ✅ Generate Key Assessments MCQs for Selected Topic
- ✅ Real-Time Assessment Evaluation
- ✅ Feedback Functionality for Generated Reels

---

## 📱 Sample UI Screens
<p align="center">
  <img src="User Interface/Splash%20Screen.jpg" alt="Splash Screen" width="30%" />
  <img src="User Interface/Login%20Screen.jpg" alt="Login Screen" width="30%" />
  <img src="User Interface/Home%20Screen.jpg" alt="Home Screen" width="30%" />
</p>
<p align="center">
  <img src="User Interface/Upload%20Book%20Screen.jpg" alt="Upload Books Screen" width="30%" />
  <img src="User Interface/User%20Books%20Screen.jpg" alt="User Books Screen" width="30%" />
  <img src="User Interface/Roadmap%20Screen.jpg" alt="Roadmap Screen" width="30%" />
</p>
<p align="center">
  <img src="User Interface/Expanded%20Roadmap%20Screen.jpg" alt="Expanded Roadmap Screen" width="30%" />
  <img src="User Interface/Text%20Explanation%20Screen.jpg" alt="Textual Explanation Screen" width="30%" />
  <img src="User Interface/Generated%20Summary%20Screen.jpg" alt="Summary Screen" width="30%" />
</p>

<p align="center">
  <img src="User Interface/Quiz%20Screen.jpg" alt="Quiz Screen" width="30%" />
  <img src="User Interface/Meme%20Video%20Sample.jpg" alt="Meme Video Screen" width="30%" />
  <img src="User Interface/Educational%20Video%20Sample.jpg" alt="Educational Video Screen" width="30%" />
</p>

---

## 🎥 Demo Video

[Watch Demo](https://drive.google.com/file/d/1Aw8m-Wu0kFfK9iP9vpdW6Zz2pP6tbizq/view?usp=sharing)

---
## 📱 Execution Guide
To simply run the app on your mobile device, download and install the APK from the latest release on this GitHub Repo

---

## ⚙️ Installation Guide

### 🧩 Prerequisites

Before getting started, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio)
- [Git](https://git-scm.com/downloads)

---

### 📥 Clone the Repository

```bash
git clone https://github.com/Scholarly-App/Scholarly.git
```

Open the cloned repository in **Android Studio**.

---

### 📦 Install Flutter Dependencies

```bash
flutter pub get
```

---

### 🔥 Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Create a new project.
3. Create a Realtime Database
4. Next Install Firebase CLI and Register the app using Firebase CLI in your Android Studio Terminal
5. Download the \`google-services.json\` file.
6. Place it in your project at:

```plaintext
android/app/google-services.json
```
---

### ▶️ Run the App

```bash
flutter run
```

---

## 🧠 Local Server Setup

### Note
In the below steps you will need to download multiple models and place them in different folder
The download scripts for the models can be found in the `Scholarly Local Host/Model_Downloads/`



### 1️⃣ Create Python Virtual Environment & Install Dependencies

Navigate to Scholarly Local Host Folder and run:

```bash
python -m venv scholarly python=3.12
source scholarly/bin/activate  # For Linux/macOS
scholarly\Scripts\activate     # For Windows

pip install -r requirements.txt
```

---

### 📘 Download and Configure the Summarization Model

1. Download the BART large CNN model from Hugging Face:  
   👉 https://huggingface.co/facebook/bart-large-cnn

2. Place the downloaded model inside:

```plaintext
bart_large_cnn_local/
```

3. Update the **model path** in `summarize.py` to point to the correct path on your system.

---

### 🎞️ Video Generation Setup

Navigate to the `Video Generation` folder and:

#### 1. Create & Activate a New Virtual Environment:

```bash
python -m venv video_gen 
source video_gen/bin/activate  # For Linux/macOS
video_gen\Scripts\activate     # For Windows
```

#### 2. Install Requirements:

```bash
winget install ffmpeg
python -m spacy download en_core_web_sm
set PEXELS_API_KEY= "Your PEXELS API KEY"
```

#### 3. Install Fonts (Linux/macOS):

```bash
mkdir -p ~/.local/share/fonts
cp fonts/* ~/.local/share/fonts/ && fc-cache -f -v

If you are using Windows
Open C:\Users\YourUsername\AppData\Local\Microsoft\Windows\Fonts
Drag and drop your font files (.ttf, .otf) into this folder.
Double-click the font files and click Install.

```

Next Download the Whisper Base model from Hugging Face:  
   👉 https://huggingface.co/openai/whisper-base

and Place the downloaded model inside:

```plaintext
Scholarly Local Host/Video Generation/whisper
```

---

### ❓ Question Generation Setup

Navigate to the `Question Generation` folder and:

#### 1. Create & Activate a New Virtual Environment:

```bash
python -m venv q_gen python=3.8
source q_gen/bin/activate  # For Linux/macOS
q_gen\Scripts\activate     # For Windows
```

#### 2. Install Requirements:

```bash
pip install -r requirements.txt
```

### 3. Download Additional Models

- Go to "Question Generation/app/ml_models"
- You will find directories for each models that you need to configure.
- Follow the links and steps provided in the README file available in the subdirectories of the 'models' directory, i.e. `Question Generation/app/ml_models/<subdirectory>`
- Or, Directly download [T5 fine-tuned on SQuAD for Question-Answer Pair Generation here](https://drive.google.com/file/d/1xMUmYbwSxGQoEeUSm95KyOKPei_DmEml/view?usp=drive_link), unzip and place it in `Question Generation/app/ml_models/question_generation/models`.
- Download [T5 fine-tuned on RACE dataset for Distractor here](https://drive.google.com/file/d/1tXHVmXkSLz5qFoDTnAQ17oBDvMXE0YnC/view?usp=drive_link), unzip and place in `Question Generation/app/ml_models/distractor_generation/models`.
- Download [s2v-2015 here](https://github.com/explosion/sense2vec/releases/download/v1.0.0/s2v_reddit_2015_md.tar.gz), unzip and place `s2v_old` folder in `Question Generation/app/ml_models/sense2vec_distractor_generation/data`

---

## 🖥️ Run Local Server Functionalities

Each functionality should be run in a **separate terminal**, and make sure the environment is activated in each.

---

### 📘 Upload Book

```bash
source scholarly/bin/activate
scholarly\Scripts\activate (Windows)
python upload-book.py
```

---

### 📘 Summary Generation

```bash
source scholarly/bin/activate
scholarly\Scripts\activate (Windows)
python summarize.py
```

---

### 🎬 Reels Generation

```bash
cd Video Generation
source video_gen/bin/activate
video_gen\Scripts\activate (Windows)
python generate-reels.py
```
If you face any issues regarding the whisper model, you can manually download it and place it in the 

---

### 🌐 Serve Reels

```bash
cd Video Generation
source video_gen/bin/activate
video_gen\Scripts\activate (Windows)
python serve-reels.py
```

---

### ❓ Quiz/MCQ Generation

```bash
cd Question Generation
source q_gen/bin/activate
q_gen\Scripts\activate (Windows)
python mcq-app.py
```

---

✅ **Your local server is now fully set up and functional.
- Now Finally Get your IP Address that should look like this 192.168.10.0  and in the Android Studio Navigate to lib/config.dart and update your IP Address:
- static const String baseUrl = 'http://192.168.10.0';
- Remember to Replace the IP Address with your current IP Address
**
