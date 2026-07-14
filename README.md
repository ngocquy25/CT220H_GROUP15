
# 📘 CT220H Assignment Submission Guide

## 🔑 Quick Checklist
1. Fork the instructor’s repository.  
2. Clone your fork to your computer.  
3. Build your mobile app inside the project folder.  
4. Commit changes regularly with clear messages.  
5. Push commits to your fork and share the repo link.  

---

## 1. Fork the Course Repository
1. Go to the course repo: [hqnghi88/CT220H](https://github.com/hqnghi88/CT220H).
2. Click the **Fork** button (top right).
3. This creates a copy under your own GitHub account.

---

## 2. Clone Your Fork Locally
Open your terminal/command prompt and run:
```bash
git clone https://github.com/<your-username>/CT220H.git
cd CT220H
```

---

## 3. Configure Git (first time only)
```bash
git config --global user.name "Your Full Name"
git config --global user.email "your_email@example.com"
```

---

## 4. Work on Your Assignment
- Build your mobile app inside the cloned project folder.  
- Add your code, assets, and documentation.  
- Keep assignments organized in separate folders (e.g., `Assignment1/`, `Assignment2/`).  

---

## 5. Commit Your Changes
Stage and commit regularly:
```bash
git add .
git commit -m "Implemented login screen"
```

👉 **Important:** Use clear commit messages that describe what you did.

---

## 6. Push to Your Fork
Send commits to your forked repo:
```bash
git push origin main
```

---

## 7. Verify Your Commits
- Go to your fork on GitHub.  
- Click the **Commits** tab to see your history.  
- Ensure all changes are visible.  
 
---

## ✅ Best Practices
- **Commit often**: after each feature or bug fix.  
- **Write descriptive messages**: `"Added Firebase authentication"` is better than `"update"`.  
- **README file**: Include instructions on how to build/run your app.  

---

## 📂 Example Commit Flow
```bash
# After finishing a feature
git add .
git commit -m "Added user profile screen"
git push origin main
```

