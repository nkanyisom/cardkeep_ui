# 🚀 CardKeep - Quick Deployment Setup

## Prerequisites

Before deploying CardKeep, ensure you have the following installed:

### Required Tools
- [ ] **Flutter SDK** (3.16.0 or later)
- [ ] **Dart SDK** (included with Flutter)
- [ ] **Git**
- [ ] **Node.js & npm** (for Firebase CLI)

### Optional Tools (based on deployment target)
- [ ] **Docker** (for containerized deployment)
- [ ] **AWS CLI** (for AWS deployment)
- [ ] **Terraform** (for AWS infrastructure)

## 🔧 Environment Setup

### 1. Copy Environment Configuration
```bash
cp .env.example .env
```

### 2. Update Environment Variables
Edit `.env` file with your actual values:

```bash
# Production API URL
FLUTTER_APP_API_BASE_URL_PROD=https://your-api-domain.com/api

# Firebase Configuration (get from Firebase Console)
FIREBASE_API_KEY=your-actual-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef123456
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX
```

## 🏗️ Build Process

### Option 1: Quick Build & Deploy
```bash
# Windows
deploy.bat

# Linux/Mac
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Manual Build
```bash
# Windows
build-production.bat

# Linux/Mac
chmod +x build-production.sh
./build-production.sh
```

## 🔥 Firebase Hosting (Recommended First Deploy)

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Initialize Firebase in your project**
   ```bash
   firebase init hosting
   ```
   - Select your Firebase project
   - Set public directory to: `build/web`
   - Configure as single-page app: `Yes`
   - Don't overwrite index.html: `No`

4. **Deploy**
   ```bash
   firebase deploy --only hosting
   ```

## ☁️ AWS S3 + CloudFront

1. **Configure AWS CLI**
   ```bash
   aws configure
   ```

2. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. **Deploy app**
   ```bash
   aws s3 sync build/web s3://your-bucket-name --delete
   ```

## ▲ Vercel

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Deploy**
   ```bash
   vercel --prod
   ```

## 🐳 Docker

1. **Build Docker image**
   ```bash
   docker build -t loyalty-card-app .
   ```

2. **Run locally**
   ```bash
   docker run -p 80:80 loyalty-card-app
   ```

3. **Deploy to cloud**
   - Google Cloud Run
   - AWS ECS/Fargate
   - Azure Container Instances

## 🔍 Verification

After deployment, verify your app:

1. **Check app loads correctly**
2. **Test user authentication**
3. **Verify API connectivity**
4. **Test barcode scanning (requires HTTPS)**
5. **Check responsive design**

## 🚨 Common Issues

### Build Fails
- Run `flutter doctor` and fix any issues
- Ensure all environment variables are set
- Check for any compilation errors

### Firebase Deploy Fails
- Verify Firebase CLI is logged in
- Check project permissions
- Ensure firebase.json is configured correctly

### API Connection Issues
- Verify API URL is correct and accessible
- Check CORS configuration on your backend
- Ensure SSL certificates are valid (for HTTPS)

### Barcode Scanner Not Working
- Barcode scanning requires HTTPS in production
- Ensure camera permissions are properly configured
- Check if the deployed URL supports camera access

## 📊 Post-Deployment

1. **Set up monitoring**
   - Google Analytics
   - Firebase Performance Monitoring
   - Error tracking (Sentry)

2. **Configure custom domain** (if needed)
3. **Set up CI/CD pipeline** using GitHub Actions
4. **Monitor application performance**

## 🆘 Need Help?

- Check the detailed [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- Review deployment logs for specific errors
- Test locally before deploying: `flutter run -d chrome`

---

**Ready to deploy? Run the deployment script for your chosen platform! 🚀**
