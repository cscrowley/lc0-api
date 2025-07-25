FROM ubuntu:22.04

# Install all build dependencies and git early
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git cmake build-essential \
    protobuf-compiler libprotobuf-dev \
    libboost-all-dev \
    wget curl unzip python3 python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone and build lc0 (CPU-only)
RUN git clone --recurse-submodules https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && make -j$(nproc) && \
    cp lc0 /app/lc0 && cd /app && rm -rf lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy Python REST server and install deps
COPY app.py /app/app.py
RUN pip3 install flask

CMD ["python3", "app.py"]
