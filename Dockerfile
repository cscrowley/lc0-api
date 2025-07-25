# Version: v0.29
# Summary:
# - Builds Lc0 from source using Meson (not CMake, which failed repeatedly)
# - CPU-only build (no CUDA required)
# - Uses official Meson build instructions from Lc0 README
# - Includes Flask REST server (your app.py)
# - Designed for remote chess clients
# - Git and submodules required (included)
# - Leverages ninja for speed

FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip git wget curl unzip ninja-build meson \
    build-essential zlib1g-dev libprotobuf-dev protobuf-compiler \
    libopenblas-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone lc0 repo (v0.32.0-rc1 is most recent stable-ish release)
RUN git clone --recurse-submodules --branch release/0.32 https://github.com/LeelaChessZero/lc0.git

# Build with Meson (CPU only, no CUDA)
RUN cd lc0 && meson setup build --buildtype release --prefix /usr/local && \
    meson compile -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy your app and install Flask
COPY app.py /app/app.py
RUN pip3 install flask

EXPOSE 5000
CMD ["python3", "app.py"]

# == RELEASE NOTES ==
# v0.29:
# - Switched to Meson (as CMake fails to find valid config)
# - Targeting CPU-only build
# - Integrated REST Flask API
# - Build confirmed with git submodules
# - Prepared for future CUDA toggle
