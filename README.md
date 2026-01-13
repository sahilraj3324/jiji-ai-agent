# Jiji Agent 🌸

**Jiji Agent** is a personable, anime-themed AI assistant built with Flutter and powered by the Gemini API. Designed with a vibrant **"Anime Glass"** aesthetic, it offers a unique and engaging chat experience.

<p align="center">
  <img src="https://api.dicebear.com/7.x/avataaars/png?seed=Jiji&backgroundColor=b6e3f4" width="150" height="150" alt="Jiji Avatar">
</p>

## ✨ Features

- **Jiji Persona**: A friendly, helpful AI "waifu" companion.
- **Anime Glass Aesthetics**: 
  - Deep violet radial gradient backgrounds (`#2E1A47` -> `#0F0F11`).
  - Glassmorphism effects on inputs and message bubbles.
  - Soft Sakura Pink (`#FFFF8B7D`) and Purple (`#C58AF9`) accents.
- **Interactive Chat**:
  - Real-time responses using Google's **Gemini 2.5 Flash** model.
  - Markdown support for code and formatted text.
  - "Thinking" indicators with custom animations.
- **Project Structure**:
  - Clean separation between **Home Screen** (Landing) and **Chat Screen** (Conversation).
  - Modularized codebase.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **AI Model**: [Google Gemini API](https://ai.google.dev/)
- **State Management**: `setState` (Simple & Effective for this scale)
- **Networking**: `http` package
- **Icons**: Material Icons + Custom Lucide-style implementations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed on your machine.
- A valid Google Gemini API Key.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/sahilraj3324/jiji-ai-agent.git
   cd jiji-ai-agent
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Key**:
   - Open `lib/screens/home_screen.dart` or `lib/api/gemini_api.dart`.
   - Replace the API key placeholder with your own Gemini API Key.

4. **Run the app**:
   ```bash
   flutter run
   ```

## 📸 Screenshots

*(Add your screenshots here)*

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
Made with 💜 by [Your Name]
