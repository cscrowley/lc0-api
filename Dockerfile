FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget curl unzip python3 python3-pip git cmake build-essential protobuf-compiler \
    libprotobuf-dev libboost-all-dev g++ && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone and build lc0 from source (CPU-only)
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && make -j$(nproc) && \
    cp lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Add REST server
COPY app.py /app/app.py
RUN pip3 install flask

CMD ["python3", "app.py"]
