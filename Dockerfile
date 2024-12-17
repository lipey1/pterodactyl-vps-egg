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
        apt-utils \
        cron \
        dbus && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
RUN update-locale lang=en_US.UTF-8 && \
    dpkg-reconfigure --frontend noninteractive locales

# Set up working directory and permissions
RUN mkdir -p /home/container && \
    chmod -R 777 /home/container && \
    mkdir -p /etc/apt/apt.conf.d && \
    chmod -R 777 /etc/apt && \
    mkdir -p /var/lib/apt/lists/partial \
             /var/cache/apt/archives/partial \
             /var/lib/dpkg && \
    chmod -R 777 /var/lib/apt \
                 /var/cache/apt \
                 /var/lib/dpkg

# Set up working directory
WORKDIR /home/container

# Copy scripts into the container
COPY ./entrypoint.sh /entrypoint.sh
COPY ./install.sh /install.sh
COPY ./run.sh /run.sh

# Make the copied scripts executable
RUN chmod +x /entrypoint.sh /install.sh /run.sh

# Create a special apt configuration to handle read-only filesystem
RUN echo 'Dir::Cache "/home/container/.apt/cache/";' > /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::State::lists "/home/container/.apt/lists/";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::Log "/home/container/.var/log/apt/";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::State::extended_states "/home/container/.apt/extended_states";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::State::status "/home/container/.var/lib/dpkg/status";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::State "/home/container/.apt/";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::Cache::archives "/home/container/.cache/apt/archives/";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::Cache::pkgcache "";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::Etc::TrustedParts "/home/container/.apt/trusted.gpg.d/";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::Log::Terminal "/home/container/.var/log/apt/term.log";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Dir::Log::History "/home/container/.var/log/apt/history.log";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'APT::Get::List-Cleanup "0";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'APT::Keep-Downloaded-Packages "true";' >> /etc/apt/apt.conf.d/99custom && \
    echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99custom

# Create dpkg configuration
RUN mkdir -p /etc/dpkg/dpkg.cfg.d && \
    echo 'path-exclude=/usr/share/doc/*' > /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo 'path-exclude=/usr/share/man/*' >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo 'path-exclude=/usr/share/groff/*' >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo 'path-exclude=/usr/share/info/*' >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo 'path-exclude=/usr/share/lintian/*' >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo 'path-exclude=/usr/share/linda/*' >> /etc/dpkg/dpkg.cfg.d/01_nodoc && \
    echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/02_unsafe-io && \
    echo 'no-debsig' >> /etc/dpkg/dpkg.cfg.d/02_unsafe-io && \
    echo 'force-confdef' >> /etc/dpkg/dpkg.cfg.d/02_unsafe-io && \
    echo 'force-confold' >> /etc/dpkg/dpkg.cfg.d/02_unsafe-io && \
    echo 'admindir /home/container/.var/lib/dpkg' > /etc/dpkg/dpkg.cfg.d/03_custom && \
    echo 'no-chroot' >> /etc/dpkg/dpkg.cfg.d/03_custom && \
    echo 'log /home/container/.var/log/dpkg' >> /etc/dpkg/dpkg.cfg.d/03_custom

# Install additional required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fakechroot \
        libc6-dev && \
    rm -rf /var/lib/apt/lists/*

# Create required system groups
RUN for group in messagebus ssl-cert input audio dip plugdev; do \
        getent group $group > /dev/null 2>&1 || groupadd -r $group; \
    done

# Ensure we run as root
USER root

# Set the default command
CMD ["/bin/bash", "/entrypoint.sh"]