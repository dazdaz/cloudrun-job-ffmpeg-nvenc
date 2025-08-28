# TODO

- check input .mp4 filesize

- ARGV

- make container image more lean

- Does not chunk or stream videos as this is intended for a low priority batch process and files are less than 8 Gib in size however these
  approaches would need to be explored if we were to transcode larger files as well as transcoding from/to block storage

- designed to run on NVIDIA Tesla T4 GPU, which has 1 x NVENC, make this clearer and explore utilizing other GPU's which provide >2 NVENC
  Number of NVENC chips are listed here https://developer.nvidia.com/video-encode-and-decode-gpu-support-matrix-new

- explore running ffmpeg as a Cloud Run service, for more realtime batch transcoding, which is a different use case, project fork
