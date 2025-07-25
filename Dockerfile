FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git cmake build-essential protobuf-compiler libprotobuf-dev libboost-all-dev \
    wget curl unzip python3 python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working dir
WORKDIR /app

# Clone and build lc0 from source (CPU-only)
RUN git clone --recurse-submodules --branch v0.32.0-rc1 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && make -j$(nproc) && \
    cp lc0 /app/lc0 && cd /app && rm -rf lc0

# Download weights (optional — could mount separately)
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Add Flask API
COPY app.py /app/app.py
RUN pip3 install flask

# Start server
CMD ["python3", "app.py"]
