FROM ubuntu:22.04

# Install system packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git python3 python3-pip curl unzip wget \
    build-essential ninja-build meson pkg-config protobuf-compiler \
    libprotobuf-dev libboost-all-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone lc0 and build (CPU only)
RUN git clone --recurse-submodules --branch v0.32.0-rc1 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && ./autogen.sh && \
    meson build --buildtype release -Dcuda=false && \
    ninja -C build && \
    cp build/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy your Flask app
COPY app.py /app/app.py

# Install Python dependencies
RUN pip3 install flask

CMD ["python3", "app.py"]
