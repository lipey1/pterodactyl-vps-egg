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
    rm -rf /var/lib/apt/lists/* && \
    # Configure root access
    chmod 4755 /bin/su && \
    chmod 4755 /usr/bin/sudo && \
    # Configure sudo
    mkdir -p /etc/sudoers.d && \
    echo "container ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/container && \
    echo "Defaults !requiretty" >> /etc/sudoers && \
    chmod 440 /etc/sudoers.d/container && \
    # Create necessary directories
    mkdir -p /var/run/sudo && \
    chmod 755 /var/run/sudo

# Configure locale
RUN update-locale lang=en_US.UTF-8 && \
    dpkg-reconfigure --frontend noninteractive locales

# Create a non-root user with sudo privileges
RUN useradd -m -d /home/container -s /bin/bash container && \
    echo "container:container" | chpasswd && \
    echo "root:container" | chpasswd && \
    adduser container sudo && \
    chown -R root:root / && \
    chmod -R 755 /

# Switch to the container user
USER container
ENV USER=container
ENV HOME=/home/container

# Set the working directory
WORKDIR /home/container

# Copy scripts into the container
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
COPY --chown=container:container ./install.sh /install.sh
COPY --chown=container:container ./helper.sh /helper.sh
COPY --chown=container:container ./run.sh /run.sh

# Make the copied scripts executable
RUN chmod +x /entrypoint.sh /install.sh /helper.sh /run.sh

# Set the default command
CMD ["/bin/bash", "/entrypoint.sh"]