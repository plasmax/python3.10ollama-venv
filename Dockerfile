# Dockerfile
FROM ubuntu:22.04 AS builder

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install build dependencies
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncurses5-dev \
    libncursesw5-dev \
    liblzma-dev \
    tk-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and build Python
WORKDIR /python-build
RUN wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz \
    && tar xzf Python-3.10.13.tgz
WORKDIR /python-build/Python-3.10.13
RUN ./configure --enable-optimizations --prefix=/opt/python3.10 \
    && make -j$(nproc) \
    && make install

# Create and activate virtual environment
RUN /opt/python3.10/bin/python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install required packages
RUN pip install --no-cache-dir \
    ollama \
    langchain \
    chromadb

# Create portable archive
WORKDIR /opt
RUN tar -czf /python-portable.tar.gz python3.10 venv

# Final stage to get just the archive
FROM scratch
COPY --from=builder /python-portable.tar.gz /
