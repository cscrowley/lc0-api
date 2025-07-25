# =============================
# Lc0 Docker Build v0.35
# -----------------------------
# Base Image: ubuntu:22.04
# Lc0 Version: release/0.31 (from Git)
# Backend: CPU-only (no CUDA)
# Build System: CMake
# Status: ❌ FAIL
# Summary:
# - Attempted CPU-only build using CMake.
# - cmake .. -DUSE_CUDA=OFF failed due to missing/incorrect CMakeLists.txt (again).
# - This method is deprecated per upstream README.
# - Git or build dependencies may have been missing from path.
# -----------------------------
# Notes:
# - Consider switching to Meson build system per README guidance.
# - CUDA build may be more stable if prerequisites are satisfied.
# =============================

FROM ubuntu:22.04

# Install build tools and dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential cmake git wget curl unzip \
    python3 python3-pip \
    protobuf-compiler libprotobuf-dev libboost-all-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone lc0 source
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git

# Build lc0 (CPU-only)
RUN cd lc0 && \
    mkdir build && \
    cd build && \
    cmake .. -DUSE_CUDA=OFF && \
    make -j$(nproc) && \
    cp lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download default weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy app.py server
COPY app.py /app/app.py

# Install Python deps
RUN pip3 install flask

CMD ["python3", "app.py"]
