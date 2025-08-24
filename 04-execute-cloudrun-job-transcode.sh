#!/bin/bash

# 05-execute-job.sh

# Pass the file names only, not the full gs:// paths.
# The entrypoint script will construct the full path using the known mount points (/inputs and /outputs).

# -movflags - prevent the GCS FUSE error by telling FFmpeg to write its metadata at the end of the file, prevents GCS Fuse Write Errors

REGION="us-central1"

gcloud run jobs execute ffmpeg-job \
    --region=$REGION \
    --wait \
    --args="elephant_video.mp4,elephant_video_encoded.mp4,-vcodec,h264_nvenc,-cq,21,-movflags,+faststart"
