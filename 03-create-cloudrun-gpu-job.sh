#!/bin/bash

# 03-create-cloudrun-gpu-job.sh

# Set your project ID and region
export PROJECT_ID="myplayground"
export REGION="us-central1"
IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/ffmpeg-nvidia/ffmpeg-nvidia-nvenc:latest"
# You must specify your project's number here
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')
# This is the default service account Cloud Run jobs use
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Our 2 GCS Buckets are -
# gs://transcode-preprocessing-bucket
# gs://transcode-postprocessing-bucket

echo "Deploying image: $IMAGE_PATH"

gcloud beta run jobs create ffmpeg-job \
    --image=$IMAGE_PATH \
    --region=$REGION \
    --memory=32Gi \
    --cpu=8 \
    --gpu=1 \
    --gpu-type=nvidia-l4 \
    --no-gpu-zonal-redundancy \
    --max-retries=1 \
    --service-account=$SERVICE_ACCOUNT \
    --set-env-vars "TZ=Europe/Zurich" \
    --add-volume=name=input-volume,type=cloud-storage,bucket=transcode-preprocessing-bucket,readonly=true \
    --add-volume-mount=volume=input-volume,mount-path=/inputs \
    --add-volume=name=output-volume,type=cloud-storage,bucket=transcode-postprocessing-bucket \
    --add-volume-mount=volume=output-volume,mount-path=/outputs
