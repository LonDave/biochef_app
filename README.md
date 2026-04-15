# BioChef AI

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg?style=flat-square&logo=flutter)](https://flutter.dev)
[![AI Engine](https://img.shields.io/badge/AI_Engine-Groq_LLM-darkgreen.svg?style=flat-square&logo=openai)](https://groq.com)
[![License](https://img.shields.io/badge/License-MIT_%2B_Safety-red.svg?style=flat-square)](https://github.com/LonDave/biochef_app/blob/main/LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=flat-square)](https://github.com/LonDave/biochef_app)

**BioChef AI** is a smart culinary supervisor designed by **Davide Longo (LonDave)**. It bridges the gap between AI-driven recipe generation and strict family dietary safety requirements.

---

## 🌎 Index / Indice
- [English Version](#english-version)
- [Versione Italiana](#versione-italiana)
- [The BioChef Protocol (Technical)](#the-biochef-protocol-technical)
- [Legal Shield](#⚖️-legal-shield--safety-mandatory)
- [Setup & Installation](#🚀-setup--installation)

---

## English Version

### 🌟 Key Features
- **Smart AI Interaction**: Powered by Groq LLM with sliding window token optimization.
- **Dietary Safety Engine**: Real-time filtering of allergens and non-edible items via `BCDietary`.
- **Salted Backup (V2)**: Cross-platform secure backup with SHA-256 verification.
- **Privacy First**: No cloud mirrors. Your Groq API key stays on your device.

### 🛠️ Technical Architecture
- **Tech Stack**: Flutter 3, Hive (NoSQL), Groq API.
- **Performance**: Heavy use of Isolates for multithreading and zero-lag UI.
- **Cross-Platform**: Optimized for Android, iOS, and Windows Desktop.

---

## Versione Italiana

### 🌟 Caratteristiche Principali
- **Interazione AI Intelligente**: Basata su Groq LLM con ottimizzazione Sliding Window dei token.
- **Motore di Sicurezza**: Filtraggio in tempo reale di allergeni e sostanze pericolose tramite `BCDietary`.
- **Backup Salato (V2)**: Sistema di esportazione sicuro con validazione SHA-256 integrata.
- **Privacy Totale**: Le chiavi API sono memorizzate localmente e non vengono mai inviate all'esterno.

### 🛠️ Architettura Tecnica
- **Tecnologie**: Flutter 3, Hive (NoSQL), Groq API.
- **Performance**: Utilizzo di Isolati Dart per operazioni asincrone fluide.
- **Multi-Piattaforma**: Perfetta stabilità su Mobile e Windows PC.

---

## 🧩 The BioChef Protocol (Technical)

### Context Management
BioChef uses a **Sliding Window** mechanism to prune conversation history, maintaining optimal inference speed while retaining critical user preferences.

### Security Hardening
Backups utilize a **Salted XOR** algorithm with **SHA-256** hash pre-validation, ensuring data integrity and zero-knowledge privacy.

---

## ⚖️ Legal Shield & Safety (MANDATORY)

> [!CAUTION]
> **Safety First / La Sicurezza Prima di Tutto**
> - **EN**: BioChef AI recipes are AI-generated. The user is legally responsible for verifying all ingredients.
> - **IT**: Le ricette di BioChef AI sono generate da IA. L'utente è legalmente responsabile della verifica di ogni ingrediente.

---

## 🚀 Setup & Installation
```bash
git clone https://github.com/LonDave/biochef_app.git
flutter pub get
flutter run
```

---

## 👨‍💻 Developed by [Davide Longo (LonDave)](https://github.com/LonDave)
Copyright © 2026. Licensed under [MIT + AI Safety Clause](LICENSE).

---
*Precision. Safety. Intelligence.* / *Precisione. Sicurezza. Intelligenza.*