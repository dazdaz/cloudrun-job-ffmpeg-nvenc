# TODO

- Potential I/O Bottleneck
  Reading and writing directly to Google Cloud Storage using GCS FUSE is convenient but slower than using a local disk.
  Network latency and throughput for file operations can become the limiting factor, preventing the GPU from running at
  full speed because it's waiting for data.

- display megapixels per second

- try running ffmpeg as a Cloud Run service instead
