# BioChef AI

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg?style=flat-square&logo=flutter)](https://flutter.dev)
[![AI Engine](https://img.shields.io/badge/AI_Engine-Groq_LLM-darkgreen.svg?style=flat-square&logo=openai)](https://groq.com)
[![License](https://img.shields.io/badge/License-MIT_%2B_Safety-red.svg?style=flat-square)](https://github.com/LonDave/biochef_app/blob/main/LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=flat-square)](https://github.com/LonDave/biochef_app)

**BioChef AI** is the first intelligent culinary supervisor designed for high-performance and absolute family safety. 

---

## 🌎 [English](#english) | [Italiano](#italiano) | [Security](#security) | [License](https://github.com/LonDave/biochef_app/blob/main/LICENSE) | [Install](#install)

---

## <a name="english"></a>English

### 🌟 Key Features
- **Smart AI Interaction**: Powered by Groq LLM with sliding window token optimization.
- **Dietary Safety Engine**: Real-time filtering of allergens and non-edible items via `BCDietary`.
- **Salted Backup (V2)**: Cross-platform secure backup with SHA-256 verification.
- **Privacy First**: Groq API keys and health data stay exclusively on your device.

### 🛠️ Technical Architecture
- **Tech Stack**: Flutter 3, Hive (NoSQL), Groq API.
- **Performance**: Multithreaded logic using Isolates for zero-lag UI.

---

## <a name="italiano"></a>Italiano

### 🌟 Caratteristiche Principali
- **Interazione AI Intelligente**: Basata su Groq LLM con ottimizzazione Sliding Window dei token.
- **Motore di Sicurezza**: Filtraggio in tempo reale di allergeni e sostanze pericolose tramite `BCDietary`.
- **Backup Salato (V2)**: Sistema di esportazione sicuro con validazione SHA-256 integrata.
- **Privacy Totale**: Il controllo dei dati e delle chiavi API è interamente locale.

### 🛠️ Architettura Tecnica
- **Tecnologie**: Flutter 3, Hive (NoSQL), Groq API.
- **Performance**: Utilizzo di Isolati per una reattività dell'interfaccia impeccabile.

---

## <a name="security"></a>🧩 The BioChef Protocol (Technical)
**Context Management**: BioChef implements a Sliding Window to stay within optimal token limits (2500 chars) for maximum speed.
**Salted XOR Encryption**: Backups are salted and validated via SHA-256 before any data is processed.

---

## ⚖️ Legal Shield

> [!CAUTION]
> **Safety First / La Sicurezza Prima di Tutto**
> - **EN**: AI suggestions are for informational purposes. Always verify ingredients.
> - **IT**: Le ricette generate dall'IA possono contenere errori. Verifica sempre gli ingredienti.

---

## <a name="install"></a>🚀 Setup & Installation
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