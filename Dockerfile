FROM ubuntu:22.04

# Install base dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget curl unzip git python3 python3-pip cmake build-essential \
    protobuf-compiler libprotobuf-dev libprotoc-dev \
    libboost-all-dev libeigen3-dev zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and build lc0 (CPU-only)
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && \
    make -j$(nproc) && \
    cp lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest network weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Add your Python server code
COPY app.py /app/app.py
RUN pip3 install flask

# Expose port (optional)
EXPOSE 5000

# Run the Flask app
CMD ["python3", "app.py"]
