# Dockerfile v0.38 - CUDA build attempt via Meson
# ------------------------------------------------
# CHANGELOG:
# - Base image upgraded to `nvidia/cuda:12.2.0-devel-ubuntu22.04` (includes nvcc)
# - Switched to Meson build system per upstream README
# - Added g++-9 to satisfy CUDA compiler requirements
# - Build target: lc0 with CUDA support via meson backend
# - Includes REST API via Flask
#
# To fallback to CPU-only: set `-Dcuda=false` and rebuild

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip git curl wget ninja-build \
    g++-9 gcc-9 build-essential \
    meson libopenblas-dev zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Clone lc0 with submodules (v0.32.0-rc1)
RUN git clone --recurse-submodules --branch v0.32.0-rc1 https://github.com/LeelaChessZero/lc0.git

# Build with meson + CUDA
RUN cd lc0 && \
    CC=gcc-9 CXX=g++-9 meson setup build --buildtype release -Dcuda=true -Dnvcc_ccbin=g++-9 && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download network weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Install Flask
RUN pip3 install flask

# Copy app.py
COPY app.py /app/app.py

# Expose port for REST API
EXPOSE 5000

# Run REST server
CMD ["python3", "app.py"]
