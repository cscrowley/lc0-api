FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system packages, including git this time (you’re welcome)
RUN for i in 1 2 3 4 5; do apt-get update && break || sleep 5; done && \
    apt-get install -y --no-install-recommends \
    wget curl unzip git python3 python3-pip \
    cmake g++ protobuf-compiler libprotobuf-dev libboost-all-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and build lc0 (CPU-only)
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && make -j$(nproc) && \
    cp lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy your app code into image
COPY app.py /app/

# Install Python dependencies
RUN pip3 install --no-cache-dir flask

# Run your server
CMD ["python3", "app.py"]
