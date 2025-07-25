FROM ubuntu:22.04

# Install base system deps
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget curl unzip ca-certificates \
    python3 python3-pip \
    git cmake build-essential \
    protobuf-compiler libprotobuf-dev libboost-all-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone lc0 source and build (CPU-only)
RUN git clone --recurse-submodules https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    git checkout tags/v0.30.0 && \
    mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && \
    make -j$(nproc) && \
    cp lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Install Python deps & copy server
COPY app.py /app/app.py
RUN pip3 install flask

CMD ["python3", "app.py"]
