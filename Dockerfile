# lc0-docker v0.32 (CUDA backend build)
# CHANGELOG:
# - Bumped to v0.32 (CUDA)
# - Using meson instead of cmake per README recommendations
# - CUDA support required. Ensure compatible compiler or set nvcc_ccbin
# - Built-in REST server supported via app.py

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Install base system deps
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip git build-essential ninja-build meson \
    wget curl unzip zlib1g-dev libopenblas-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone Lc0 (CUDA capable)
RUN git clone --recurse-submodules --branch v0.32.0-rc1 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    meson setup build --buildtype=release && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download network weights (optional to override at runtime)
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy server app and install deps
COPY app.py /app/app.py
RUN pip3 install flask

CMD ["python3", "app.py"]
