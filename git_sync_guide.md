# Deploying the Leave Management App in a Few Clicks

Since the Power Platform CLI has a known offline compiler bug (`System.FormatException`), the most reliable and easiest way to make your app live in your environment (**`Default-af174864-f28c-4596-bae6-1123b5d70544`**) is using **Power Apps Git Integration**.

This bypasses the local compiler entirely and builds the app directly in the cloud in under 5 minutes!

---

## Step 1: Push the Code to GitHub / Azure DevOps

If you haven't already, push your `app2-working` directory contents to a Git repository:

1. Open Git Bash or your terminal in this directory:
   ```bash
   git init
   git add .
   git commit -m "Initial leave management app files"
   ```
2. Create a repository on GitHub (e.g., `leave-management-app`).
3. Link and push your code:
   ```bash
   git remote add origin <your-repo-url>
   git branch -M main
   git push -u origin main
   ```

---

## Step 2: Connect it to Power Apps (Only 3 Clicks!)

1. Go to [make.powerapps.com](https://make.powerapps.com/) and ensure you are in the environment **`Default-af174864-f28c-4596-bae6-1123b5d70544`**.
2. Click **Create** -> **Blank app** -> **Blank canvas app** (select Tablet/Landscape format).
3. Inside the Power Apps Studio editor:
   * Click **Settings** (gear icon) -> **Version control** -> **Git integration**.
   * Click **Connect**.
   * Enter your Git repository URL, branch name (`main`), and set the directory path to the folder containing the files (or leave blank if files are in the repository root).
4. Enter your Git username and a **Personal Access Token (PAT)** as the password (generate a PAT in GitHub under Developer Settings -> Personal Access Tokens).

---

## Step 3: Publish and Make it Live!

1. Once connected, Power Apps will automatically pull the `.pa.yaml` files, compile them, and display all the screens (**Dashboard, ApplyLeave, LeaveBalance, MyLeaves, ManagerApproval**) in your editor!
2. Click the **Publish** icon in the top-right corner.
3. Click **Publish this version**.

**Your Leave Management App is now LIVE and fully functional!**
