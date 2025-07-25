# ------------------------------------------------------------------------------
# Dockerfile for building lc0 with REST interface via Flask
# Version: v0.29
# Date: 2025-07-25
# ------------------------------------------------------------------------------
# Release Notes:
# - Switched to Meson + Ninja (per lc0 README recommendation).
# - CPU-only build (CUDA is not yet integrated).
# - Python layer retained for REST use case.
# - Removed CMake-based build path which previously failed.
# - Verified dependencies from lc0's README and previous failures.
# ------------------------------------------------------------------------------

FROM ubuntu:22.04

# System dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git python3 python3-pip ninja-build meson \
    build-essential libprotobuf-dev protobuf-compiler \
    zlib1g-dev libboost-all-dev wget curl unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /app

# Clone lc0 source with submodules
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git

# Build with Meson
WORKDIR /app/lc0
RUN meson setup build --buildtype=release && \
    meson compile -C build

# Move the binary and clean up
RUN cp build/lc0 /app/lc0 && cd /app && rm -rf lc0

# Download default network weights
WORKDIR /app
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy REST API server
COPY app.py /app/app.py
RUN pip3 install flask

# Start Flask server
CMD ["python3", "/app/app.py"]
