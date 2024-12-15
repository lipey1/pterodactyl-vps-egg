# Use Ubuntu noble (24.04) as the base image
FROM ubuntu:noble

# Set the environment variable to disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Ensure we run as root
USER root

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
        adduser && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
RUN update-locale lang=en_US.UTF-8 && \
    dpkg-reconfigure --frontend noninteractive locales

# Set up working directory and history file
RUN mkdir -p /home/container && \
    touch /home/container/.custom_shell_history && \
    chmod -R 777 /home/container && \
    # Set proper permissions for package management
    chmod -R 777 /var/lib/dpkg /var/lib/apt /var/cache/apt && \
    mkdir -p /var/lib/dpkg/updates /var/lib/apt/lists/partial /var/cache/apt/archives/partial && \
    chmod -R 777 /var/lib/dpkg/updates /var/lib/apt/lists/partial /var/cache/apt/archives/partial

# Set up working directory
WORKDIR /home/container

# Copy scripts into the container
COPY ./entrypoint.sh /entrypoint.sh
COPY ./install.sh /install.sh
COPY ./run.sh /run.sh

# Make the copied scripts executable
RUN chmod +x /entrypoint.sh /install.sh /run.sh

# Ensure all users can write to necessary directories
RUN chmod 777 /tmp /var/tmp && \
    mkdir -p /var/run/dpkg && \
    chmod 777 /var/run/dpkg

# Set the default command
CMD ["/bin/bash", "/entrypoint.sh"]