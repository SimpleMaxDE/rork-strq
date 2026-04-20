# 💪 ExerciseDB Data Collection

This folder contains pre-fetched **ExerciseDB** exercise data stored in JSON format, allowing your app to use it without calling the API in production.


---


## 📁 Files Included

### `exercises2.json`
Full exercise list (cached) — contains all exercise data ready to use.

### `bodyParts2.json`
Body-part mapping using exercise IDs for easy filtering.


---


## ⚠️ Important Notes


### 1️⃣ GIF URLs May Not Work in Browser (But Work in the App!)

The `gifUrl` inside `exercises2.json` may fail if you manually copy-paste it into a browser. This happens due to **CORS restrictions**.

**✅ Don't worry:** All GIFs work properly when used inside the **mobile app** (React Native or flutter etc), because mobile apps are usually not blocked by browser CORS rules.


### 3️⃣ `bodyParts2.json` Provided for Easy Filtering

You don't need to manually map exercises!

`bodyParts2.json` already contains body parts with their related exercise IDs, so you can easily load exercises by ID inside your app.


---

🎥 Animation Notes

The GIF animations are optimized for fast loading and smooth performance in applications.

# Look clear when displayed at smaller sizes inside your app
# May appear less clear when zoomed or shown in full-screen
# Designed to balance performance and usability

📌 Example of how animations look good in an app:
https://drive.google.com/file/d/1ZoEnbxsrVlrV2p3hBseiu-NEzx5hchQe/view?usp=sharing

---

## 🧩 Need Help?

If you need help integrating this into your app, feel free to reach out:

📩 **profilesleetcode@gmail.com**


---


## 🚀 Quick Start

1. **Import the data** in your app
2. **Reference `bodyParts2.json`** to filter exercises by body part
3. **Display GIFs** directly in your app using the `gifUrl` field


---


**Happy Coding!** 💻✨