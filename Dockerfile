# v0.40 - CUDA + Meson build for lc0 REST server
# Notes:
# - Using Ubuntu 22.04 base
# - CUDA 12.2 with cudnn expected to be available in image (handled via base or host mount)
# - Meson build system used as per official README
# - Weights and app.py expected via bind mount or later COPY

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

LABEL version="0.40"
LABEL maintainer="GPT for Conor"
LABEL description="Lc0 REST server with CUDA using Meson build"

# Essential build tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ninja-build \
    meson \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    wget \
    curl \
    ca-certificates \
    unzip \
    zlib1g-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libboost-all-dev \
    libopenblas-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone Lc0 and build
RUN git clone --recurse-submodules --branch release/0.32 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    meson setup build --buildtype=release -Dgtest=false -Dcuda=true && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Flask REST interface (expected app.py present or mount later)
COPY app.py /app/app.py
RUN pip3 install flask

CMD ["python3", "/app/app.py"]
