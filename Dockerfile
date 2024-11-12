# Use a CentOS 7 base image to ensure compatibility
FROM centos:7

# Update repository metadata and install EPEL (Extra Packages for Enterprise Linux) for additional packages
RUN yum -y update && \
    yum -y install epel-release && \
    yum clean all

# Install Development Tools and required dependencies
RUN yum -y groupinstall "Development Tools" && \
    yum -y install wget openssl-devel bzip2-devel libffi-devel zlib-devel && \
    yum clean all

# Install Python 3.10
RUN wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz && \
    tar xzf Python-3.10.13.tgz && \
    cd Python-3.10.13 && \
    ./configure --prefix=/opt/python3.10 --enable-optimizations && \
    make altinstall && \
    cd .. && rm -rf Python-3.10.13*

# Update PATH to include new Python installation
ENV PATH="/opt/python3.10/bin:$PATH"

# Create a virtual environment and install packages
RUN python3.10 -m venv /opt/python-venv && \
    source /opt/python-venv/bin/activate && \
    /opt/python-venv/bin/pip install --upgrade pip && \
    /opt/python-venv/bin/pip install langchain chromadb ollama

# Create a tar.gz archive of the Python installation and virtual environment
RUN tar -czf /python_env.tar.gz /opt/python3.10 /opt/python-venv

# The tar file is stored in /python_env.tar.gz
