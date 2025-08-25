# GPU-Accelerated Video Transcoding with FFmpeg on Google Cloud Run Jobs 🚀

This project provides a complete, optimized solution for running GPU-accelerated video transcoding jobs using
**FFmpeg** with **NVIDIA NVENC** on **Google Cloud Run Jobs**.

The use case is for low-priority offline transcoding of a batch of videos upto 8Gib in size to their new format via a Cloud Run batch job.

The entire workflow is automated with shell scripts, from building the container image with Cloud Build to creating and executing the transcoding job. It leverages **Cloud Storage FUSE** for seamless file access, eliminating the need for manual downloads and uploads.

I originally read one video .mp4 file from a GCS bucket, transcoded the file and then wrote to the GCS bucket which made transcoding I/O bound and
resulted in ~30 megapixel/s.

After re-archictecting this, we now read the file from a GCS bucket, transcode in memory and write the output file to the target GCS bucket.
We're now achieving ~100-300 megapixel/s resulting in 0.59 seconds to transcode our test file. Your mileage may vary ...

You may want to modify this code to encode a large batch of files, each time that a Cloud Run job instance is deployed.


---
## ## Features

- **Hardware-Accelerated Transcoding**: Uses NVIDIA L4 GPUs on Cloud Run for both video decoding (`h264_cuvid`) and encoding (`h264_nvenc`).
- **Serverless & Scalable**: Leverages Cloud Run Jobs to run transcoding tasks without managing servers.
- **Seamless GCS Integration**: Mounts Google Cloud Storage buckets directly into the container as volumes for easy file access.
- **Optimized Performance**:
  - Uses fast encoder presets (`-preset p7`) for maximum throughput.
  - Enables Cloud Run's Startup CPU Boost for faster initialization.
  - Includes the `-movflags +faststart` flag for web-optimized MP4 output.
- **Automated Workflow**: Shell scripts are provided to automate the entire process from build to execution.

---
## ## How to Use

### ### Prerequisites

1.  A Google Cloud Project with billing enabled.
2.  The `gcloud` command-line tool installed and authenticated.
3.  Two Google Cloud Storage buckets: one for input videos and one for output videos.

### ### 1. Configure Your Environment

Before running the scripts, you need to update the placeholder values.

-   In `01-build-container.sh`, `02-iam-roles.sh`, and `03-create-cloudrun-gpu-job.sh`, set your `PROJECT_ID` and `REGION`.
-   In `03-create-cloudrun-gpu-job.sh`, update the bucket names in the `--mount-gcs-volume` flags.
    -   `bucket=transcode-preprocessing-bucket`
    -   `bucket=transcode-postprocessing-bucket`
-   In `02-iam-roles.sh`, update the bucket names in the `gcloud storage buckets add-iam-policy-binding` commands.

### ### 2. Build the Container Image

This script builds the custom FFmpeg container using Cloud Build and pushes it to your project's Artifact Registry.

```bash
./01-build-container.sh
```

### ### 3. Set IAM Permissions

This script grants the default Compute Engine service account (used by Cloud Run Jobs) the necessary permissions to read from and write to your GCS buckets.

```bash
./02-iam-roles.sh
```

### ### 4. Create the Cloud Run Job

This script creates the Cloud Run Job definition, specifying the GPU type, CPU, memory, and mounting the GCS buckets as volumes.

```bash
./03-create-cloudrun-gpu-job.sh
```

### ### 5. Execute a Transcoding Task

Upload a video (e.g., `elephant_video.mp4`) to your input bucket. Then, run the execution script, passing the input filename, output filename, and any additional FFmpeg flags.

```bash
./04-execute-cloudrun-job-transcode.sh
```

The script will wait for the job to complete and you'll find the transcoded file in your output bucket.

---
## ## Scripts Overview

- **`01-build-container.sh`**: Builds the Docker image via Cloud Build.
- **`02-iam-roles.sh`**: Configures the necessary IAM permissions for the Cloud Run job's service account to access the GCS buckets.
- **`03-create-cloudrun-gpu-job.sh`**: Creates the `ffmpeg-job` on Cloud Run with all the required hardware and volume mount settings.
- **`04-execute-job.sh`**: Triggers an execution of the `ffmpeg-job` with specific video files and transcoding parameters.
- **`cloudbuild.yaml`**: The build configuration file for Cloud Build.
- **`Dockerfile`**: Defines the container, compiling FFmpeg from source with NVIDIA CUDA support.
- **`entrypoint.sh`**: The script that runs inside the container, constructing and executing the final `ffmpeg` command using the mounted volume paths.

---
## ## Dockerfile Breakdown

The `Dockerfile` uses a multi-stage build to keep the final image lean:

1.  **Builder Stage**: Starts from an `nvidia/cuda:12.1.0-devel` image, installs build tools, and compiles FFmpeg from source with a specific version of `nv-codec-headers` to ensure driver compatibility with the Cloud Run environment.
2.  **Runtime Stage**: Starts from a smaller `nvidia/cuda:12.1.0-runtime` image, copies the compiled FFmpeg binaries from the builder stage, and sets up the `entrypoint.sh` script.

---
## ## Key Optimizations Implemented

- **Hardware Decoding (`-c:v h264_cuvid`)**: Offloads the video decoding process to the GPU, freeing up the CPU.
- **Fast Encoder Preset (`-preset p7`)**: Configures the NVIDIA encoder to prioritize speed over quality, ideal for high-throughput batch processing.
- **GCS Volume Mounting**: Eliminates network latency from manual file transfers by treating GCS buckets as local filesystems.

----

### Additional Notes

This is not designed to be a lean container image (4Gib) but to show how this works as a proof of concept.


### Disclaimer

Use this software at your own risk, any timings may change.
