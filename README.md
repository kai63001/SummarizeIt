# Summarize It

**Instant text, video & audio summaries on iOS**
Flutter client · Python (llmlingua) & Node.js (Whisper) services · MongoDB · RevenueCat IAP

Summarize It distills long-form content into concise take-aways so users can “read the gist” instead of wading through hours of material. Inspired by the live App Store release, our open-source rebuild keeps the spirit but swaps in a modern, developer-friendly stack.

---

## ⚡️ Core features

* **Text summarisation** – drop any article or paste raw text to get a crisp abstract
* **Video summarisation** – paste a YouTube/Vimeo link; Whisper → transcript → llmlingua → bullets
* **Webpage & audio summarisation** – handle full URLs or voice memos on-device
* **Integrated playback & file vault** – listen, watch, and manage source files in-app
* **Productivity focus** – save time, organise insights, and skip tedious note-taking

---

## 🏗️ Tech stack at a glance

| Layer                           | Tech                                            | Role                                                    |
| ------------------------------- | ----------------------------------------------- | ------------------------------------------------------- |
| **Mobile**                      | Flutter 3, Riverpod, GoRouter                   | Single code-base for iPhone, iPad |
| **compress the promp**                 | Python FastAPI + **llmlingua**                  | Fast extractive / abstractive summaries                 |
| **Transcription micro-service** | Python + **Whisper.cpp**                    | GPU/Metal-accelerated speech-to-text                    |
| **Database**                    | MongoDB Atlas                                   | Store requests, transcripts, summaries                  |
| **Monetisation**                | **RevenueCat**                                  | Paywall, subscriptions, App Store receipts              |
| **Backend**                       | Nodejs + Mongodb | Main Backend                              |

---

## 🧩 System overview

* **Flutter** delivers 60 fps UI across iOS, iPadOS, macOS & visionOS.
* **llmlingua** provides ultra-compact, factual summaries with configurable length.
* **Whisper.cpp** runs fully offline on Apple silicon for privacy-first transcripts.
* **RevenueCat** handles purchase flow, receipt validation & entitlement caching.

