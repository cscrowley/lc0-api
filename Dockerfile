FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Install system packages
RUN apt-get update && apt-get install -y wget unzip curl python3 python3-pip git

# Set up working dir and install Lc0
RUN mkdir /app && cd /app && wget https://github.com/LeelaChessZero/lc0/releases/download/v0.30.0/lc0-v0.30.0-linux-cuda.tar.gz && tar -xvzf lc0-v0.30.0-linux-cuda.tar.gz && mv lc0* lc0 && rm lc0-v0.30.0-linux-cuda.tar.gz

# Download current Lc0 network weights
RUN cd /app && wget https://lczero.org/networks/current -O weights.pb.gz

# Install Python deps
RUN pip3 install flask

# Copy app and set workdir
COPY app.py /app/app.py
WORKDIR /app

# Run the server
CMD ["python3", "app.py"]
