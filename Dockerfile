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
        fakeroot && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
RUN update-locale lang=en_US.UTF-8 && \
    dpkg-reconfigure --frontend noninteractive locales

# Set up working directory and permissions
RUN mkdir -p /home/container && \
    touch /home/container/.custom_shell_history && \
    chmod -R 777 /home/container && \
    mkdir -p /var/lib/dpkg /var/lib/apt /var/cache/apt \
           /var/lib/dpkg/updates /var/lib/apt/lists/partial \
           /var/cache/apt/archives/partial && \
    touch /var/lib/dpkg/lock-frontend && \
    touch /var/lib/apt/lists/lock && \
    touch /var/cache/apt/archives/lock && \
    chmod -R 777 /var/lib/dpkg /var/lib/apt /var/cache/apt

# Set up working directory
WORKDIR /home/container

# Copy scripts into the container
COPY ./entrypoint.sh /entrypoint.sh
COPY ./install.sh /install.sh
COPY ./run.sh /run.sh

# Make the copied scripts executable
RUN chmod +x /entrypoint.sh /install.sh /run.sh

# Ensure we run as root
USER root

# Set the default command
CMD ["/bin/bash", "/entrypoint.sh"]