FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

RUN for i in 1 2 3 4 5; do apt-get update && break || sleep 5; done && apt-get install -y wget unzip curl python3 python3-pip git cmake build-essential protobuf-compiler libprotobuf-dev libboost-all-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --recurse-submodules --branch release/0.31 https://github.com/LeelaChessZero/lc0.git && cd lc0 && mkdir build && cd build && cmake .. && make && cp lc0 /app/lc0

RUN wget https://lczero.org/networks/current -O weights.pb.gz

RUN pip3 install flask

COPY . /app

CMD ["python3", "app.py"]
