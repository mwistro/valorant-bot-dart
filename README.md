<p align="center">
  <img src="banner.png" alt="Valorant Stats Bot Banner" />
</p>
# 🧠 Valorant Stats Bot (in Dart)

This is my first **big personal project built with Dart**: a Discord bot that integrates with the [HenrikDev API](https://docs.henrikdev.xyz/) to fetch statistics and match history for **Valorant** players.  
Made with ❤️, occasional bugs, and a lot of learning along the way.

---

## 🚀 Features

- 🔍 `/perfil` — Displays basic profile info (level, region, card, rank).
- 📊 `/stats` — Shows general stats based on the last 10 matches.
- 🕹️ `/historico` — Lists detailed history of the last 10 matches.

---

## 📦 Tech Stack

- [Dart](https://dart.dev/)
- [nyxx](https://pub.dev/packages/nyxx) & [nyxx_commands](https://pub.dev/packages/nyxx_commands) — Discord bot framework for Dart
- [http](https://pub.dev/packages/http) — For making API requests
- [dotenv](https://pub.dev/packages/dotenv) — For safely managing API keys and tokens
- Public API: [HenrikDev Valorant API](https://docs.henrikdev.xyz/)

---

## 🛠️ How to Run

1. Clone the repo:
   ```bash
   git clone https://github.com/mwistro/valorant-bot-dart.git
   cd valorant-bot-dart
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

3. Create a `.env` file in the root folder with the following content:
   ```env
   YOUR-HDEV-APIKEY-HERE=...
   YOUR-BOT-TOKEN-HERE=...
   YOUR-SERVER-ID-HERE=...
   ```

4. Run the bot:
   ```bash
   dart run
   ```

---

## 📷 Screenshots (optional)

*You can add some screenshots here to show how the bot looks on Discord.*

---

## 🤓 About

This project was built as a way to study and practice Dart by creating a functional Discord bot.  
There may still be bugs, duplicated code, or things to improve — but it was built with care and a lot of curiosity.

Feel free to use it, suggest improvements, or open a pull request!  
Let’s learn and build together 🧠💻

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
