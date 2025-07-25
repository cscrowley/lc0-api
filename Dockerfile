FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git cmake build-essential curl unzip wget python3 python3-pip \
    libprotobuf-dev protobuf-compiler && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working dir
WORKDIR /app

# Clone v0.32.0-rc1 with submodules
RUN git clone --recurse-submodules --branch v0.32.0-rc1 https://github.com/LeelaChessZero/lc0.git

# Build with vcpkg (built-in)
RUN cd lc0 && \
    mkdir build && cd build && \
    cmake .. -DUSE_CUDA=OFF -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# Copy lc0 binary up one level
RUN cp lc0/build/lc0 /app/lc0

# Download network weights
RUN wget https://lczero.org/networks/current -O /app/weights.pb.gz

# Add your REST app
COPY app.py /app/app.py
RUN pip3 install flask

# Run app
CMD ["python3", "/app/app.py"]
