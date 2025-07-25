# Dockerfile v0.32 - Lc0 REST server with CUDA support (Meson build)
# ---------------------------------------------------------------
# CHANGELOG:
# - v0.29: Initial Meson CPU build attempt
# - v0.30: Rebuilt with release/0.31 branch and proper cleanup
# - v0.31: Verified Meson requirement from README, added Meson & Ninja
# - v0.32: CUDA support re-enabled, confirmed CUDA deps, fallback logic possible

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Install build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git python3 python3-pip build-essential ninja-build meson \
    libz-dev libprotobuf-dev protobuf-compiler libboost-all-dev \
    libopenblas-dev wget curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone Lc0 with submodules (release branch)
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git

# Build with Meson (CUDA enabled)
RUN cd lc0 && \
    meson setup build --buildtype release -Dbackend=cuda && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Install Python deps
COPY app.py /app/app.py
RUN pip3 install flask

# Expose port (optional if used in local Docker bridge mode)
EXPOSE 5000

CMD ["python3", "app.py"]
