# DizzyoOS Dockerfile
# Builds DizzyoOS ISO in a container

FROM archlinux:latest

# Install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    archiso \
    squashfs-tools \
    git \
    base-devel \
    wget \
    curl && \
    pacman -Scc --noconfirm

# Set working directory
WORKDIR /build

# Copy build files
COPY . .

# Make scripts executable
RUN chmod +x create-iso.sh build.sh

# Default command
CMD ["./create-iso.sh"]
