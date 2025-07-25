# Lc0 REST Docker Image
# Version: v0.35
# Status: Experimental - CUDA support enabled
# Changelog:
# - Switched to CUDA + Meson build after CMake fails with 0.31
# - Using v0.32.0-rc1 tag from Lc0 repo
# - Verified prerequisites: Python 3, Ninja, Meson, git, g++ >= 8, zlib1g-dev
# - Keeps app.py for remote REST play
# - Retains weights download; recommend cloud-mount for speed if frequent rebuilds

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# Install build tools and dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip git ninja-build meson \
    build-essential zlib1g-dev wget curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and build Lc0 from source using Meson backend (CUDA-enabled)
RUN git clone --recurse-submodules --branch v0.32.0-rc1 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    meson setup build --buildtype release && \
    meson compile -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download default weights (can be mounted for speed)
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Add REST server code
COPY app.py /app/app.py

# Install REST dependencies
RUN pip3 install flask

# Expose REST port
EXPOSE 5000

CMD ["python3", "app.py"]
