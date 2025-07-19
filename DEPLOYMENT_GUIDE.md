# CardKeep - Cloud Deployment Guide

## 🚀 Deployment Options

CardKeep can be deployed to multiple cloud platforms. Choose the one that best fits your needs:

### 1. 🔥 Firebase Hosting (Recommended for simplicity)

**Pros:** 
- Easy setup and deployment
- Free tier available
- Automatic SSL certificates
- Global CDN
- Integration with Firebase services

**Steps:**
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`
3. Initialize project: `firebase init hosting`
4. Run deployment script: `./deploy.sh` (or `deploy.bat` on Windows)
5. Select "firebase" as deployment target

**Cost:** Free tier: 125GB storage, 10GB/month bandwidth

---

### 2. ☁️ AWS S3 + CloudFront (Best for scalability)

**Pros:**
- Highly scalable
- Global CDN with CloudFront
- Fine-grained control
- Pay-as-you-use

**Prerequisites:**
- AWS CLI installed and configured
- Terraform installed
- AWS account with appropriate permissions

**Steps:**
1. Configure AWS credentials: `aws configure`
2. Run deployment script: `./deploy.sh` (or `deploy.bat` on Windows)
3. Select "aws" as deployment target
4. Terraform will create S3 bucket and CloudFront distribution

**Cost:** ~$1-5/month for small to medium traffic

---

### 3. ▲ Vercel (Great for rapid deployment)

**Pros:**
- Zero-config deployment
- Automatic deployments from Git
- Free tier available
- Great developer experience

**Steps:**
1. Install Vercel CLI: `npm install -g vercel`
2. Run deployment script: `./deploy.sh` (or `deploy.bat` on Windows)
3. Select "vercel" as deployment target

**Cost:** Free tier available, $20/month for Pro

---

### 4. 🐳 Docker (For containerized deployment)

**Pros:**
- Consistent environment
- Can deploy to any platform supporting Docker
- Easy local development

**Steps:**
1. Install Docker
2. Run deployment script: `./deploy.sh` (or `deploy.bat` on Windows)
3. Select "docker" as deployment target
4. Container will run on `http://localhost`

**For production Docker deployment, consider:**
- Google Cloud Run
- AWS ECS/Fargate
- Azure Container Instances
- DigitalOcean App Platform

---

## 🔧 Environment Configuration

### Firebase Configuration
Before deploying, update your Firebase configuration in the app:

1. Go to Firebase Console → Project Settings
2. Add a new web app
3. Copy the configuration
4. Update `lib/services/firebase_service.dart` with your config

### API Configuration
Update the API base URL for production:

1. Create environment-specific config files
2. Update `lib/services/api_service.dart`
3. Set your production API endpoint

### Security Considerations

1. **API Keys**: Store sensitive keys in environment variables
2. **CORS**: Configure your backend API to allow requests from your domain
3. **Firebase Security Rules**: Set up proper security rules for Firebase
4. **Content Security Policy**: Configure CSP headers in nginx.conf

---

## 📊 Performance Optimizations

The deployment includes several optimizations:

- **Gzip compression** for smaller file sizes
- **Cache headers** for static assets
- **CDN distribution** for global performance
- **Image optimization** recommendations

---

## 🔍 Monitoring and Analytics

Consider adding:

- Google Analytics for user tracking
- Firebase Performance Monitoring
- Error tracking (Sentry, Bugsnag)
- Uptime monitoring (UptimeRobot, Pingdom)

---

## 🚀 Quick Start

1. **Choose your platform** (Firebase recommended for beginners)
2. **Run the deployment script**: `./deploy.sh` (Linux/Mac) or `deploy.bat` (Windows)
3. **Follow the prompts** to select your deployment target
4. **Access your deployed app** at the provided URL

---

## 📝 CI/CD Setup

The included GitHub Actions workflow (`.github/workflows/deploy.yml`) provides:

- Automated testing
- Build verification
- Deployment to Firebase Hosting
- Can be modified for other platforms

To use it:
1. Add your Firebase service account key to GitHub Secrets
2. Update the project ID in the workflow file
3. Push to main/master branch to trigger deployment

---

## 🆘 Troubleshooting

### Common Issues:

1. **Build fails**: Run `flutter doctor` and fix any issues
2. **Firebase deployment fails**: Check project permissions and CLI auth
3. **AWS deployment fails**: Verify AWS credentials and Terraform setup
4. **Docker build fails**: Check Dockerfile and dependencies

### Getting Help:
- Check the deployment logs
- Verify all prerequisites are installed
- Ensure Firebase/AWS/Vercel accounts are properly configured

---

## 📈 Scaling Considerations

As your app grows, consider:

1. **CDN optimization** for global users
2. **Database scaling** for your backend
3. **Load balancing** for high traffic
4. **Monitoring and alerting** for uptime
5. **Backup strategies** for data protection

---

Your CardKeep app is now ready for cloud deployment! 🎉
