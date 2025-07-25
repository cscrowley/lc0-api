FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git wget curl unzip python3 python3-pip build-essential cmake \
    ninja-build meson libprotobuf-dev protobuf-compiler \
    libboost-all-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone Lc0
RUN git clone --recurse-submodules --branch release/0.32 https://github.com/LeelaChessZero/lc0.git

# Build (CPU only, disable TensorFlow and CUDA)
RUN cd lc0 && \
    meson setup build --buildtype=release -Duse_tensorflow=false -Dcuda=false && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy app and install Python dependencies
COPY app.py /app/app.py
RUN pip3 install flask

CMD ["python3", "app.py"]
