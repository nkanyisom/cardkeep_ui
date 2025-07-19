@echo off
REM Deployment script for CardKeep (Windows)

echo 🚀 Starting CardKeep deployment process...

REM Build the Flutter web app
echo 📦 Building Flutter web app...
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit

REM Check if build was successful
if not exist "build\web" (
    echo ❌ Build failed! build\web directory not found.
    exit /b 1
)

echo ✅ Flutter web app built successfully!

REM Choose deployment target
set /p DEPLOY_TARGET="Choose deployment target (firebase/aws/vercel/render/docker): "

if "%DEPLOY_TARGET%"=="firebase" (
    echo 🔥 Deploying to Firebase Hosting...
    
    REM Check if Firebase CLI is installed
    where firebase >nul 2>nul
    if %errorlevel% neq 0 (
        echo Installing Firebase CLI...
        npm install -g firebase-tools
    )
    
    REM Deploy to Firebase
    firebase deploy --only hosting
    echo ✅ Deployed to Firebase Hosting!
    
) else if "%DEPLOY_TARGET%"=="aws" (
    echo ☁️ Deploying to AWS S3 + CloudFront...
    
    REM Check if AWS CLI is installed
    where aws >nul 2>nul
    if %errorlevel% neq 0 (
        echo ❌ AWS CLI not found. Please install AWS CLI first.
        exit /b 1
    )
    
    REM Check if Terraform is installed
    where terraform >nul 2>nul
    if %errorlevel% neq 0 (
        echo ❌ Terraform not found. Please install Terraform first.
        exit /b 1
    )
    
    REM Deploy infrastructure with Terraform
    cd terraform
    terraform init
    terraform plan
    set /p APPLY="Apply Terraform configuration? (y/n): "
    if /i "%APPLY%"=="y" (
        terraform apply -auto-approve
        
        REM Get the S3 bucket name from Terraform output
        for /f %%i in ('terraform output -raw s3_bucket_name') do set BUCKET_NAME=%%i
        
        REM Upload files to S3
        cd ..
        aws s3 sync build\web s3://%BUCKET_NAME% --delete
        
        echo ✅ Deployed to AWS S3 + CloudFront!
    )
    
) else if "%DEPLOY_TARGET%"=="render" (
    echo ☁️ Deploying to Render...
    
    echo 📋 For Render deployment:
    echo 1. Push your code to Git repository
    echo 2. Go to https://render.com and create account
    echo 3. Create new Static Site
    echo 4. Use these settings:
    echo    - Build Command: chmod +x build.sh ^&^& ./build.sh
    echo    - Publish Directory: build/web
    echo 5. Set environment variables in Render dashboard
    echo.
    echo 📖 See RENDER_DEPLOYMENT.md for detailed instructions
    echo ✅ Ready for Render deployment!
    
) else if "%DEPLOY_TARGET%"=="vercel" (
    echo ▲ Deploying to Vercel...
    
    REM Check if Vercel CLI is installed
    where vercel >nul 2>nul
    if %errorlevel% neq 0 (
        echo Installing Vercel CLI...
        npm install -g vercel
    )
    
    REM Deploy to Vercel
    vercel --prod
    echo ✅ Deployed to Vercel!
    
) else if "%DEPLOY_TARGET%"=="docker" (
    echo 🐳 Building and running Docker container...
    
    REM Build Docker image
    docker build -t cardkeep-app .
    
    REM Stop existing container if running
    docker stop cardkeep-app-container 2>nul
    docker rm cardkeep-app-container 2>nul
    
    REM Run the container
    docker run -d --name cardkeep-app-container -p 80:80 cardkeep-app
    
    echo ✅ Docker container is running on http://localhost
    
) else (
    echo ❌ Invalid deployment target. Choose from: firebase, aws, vercel, docker
    exit /b 1
)

echo 🎉 Deployment completed successfully!
pause
