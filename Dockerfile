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
        proot && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
RUN update-locale lang=en_US.UTF-8 && \
    dpkg-reconfigure --frontend noninteractive locales

# Set up working directory and permissions
RUN mkdir -p /home/container && \
    touch /home/container/.custom_shell_history && \
    chmod -R 777 /home/container

# Set up working directory
WORKDIR /home/container

# Copy scripts into the container
COPY ./entrypoint.sh /entrypoint.sh
COPY ./install.sh /install.sh
COPY ./run.sh /run.sh
COPY ./helper.sh /helper.sh

# Make the copied scripts executable
RUN chmod +x /entrypoint.sh /install.sh /run.sh /helper.sh

# Set the default command
CMD ["/bin/bash", "/entrypoint.sh"]