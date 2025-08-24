#!/bin/bash

# 02-iam-roles.sh

# Set your project ID and region
export PROJECT_ID="myproject"
export REGION="us-central1"
IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/ffmpeg-nvidia/ffmpeg-nvidia-nvenc:latest"
# You must specify your project's number here
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')
# This is the default service account Cloud Run jobs use
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Grant permissions to the preprocessing bucket
gcloud storage buckets add-iam-policy-binding gs://transcode-preprocessing-bucket \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/storage.objectAdmin"

gcloud storage buckets add-iam-policy-binding gs://transcode-preprocessing-bucket \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/storage.objectViewer"

# Grant permissions to the postprocessing bucket
gcloud storage buckets add-iam-policy-binding gs://transcode-postprocessing-bucket \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/storage.objectAdmin"

gcloud storage buckets add-iam-policy-binding gs://transcode-postprocessing-bucket \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/storage.objectViewer"
