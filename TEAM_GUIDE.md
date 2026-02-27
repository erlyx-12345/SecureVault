# 🚀 Team Member Guide - Getting Started

This guide is for **M2, M3, M4, and M5** - explaining how to clone the project, set up your local environment, and start working on your assigned role.

---

## 📋 Quick Reference by Role

| Role | Member | First Task | File to Edit |
|------|--------|-----------|--------------|
| **M2** | Core Auth Developer | Implement AuthViewModel | `lib/viewmodels/auth_viewmodel.dart` |
| **M3** | Security Engineer | Create UserModel | `lib/models/user_model.dart` |
| **M4** | UI/UX Designer | Build LoginView | `lib/views/login_view.dart` |
| **M5** | Integration Specialist | Add Google SSO | `lib/services/auth_service.dart` |

---

## **Step 1: Clone the Repository**

### On Your Computer:

1. **Open PowerShell** (or Command Prompt)
2. **Navigate to where you want the project:**
   ```powershell
   cd C:\Users\YourName\Documents
   ```

3. **Clone the repository** (replace the URL with your actual GitHub repo):
   ```powershell
   git clone https://github.com/erlyx-12345/SecureVault.git
   cd SecureVault
   ```

4. **You now have the project!** ✅

---

## **Step 2: Open the Project in VS Code**

```powershell
# While in the project directory:
code .
```

Or manually open VS Code and select the `SecureVault` folder.

---

## **Step 3: Install Dependencies**

In VS Code Terminal (Ctrl + `):

```powershell
flutter pub get
```

This installs all required packages.

---

## **Step 4: Create Your Feature Branch**

**Each team member should work on their own branch** to avoid conflicts.

```powershell
# Create a branch for your role
git checkout -b feature/M2-auth-viewmodel      # For M2
git checkout -b feature/M3-security            # For M3
git checkout -b feature/M4-ui-views            # For M4
git checkout -b feature/M5-google-sso          # For M5

# Verify you're on your branch
git branch
```

**Output will show:**
```
  main
* feature/M2-auth-viewmodel   <- (starred means you're here)
```

---

## **Step 5: Start Working on Your Files**

### **M2 - Core Auth Developer**
Files to implement:
- [ ] `lib/viewmodels/auth_viewmodel.dart` - AuthViewModel class
- [ ] `lib/services/auth_service.dart` - Auth methods
- [ ] `lib/viewmodels/profile_viewmodel.dart` - Profile logic

### **M3 - Security Engineer**
Files to implement:
- [ ] `lib/models/user_model.dart` - User data class
- [ ] `lib/utils/constants.dart` - Colors, strings, regex patterns
- [ ] `lib/utils/validators.dart` - Email/password validators
- [ ] `lib/services/storage_service.dart` - Secure storage
- [ ] `lib/services/biometric_service.dart` - Fingerprint logic

### **M4 - UI/UX Designer**
Files to implement:
- [ ] `lib/views/login_view.dart` - Login screen
- [ ] `lib/views/register_view.dart` - Registration screen
- [ ] `lib/views/profile_view.dart` - Profile screen
- [ ] `lib/views/widgets/` - Custom widgets (buttons, textfields, dialogs)

### **M5 - Integration Specialist**
Files to implement:
- [ ] Add Google Sign-In to `lib/services/auth_service.dart`
- [ ] Update `lib/models/user_model.dart` with additional fields
- [ ] Test and QA all features
- [ ] Bonus: Facebook Login

---

## **Step 6: Save Your Changes Locally**

As you code, your changes are **only on your computer** until you commit and push.

---

## **Step 7: Commit Your Work**

When you finish a meaningful chunk of work:

```powershell
# See what files changed
git status

# Add all your changes
git add .

# Create a commit with a message
git commit -m "M2: Implement AuthViewModel with login logic"
```

**Good commit messages:**
- ✅ "M2: Implement AuthViewModel"
- ✅ "M3: Add email validator regex"
- ✅ "M4: Build LoginView with form"
- ❌ "fixed stuff"
- ❌ "update"

---

## **Step 8: Push Your Branch to GitHub**

```powershell
# Push your branch (first time)
git push -u origin feature/M2-auth-viewmodel

# After first time, just:
git push
```

Your code is now on GitHub! ✅

---

## **Step 9: Get Latest Changes from Team**

If M1 or other members pushed new code:

```powershell
# Get latest from main branch (without switching)
git fetch origin

# See what changed
git log origin/main --oneline

# If you need to sync your branch with main (optional)
git pull origin main
```

---

## **Step 10: Create a Pull Request (PR)**

When your work is **complete and tested**:

1. Go to **GitHub.com** → Your repo
2. Click **"Pull requests"** tab
3. Click **"New pull request"**
4. Select:
   - **Base branch**: `main`
   - **Compare branch**: `feature/M2-auth-viewmodel` (your branch)
5. Add title: `M2: Implement AuthViewModel`
6. Add description of what you did
7. Click **"Create pull request"**

**M1 (Lead) will review and merge it** into main. ✅

---

## **📊 Full Workflow Summary**

```
1. git clone                    # Get project
2. flutter pub get              # Install packages
3. git checkout -b feature/...  # Create your branch
4. Edit files                   # Do your work
5. git add .                    # Stage changes
6. git commit -m "..."          # Commit locally
7. git push                     # Push to GitHub
8. Create PR on GitHub          # Merge to main
```

---

## **🆘 Common Issues & Solutions**

### **Issue: "I don't know what to code"**
- ✅ Check the instructions in the README.md
- ✅ Check the **Feature Requirements** section
- ✅ Ask M1 (Lead Architect) for clarification

### **Issue: "git says file conflicts"**
```powershell
# Pull latest changes
git pull origin main

# Fix conflicts manually in VS Code, then:
git add .
git commit -m "Resolve merge conflicts"
git push
```

### **Issue: "I need the latest code from team members"**
```powershell
git fetch origin
git pull origin main
```

### **Issue: "I made a mistake in my commits"**
```powershell
# Undo last commit (keeps changes)
git reset --soft HEAD~1

# Or start fresh (careful!)
git reset --hard HEAD~1
```

### **Issue: "Can't push - 'authentication failed'"**
- Make sure you're using HTTPS URL (not SSH)
- Or configure SSH keys: [GitHub SSH Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

## **✅ Before You Start - Checklist**

- [ ] Project cloned
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Your branch created (`git checkout -b feature/...`)
- [ ] VS Code opened and ready
- [ ] Understood your assigned role
- [ ] Read the Feature Requirements section

---

## **📞 Need Help?**

1. Ask **M1 (Lead Architect)**
2. Check GitHub Issues (if created)
3. Check the main README.md for feature requirements

---

## **🎯 Expected Timeline**

- **Days 1-2**: Clone, setup, understand requirements
- **Days 3-7**: Implement your assigned files
- **Day 8**: Test, debug, create PR
- **Day 9**: M1 merges, build final APK
- **Day 10**: Submit to instructor

---

**Good luck! You've got this! 🚀**
