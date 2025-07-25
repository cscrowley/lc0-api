FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y wget unzip curl python3 python3-pip git

RUN mkdir /app && cd /app && \\
    wget https://github.com/LeelaChessZero/lc0/releases/download/v0.30.0/lc0-v0.30.0-linux-cuda.tar.gz && \\
    tar -xvzf lc0-v0.30.0-linux-cuda.tar.gz && \\
    mv lc0* lc0 && rm lc0-v0.30.0-linux-cuda.tar.gz

RUN cd /app && \\
    wget https://lczero.org/networks/current -O weights.pb.gz

RUN pip3 install flask

COPY app.py /app/app.py
WORKDIR /app

CMD ["python3", "app.py"]
EOF
