FROM ubuntu:22.04

# Install essential build and runtime dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    unzip \
    python3 \
    python3-pip \
    libboost-all-dev \
    protobuf-compiler \
    libprotobuf-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone Lc0 with submodules
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git

# Build Lc0 from source (CPU-only)
RUN cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && \
    make -j$(nproc) && \
    cp lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest network weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Install Python server dependencies
RUN pip3 install flask

# Copy in REST API server
COPY app.py /app/app.py

# Expose the port Flask will listen on
EXPOSE 5000

CMD ["python3", "app.py"]
