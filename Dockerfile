FROM ubuntu:22.04

# Install build tools and Python deps
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget curl unzip python3 python3-pip \
    git cmake build-essential \
    protobuf-compiler libprotobuf-dev libboost-all-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Retry git clone for network reliability
RUN for i in 1 2 3 4 5; do \
    git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && break || sleep 5; \
done && \
    cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && make -j$(nproc) && \
    cp lc0 /app/lc0 && cd /app && rm -rf lc0

# Download weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Add your app
COPY app.py /app/app.py

# Install Flask
RUN pip3 install flask

CMD ["python3", "app.py"]
