FROM ubuntu:22.04

RUN for i in 1 2 3 4 5; do apt-get update && break || sleep 5; done && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget curl unzip python3 python3-pip git cmake build-essential \
    protobuf-compiler libprotobuf-dev libboost-all-dev \
    libeigen3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and build lc0 from source (CPU-only)
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && make -j$(nproc) && \
    cp lc0 /app/lc0 && cd /app && rm -rf lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

COPY app.py /app/app.py
RUN pip3 install flask

CMD ["python3", "app.py"]
