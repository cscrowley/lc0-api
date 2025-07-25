FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Install system packages (robust retry, no-recommends, clean-up)
RUN for i in 1 2 3 4 5; do apt-get update && break || sleep 5; done && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget python3 python3-pip curl unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Download and extract prebuilt Lc0 CUDA binary
RUN wget https://github.com/LeelaChessZero/lc0/releases/download/v0.30.0/lc0-v0.30.0-linux-cuda.tar.gz && \
    tar -xzf lc0-v0.30.0-linux-cuda.tar.gz && \
    mv lc0-v0.30.0-linux-cuda lc0 && \
    rm lc0-v0.30.0-linux-cuda.tar.gz

# Download latest weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Install Python deps
RUN pip3 install flask

# Copy app into image
COPY . /app

# Run server
CMD ["python3", "app.py"]
