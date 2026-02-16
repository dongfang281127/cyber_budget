# FinCore (Cyber Budget) 💸

> **A Cyberpunk-style Personal Finance Manager built with Flutter.**

[![中文文档](https://img.shields.io/badge/Language-中文-red)](README_zh.md)

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![Hive](https://img.shields.io/badge/NoSQL-Hive-FF6F00?style=for-the-badge&logo=hive)
![Style](https://img.shields.io/badge/Style-Cyberpunk-00E5FF?style=for-the-badge)

## 📖 Introduction

**FinCore** is a personal finance application designed with a high-tech, futuristic Cyberpunk aesthetic. Unlike traditional accounting apps, FinCore treats your finances as a "system" to be managed. 

It features real-time financial trend charts similar to stock trading terminals, glitch art animations for opening scenes, and a robust local storage system using Hive. It helps you track income, expenses, and savings goals in a visually immersive environment.

## ✨ Features

* **🎨 Cyberpunk UI/UX:**
    * High-contrast neon color palette (Cyan/Green/Red) optimized for dark mode.
    * Immersive "Glitch" animations and "System Online" boot sequences.
    * Custom "Digital Terminal" aesthetic widgets.

* **📈 Financial Trend Visualization:**
    * Interactive line charts powered by `fl_chart`.
    * Stock-market style visualization for Income, Expense, and Net Balance.
    * Switchable time scopes: Weekly (1W), Monthly (1M), Yearly (1Y).

* **⚡ Efficient Transaction Management:**
    * Quick entry dialog with auto-category icons (e.g., Snacks, Parents, Digital).
    * Support for Income and Expense tracking with dynamic UI adaptation.
    * Built-in calendar date picker for historical data entry.

* **🔒 Privacy First:**
    * 100% Local storage using `Hive` NoSQL database.
    * No internet connection required, no data upload to any server.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** [Dart](https://dart.dev/)
* **State Management:** `Provider`
* **Local Database:** `Hive` (Fast NoSQL)
* **Charts:** `fl_chart`
* **Animations:** `flutter_animate`, Custom Painters

## 🚀 Getting Started

### Prerequisites
* Flutter SDK installed (Version 3.10.0 or higher recommended)
* Dart SDK installed
* An IDE (VS Code or Android Studio)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/dongfang281127/cyber_budget.git](https://github.com/dongfang281127/cyber_budget.git)
    cd cyber_budget
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate Hive Adapters:**
    *(Only needed if you modify the models)*
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

## 🤝 Contribution

Contributions are welcome! If you have any ideas for new features or bug fixes, feel free to open an issue or submit a pull request.


---

**Developed with ❤️ by Dongfang**
