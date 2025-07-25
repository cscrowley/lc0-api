FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git wget curl unzip python3 python3-pip \
    cmake build-essential \
    protobuf-compiler libprotobuf-dev libboost-all-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Confirm git is installed and usable
RUN git --version

WORKDIR /app

# Clone and build lc0 (CPU-only, no CUDA)
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF && make -j$(nproc) && \
    cp lc0 /app/lc0 && cd /app && rm -rf lc0

# Download latest weights file
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy server application
COPY app.py /app/app.py

# Install Python dependencies
RUN pip3 install flask

# Start the Flask app
CMD ["python3", "app.py"]
