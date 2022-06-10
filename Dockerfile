FROM debian:buster-slim as buildstage

# Install dependencies
RUN apt-get update && \
    apt-get install -y git pkg-config && \
    apt-get -y --no-install-recommends install wget make git gcc g++ libbz2-dev libstxxl-dev libstxxl1v5 libxml2-dev \
        libzip-dev libboost-all-dev lua5.2 liblua5.2-dev libtbb-dev -o APT::Install-Suggests=0 -o APT::Install-Recommends=0

# Install cmake 3.15 for cmake requirement of 3.15 or higher in HiGHS
RUN wget https://github.com/Kitware/CMake/releases/download/v3.23.2/cmake-3.23.2-linux-x86_64.sh && \
    chmod +x cmake-3.23.2-linux-x86_64.sh &&\
    ./cmake-3.23.2-linux-x86_64.sh --skip-license

# Build HiGhs-backend
RUN git clone https://github.com/ERGO-Code/HiGHS.git && \
    cd HiGHS && \
    mkdir build
    
RUN cd /HiGHS/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/HiGHS/highs_install .. && \
    cmake --build . --parallel 4 --config Release && \
    cmake --install .

ENV LD_LIBRARY_PATH=/HiGHS/highs_install/lib
ENV DYLD_LIBRARY_PATH=/HiGHS/highs_install/lib
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.7 \
    python3-pip \
    python3-venv \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
RUN pip3 install --no-cache-dir /HiGHS/src/interfaces/highspy/

WORKDIR /HiGHS/build/bin
COPY test.py .
RUN ./highs --help
RUN python3 test.py

FROM debian:buster-slim as runstage

# Copy HiGHS binaries from `buildstage`
COPY --from=buildstage  /HiGHS /HiGHS
COPY --from=buildstage /opt/venv /opt/venv

ENV LD_LIBRARY_PATH=/HiGHS/highs_install/lib
ENV DYLD_LIBRARY_PATH=/HiGHS/highs_install/lib

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.7 \
    python3-pip \
    python3-venv \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /HiGHS/build/bin

COPY ml.mps .
RUN ./highs ml.mps

COPY test.py .
RUN python3 test.py
CMD [ "python3", "test.py" ]
