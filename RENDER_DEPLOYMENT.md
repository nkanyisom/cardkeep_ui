# 🚀 Deploy CardKeep to Render

## Quick Setup Guide

### Step 1: Prepare Your Repository
1. Ensure your CardKeep code is in a Git repository
2. Push to GitHub, GitLab, or Bitbucket
3. The build script (`build.sh`) is already included

### Step 2: Create Render Account
1. Go to [render.com](https://render.com)
2. Sign up for free account
3. Connect your Git provider

### Step 3: Create Static Site
1. Click **"New +"** → **"Static Site"**
2. Connect your CardKeep repository
3. Configure the deployment:

```
Name: cardkeep
Branch: main (or your default branch)
Build Command: chmod +x build.sh && ./build.sh
Publish Directory: build/web
```

### Step 4: Environment Variables
Add these environment variables in Render dashboard:

**Required:**
```
FLUTTER_APP_ENVIRONMENT=production
FLUTTER_APP_API_BASE_URL_PROD=https://your-api-domain.com/api
```

**Firebase Config:**
```
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef123456
```

### Step 5: Deploy
1. Click **"Create Static Site"**
2. Render will automatically build and deploy
3. Your app will be available at: `https://cardkeep.onrender.com`

## 🔧 Advanced Configuration

### Custom Domain
1. Go to your service settings
2. Add your custom domain
3. Update DNS records as instructed

### Build Optimizations
The build script includes:
- ✅ Flutter web optimization
- ✅ CanvasKit renderer for better performance
- ✅ Tree-shaking for smaller bundles
- ✅ Production environment variables

### Automatic Deployments
- ✅ Every push to main branch triggers deployment
- ✅ Preview deployments for pull requests
- ✅ Build logs and error tracking

## 💰 Pricing

**Free Tier:**
- ✅ 100GB bandwidth/month
- ✅ Custom domains
- ✅ Automatic SSL
- ✅ Global CDN

**Pro Tier ($7/month):**
- ✅ Unlimited bandwidth
- ✅ Advanced analytics
- ✅ Priority support

## 🚨 Troubleshooting

### Build Fails
- Check Flutter version compatibility
- Verify environment variables are set
- Review build logs in Render dashboard

### App Doesn't Load
- Ensure Firebase configuration is correct
- Check browser console for errors
- Verify API endpoints are accessible

### Performance Issues
- Monitor build size and optimize assets
- Consider using WebAssembly renderer
- Enable Render CDN caching

## 📊 Monitoring

Render provides:
- ✅ Real-time build logs
- ✅ Deployment history
- ✅ Performance metrics
- ✅ Error tracking

## 🔄 CI/CD Integration

For advanced workflows, integrate with:
- GitHub Actions
- GitLab CI/CD
- Bitbucket Pipelines

---

## 🎉 Your CardKeep app will be live at:
`https://cardkeep.onrender.com`

**Render is perfect for CardKeep because:**
- 🆓 **Free for small apps**
- ⚡ **Fast global CDN**
- 🔒 **Automatic HTTPS**
- 🔄 **Git-based deployments**
- 🎯 **Zero configuration needed**
