# --------------------------------------------------------------------
# Lc0 REST Server — Dockerfile v0.33
# Build Strategy:
# - Targeting v0.32.0-rc1 using Meson
# - CUDA enabled (requires compatible GPU runtime)
# - Uses flask REST wrapper for /bestmove endpoint
# --------------------------------------------------------------------

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Install system dependencies and CUDA libs
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git python3 python3-pip curl wget unzip build-essential \
    ninja-build meson libprotobuf-dev protobuf-compiler \
    zlib1g-dev libopenblas-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone Lc0 v0.32.0-rc1 and build with Meson
RUN git clone --recurse-submodules --branch v0.32.0-rc1 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    meson setup build --buildtype release -Dcuda=true && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download default weights (can later mount via volume)
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy REST server
COPY app.py /app/app.py
RUN pip3 install flask

EXPOSE 5000
CMD ["python3", "app.py"]
