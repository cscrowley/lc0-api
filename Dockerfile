FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Install system packages
RUN apt-get update && \
    apt-get install -y wget python3 python3-pip curl unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Download prebuilt lc0 CUDA binary
RUN wget https://github.com/LeelaChessZero/lc0/releases/download/v0.30.0/lc0-v0.30.0-linux-cuda.tar.gz && \
    tar -xzf lc0-v0.30.0-linux-cuda.tar.gz && \
    mv lc0-v0.30.0-linux-cuda lc0 && \
    rm lc0-v0.30.0-linux-cuda.tar.gz

# Download latest network weights
RUN wget https://lczero.org/networks/current -O weights.pb.gz

# Install Python dependencies
RUN pip3 install flask

# Copy local app files (should include app.py)
COPY . /app

# Launch server
CMD ["python3", "app.py"]
