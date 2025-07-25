# v0.39 - CUDA + Meson build, REST-enabled
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

LABEL version="0.39" description="Builds lc0 v0.32.0-rc1 with CUDA via Meson, includes Flask REST server"

# Install build dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git python3 python3-pip curl wget unzip ninja-build \
    meson build-essential libprotobuf-dev protobuf-compiler \
    libopenblas-dev zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Clone Lc0 (v0.32.0-rc1) with submodules
RUN git clone --recurse-submodules https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && git checkout v0.32.0-rc1 && git submodule update --init --recursive

# Build with Meson
RUN cd /app/lc0 && \
    meson setup build --buildtype release && \
    ninja -C build && \
    cp build/lc0 /app/lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O /app/weights.pb.gz

# Copy REST server
COPY app.py /app/app.py

# Install Flask
RUN pip3 install flask

# Expose REST port
EXPOSE 5000

# Run REST server
CMD ["python3", "app.py"]
