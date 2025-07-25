FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git python3 python3-pip ninja-build meson \
    build-essential g++ zlib1g-dev libopenblas-dev \
    wget curl unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone and build lc0 with Meson
RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && \
    cd lc0 && ./build.sh && \
    cp build/release/lc0 /app/lc0 && \
    cd /app && rm -rf lc0

# Download weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Install Flask and copy app
COPY app.py /app/app.py
RUN pip3 install flask

CMD ["python3", "app.py"]
