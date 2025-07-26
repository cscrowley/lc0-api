# Stage 1: Builder - Compiles the lc0 binary
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04 AS builder

# Install lc0 build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    git \
    ninja-build \
    meson \
    python3 \
    wget \
    unzip \
    zlib1g-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libboost-all-dev \
    libopenblas-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone Lc0 from a recent stable release and build it
RUN git clone --recurse-submodules --branch v0.31.0 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    meson setup build --buildtype=release -Dgtest=false -Dcuda=true && \
    ninja -C build

# Stage 2: Runtime - Creates the final image based on RunPod's base
FROM runpod/base:0.6.1-cuda12.2.0

WORKDIR /app

# Copy the compiled lc0 binary from the builder stage
COPY --from=builder /build/lc0/build/lc0 /app/lc0

# Download the neural network weights
RUN wget https://lczero.org/networks/current -O /app/weights.pb.gz

# Install Python dependencies
COPY requirements.txt /requirements.txt
RUN python3.10 -m pip install --upgrade pip && \
    python3.10 -m pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

# Copy the application file
COPY app.py /app/app.py

# Set the command to run the Flask app
CMD ["python3.10", "-u", "/app/app.py"]