# Use Ubuntu noble (24.04) as the base image
FROM ubuntu:noble

# Set the environment variable to disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        ca-certificates \
        iproute2 \
        xz-utils \
        bzip2 \
        sudo \
        locales \
        adduser \
        fakeroot \
        apt-utils && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
RUN update-locale lang=en_US.UTF-8 && \
    dpkg-reconfigure --frontend noninteractive locales

# Set up working directory and permissions
RUN mkdir -p /home/container && \
    chmod -R 777 /home/container && \
    mkdir -p /var/lib/dpkg /var/lib/apt/lists /var/cache/apt/archives && \
    chmod -R 777 /var/lib/dpkg /var/lib/apt /var/cache/apt && \
    mkdir -p /var/lib/dpkg/updates /var/lib/apt/lists/partial /var/cache/apt/archives/partial && \
    chmod -R 777 /var/lib/dpkg/updates /var/lib/apt/lists/partial /var/cache/apt/archives/partial && \
    touch /var/lib/dpkg/status /var/lib/dpkg/available && \
    chmod 666 /var/lib/dpkg/status /var/lib/dpkg/available && \
    mkdir -p /etc/apt/apt.conf.d && \
    chmod -R 777 /etc/apt

# Create necessary directories with proper permissions
RUN mkdir -p /var/log/apt && \
    chmod -R 777 /var/log/apt && \
    mkdir -p /var/log/dpkg && \
    chmod -R 777 /var/log/dpkg && \
    mkdir -p /etc/dpkg/dpkg.cfg.d && \
    chmod -R 777 /etc/dpkg

# Set up working directory
WORKDIR /home/container

# Copy scripts into the container
COPY ./entrypoint.sh /entrypoint.sh
COPY ./install.sh /install.sh
COPY ./run.sh /run.sh

# Make the copied scripts executable
RUN chmod +x /entrypoint.sh /install.sh /run.sh

# Create a special apt configuration to handle read-only filesystem
RUN echo 'Dir::Cache "/home/container/apt/cache/";' > /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::State::lists "/home/container/apt/lists/";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::Log "/home/container/apt/log/";' >> /etc/apt/apt.conf.d/99custom

# Ensure we run as root
USER root

# Set the default command
CMD ["/bin/bash", "/entrypoint.sh"]