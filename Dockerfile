# Dockerfile v0.31
# -------------------------------------
# RELEASE NOTES:
# - Verified Meson is required (per README), not CMake.
# - Switched build system to Meson + Ninja.
# - CUDA disabled for now (can add later).
# - Includes Flask server to expose /bestmove API.
# - Current strategy: Build from source using Meson.
# - Logs indicate build system expectations were not met due to misconfigured env or missing deps.
# - Please keep updating this section every version!
# -------------------------------------

FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip \
    git wget curl unzip \
    build-essential \
    ninja-build \
    meson \
    zlib1g-dev \
    libprotobuf-dev protobuf-compiler \
    libopenblas-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone and build lc0 from source using Meson (CPU only for now)
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    meson setup build --buildtype release --reconfigure -Dcuda=false && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy app and install dependencies
COPY app.py /app/
RUN pip3 install flask

# Expose the REST endpoint
CMD ["python3", "app.py"]
