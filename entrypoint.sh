#!/bin/bash

# entrypoint.sh

set -e

# Debug: Check NVIDIA driver and CUDA version
echo "Checking NVIDIA environment..."
nvidia-smi || echo "nvidia-smi not available"
echo "CUDA Version check:"
nvcc --version || echo "nvcc not available"

# Expecting: ./entrypoint.sh input_video.mp4 output_video.mp4 -vcodec h264_nvenc ...
INPUT_FILE=$1
OUTPUT_FILE=$2
# All remaining arguments are passed to ffmpeg
shift 2
FFMPEG_ARGS=("$@")

# Define the mount points from the job creation step
INPUT_DIR="/inputs"
OUTPUT_DIR="/outputs"

echo "Running FFmpeg on mounted GCS volumes..."
echo "Input: ${INPUT_DIR}/${INPUT_FILE}"
echo "Output: ${OUTPUT_DIR}/${OUTPUT_FILE}"

# Execute ffmpeg using the local mount paths.
# FFmpeg reads from /inputs and writes directly to /outputs,
# and Cloud Run handles the sync with GCS automatically.
# -y allows to overwrite the target files, if they already exist
ffmpeg -y -c:v h264_cuvid -i "${INPUT_DIR}/${INPUT_FILE}" ${FFMPEG_ARGS[@]} -preset p7 "${OUTPUT_DIR}/${OUTPUT_FILE}"

FFMPEG_EXIT_CODE=$?
echo "FFmpeg finished with exit code ${FFMPEG_EXIT_CODE}."
exit $FFMPEG_EXIT_CODE
