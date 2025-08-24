#!/bin/bash

# 01-build-container.sh

# Set your project ID
export PROJECT_ID="myproject"
export REGION="us-central1"

# Set the gcloud project
gcloud config set project $PROJECT_ID

# Enable necessary APIs
echo "Enabling required services..."
gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com

# Create Artifact Registry repository (optional, if using AR instead of GCR)
echo "Creating Artifact Registry repository..."
gcloud artifacts repositories create ffmpeg-nvidia \
    --repository-format=docker \
    --location=$REGION \
    --description="FFmpeg with NVIDIA support" || echo "Repository already exists."

# Submit the build to Artifact Registry
echo "Submitting build..."
gcloud builds submit --config=cloudbuild.yaml .

# Alternative: Build locally and push
# docker build -t gcr.io/$PROJECT_ID/ffmpeg-nvidia:latest .
# docker push gcr.io/$PROJECT_ID/ffmpeg-nvidia:latest

# podman build -t gcr.io/$PROJECT_ID/ffmpeg-nvidia:latest .
# podman push gcr.io/$PROJECT_ID/ffmpeg-nvidia:latest
