FROM ubuntu:22.04

# Install base dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3 python3-pip ninja-build meson git cmake \
    build-essential libprotobuf-dev protobuf-compiler \
    libopenblas-dev zlib1g-dev wget curl unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and build lc0 with Meson (CPU only)
RUN git clone --recurse-submodules https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && \
    ./build.sh && \
    cp build/release/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download network weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Copy your REST API app
COPY app.py /app/app.py
RUN pip3 install flask

EXPOSE 5000
CMD ["python3", "app.py"]
