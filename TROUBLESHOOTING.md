# Troubleshooting
```bash
gcloud logging read "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"ffmpeg-nvidia-service\"" --limit 1000 --format="table(timestamp,logName,textPayload)"

gcloud beta run jobs executions list \
>     --job=ffmpeg-job \
>     --region=us-central1

   JOB         EXECUTION         REGION       RUNNING  COMPLETE  CREATED                  RUN BY
�  ffmpeg-job  ffmpeg-job-q5646  us-central1  0        0 / 1     2025-08-24 11:03:26 UTC  daev@daev.altostrat.com

gcloud logging read "resource.type=\"cloud_run_job\" \
   resource.labels.job_name=\"ffmpeg-job\" \
   resource.labels.execution_name=\"[EXECUTION_ID]\"" \
   --project=daev-playground \
   --format json

gcloud run jobs executions list --region us-central1
gcloud run jobs executions describe ffmpeg-job-q5646 --region us-central1

# Run container image locally
gcloud auth configure-docker us-central1-docker.pkg.dev
# Run our x86_64 image on Arm
podman run --rm us-central1-docker.pkg.dev/daev-playground/ffmpeg-nvidia/ffmpeg-nvidia-nvenc:latest ffmpeg -buildconf
```
