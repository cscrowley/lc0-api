# Dockerfile for Lc0 REST server - v0.34
# ------------------------------------------------------------
# RELEASE NOTES:
# v0.29 - Initial Docker builds started.
# v0.30 - CMake builds with CPU-only failed.
# v0.31 - Multiple retry with explicit dependencies.
# v0.32 - Switched to Meson as recommended by README.
# v0.33 - Added CUDA via -Dcuda=true (still failed).
# v0.34 - Adds cuDNN, zlib, ensures all Meson prereqs, and tags version correctly.
# ------------------------------------------------------------

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Install system dependencies and Meson prerequisites
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git wget curl unzip python3 python3-pip \
    ninja-build meson build-essential \
    zlib1g-dev libprotobuf-dev protobuf-compiler \
    libopenblas-dev libcudnn8 libcudnn8-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and build lc0 with CUDA using Meson
RUN git clone --recurse-submodules https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    meson setup build --buildtype=release -Dcuda=true && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest neural network weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy REST API and install Flask
COPY app.py /app/app.py
RUN pip3 install flask

# Launch REST API
CMD ["python3", "app.py"]
