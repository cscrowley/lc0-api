FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

RUN apt-get update || true && apt-get -o Acquire::Retries=3 install -y wget unzip curl python3 python3-pip git && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN wget https://github.com/LeelaChessZero/lc0/releases/download/v0.30.0/lc0-v0.30.0-linux-cuda.tar.gz && tar -xvzf lc0-v0.30.0-linux-cuda.tar.gz && mv lc0* lc0 && rm lc0-v0.30.0-linux-cuda.tar.gz

RUN wget https://lczero.org/networks/current -O weights.pb.gz

RUN pip3 install flask

COPY app.py /app/app.py

CMD ["python3", "app.py"]
