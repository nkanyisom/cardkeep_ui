#!/bin/bash

# Deployment script for CardKeep

set -e  # Exit on any error

echo "🚀 Starting CardKeep deployment process..."

# Build the Flutter web app
echo "📦 Building Flutter web app..."
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Build failed! build/web directory not found."
    exit 1
fi

echo "✅ Flutter web app built successfully!"

# Choose deployment target
read -p "Choose deployment target (firebase/aws/vercel/render/docker): " DEPLOY_TARGET

case $DEPLOY_TARGET in
    firebase)
        echo "🔥 Deploying to Firebase Hosting..."
        
        # Check if Firebase CLI is installed
        if ! command -v firebase &> /dev/null; then
            echo "Installing Firebase CLI..."
            npm install -g firebase-tools
        fi
        
        # Initialize Firebase if not already done
        if [ ! -f "firebase.json" ]; then
            echo "Initializing Firebase..."
            firebase init hosting
        fi
        
        # Deploy to Firebase
        firebase deploy --only hosting
        echo "✅ Deployed to Firebase Hosting!"
        ;;
        
    aws)
        echo "☁️ Deploying to AWS S3 + CloudFront..."
        
        # Check if AWS CLI is installed
        if ! command -v aws &> /dev/null; then
            echo "❌ AWS CLI not found. Please install AWS CLI first."
            exit 1
        fi
        
        # Check if Terraform is installed
        if ! command -v terraform &> /dev/null; then
            echo "❌ Terraform not found. Please install Terraform first."
            exit 1
        fi
        
        # Deploy infrastructure with Terraform
        cd terraform
        terraform init
        terraform plan
        read -p "Apply Terraform configuration? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            terraform apply -auto-approve
            
            # Get the S3 bucket name from Terraform output
            BUCKET_NAME=$(terraform output -raw s3_bucket_name)
            
            # Upload files to S3
            cd ..
            aws s3 sync build/web s3://$BUCKET_NAME --delete
            
            # Get CloudFront distribution ID
            DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[0].DomainName=='$BUCKET_NAME.s3.amazonaws.com'].Id" --output text)
            
            # Create CloudFront invalidation
            if [ ! -z "$DISTRIBUTION_ID" ]; then
                aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
            fi
            
            echo "✅ Deployed to AWS S3 + CloudFront!"
        fi
        ;;
        
    render)
        echo "☁️ Deploying to Render..."
        
        echo "📋 For Render deployment:"
        echo "1. Push your code to Git repository"
        echo "2. Go to https://render.com and create account"
        echo "3. Create new Static Site"
        echo "4. Use these settings:"
        echo "   - Build Command: chmod +x build.sh && ./build.sh"
        echo "   - Publish Directory: build/web"
        echo "5. Set environment variables in Render dashboard"
        echo ""
        echo "📖 See RENDER_DEPLOYMENT.md for detailed instructions"
        echo "✅ Ready for Render deployment!"
        ;;
        
    vercel)
        echo "▲ Deploying to Vercel..."
        
        # Check if Vercel CLI is installed
        if ! command -v vercel &> /dev/null; then
            echo "Installing Vercel CLI..."
            npm install -g vercel
        fi
        
        # Deploy to Vercel
        vercel --prod
        echo "✅ Deployed to Vercel!"
        ;;
        
    docker)
        echo "🐳 Building and running Docker container..."
        
        # Build Docker image
        docker build -t cardkeep-app .
        
        # Stop existing container if running
        docker stop cardkeep-app-container 2>/dev/null || true
        docker rm cardkeep-app-container 2>/dev/null || true
        
        # Run the container
        docker run -d --name cardkeep-app-container -p 80:80 cardkeep-app
        
        echo "✅ Docker container is running on http://localhost"
        ;;
        
    *)
        echo "❌ Invalid deployment target. Choose from: firebase, aws, vercel, render, docker"
        exit 1
        ;;
esac

echo "🎉 Deployment completed successfully!"
