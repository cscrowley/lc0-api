FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip git wget curl unzip build-essential \
    ninja-build meson libopenblas-dev zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create workdir
WORKDIR /app

# Clone Lc0 source and build
RUN git clone --recurse-submodules --branch release/0.32.0-rc1 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    meson setup build --buildtype=release && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy Python server
COPY app.py /app/app.py

# Install Flask
RUN pip3 install flask

# Start API
CMD ["python3", "app.py"]
