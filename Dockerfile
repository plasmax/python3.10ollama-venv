# Start from a minimal base image
FROM debian:bullseye-slim

# Set environment variables
ENV PYTHON_VERSION=3.10.12
ENV PREFIX_DIR=/app/python

# Install dependencies for building Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    zlib1g-dev \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and compile Python
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=$PREFIX_DIR --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall && \
    cd .. && rm -rf Python-${PYTHON_VERSION}.tgz Python-${PYTHON_VERSION}

# Install pip and required packages in a virtual environment
RUN $PREFIX_DIR/bin/python3.10 -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache-dir langchain ollama chromadb

# Package the Python installation and virtual environment as a tarball
RUN tar -czf /app/python-venv.tar.gz -C /app python venv

# Keep the container running to allow for artifact extraction
ENTRYPOINT ["tail", "-f", "/dev/null"]
