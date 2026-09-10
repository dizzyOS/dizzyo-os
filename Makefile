# DizzyoOS Makefile
# Build and manage DizzyoOS distribution

.PHONY: all clean build iso packages repo help

# Configuration
ISO_NAME := dizzyo-os-$(shell date +%Y.%m.%d)-x86_64.iso
BUILD_DIR := build
OUTPUT_DIR := output

# Default target
all: help

# Help
help:
	@echo "DizzyoOS Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make build      - Build all packages and ISO"
	@echo "  make iso        - Build ISO only"
	@echo "  make packages   - Build custom packages"
	@echo "  make repo       - Create custom repository"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make test       - Test ISO in QEMU"
	@echo "  make help       - Show this help"
	@echo ""

# Build everything
build: clean packages repo iso

# Build ISO
iso:
	@echo "Building ISO..."
	sudo ./create-iso.sh

# Build packages
packages:
	@echo "Building packages..."
	@for pkg in packages/*/; do \
		if [ -f "$$pkg/PKGBUILD" ]; then \
			echo "Building $$pkg..."; \
			cd "$$pkg" && makepkg -s --noconfirm && cd ../..; \
		fi \
	done

# Create repository
repo:
	@echo "Creating repository..."
	@mkdir -p $(BUILD_DIR)/repo/x86_64
	@cp packages/*/pkg/*.pkg.tar.zst $(BUILD_DIR)/repo/x86_64/ 2>/dev/null || true
	@cd $(BUILD_DIR)/repo/x86_64 && repo-add -s -n -R dizzyo.db.tar.gz *.pkg.tar.zst

# Clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR) $(OUTPUT_DIR) iso work
	@echo "Clean complete!"

# Test in QEMU
test:
	@echo "Testing ISO in QEMU..."
	@if [ -f "$(OUTPUT_DIR)/$(ISO_NAME)" ]; then \
		qemu-system-x86_64 \
			-enable-kvm \
			-m 4G \
			-smp 4 \
			-cpu host \
			-cdrom $(OUTPUT_DIR)/$(ISO_NAME) \
			-boot d \
			-vga virtio \
			-display gtk; \
	else \
		echo "ISO not found. Run 'make iso' first."; \
	fi

# Create virtual disk for testing
disk:
	@echo "Creating virtual disk..."
	qemu-img create -f qcow2 $(BUILD_DIR)/dizzyo.qcow2 50G

# Test with disk
test-disk: disk
	@echo "Testing ISO with disk..."
	qemu-system-x86_64 \
		-enable-kvm \
		-m 4G \
		-smp 4 \
		-cpu host \
		-drive file=$(BUILD_DIR)/dizzyo.qcow2,format=qcow2 \
		-cdrom $(OUTPUT_DIR)/$(ISO_NAME) \
		-boot d \
		-vga virtio \
		-display gtk

# Install dependencies
deps:
	@echo "Installing dependencies..."
	sudo pacman -S --noconfirm archiso squashfs-tools qemu-full

# Verify build
verify:
	@echo "Verifying build..."
	@if [ -d "archiso" ] && [ -f "build.sh" ] && [ -f "create-iso.sh" ]; then \
		echo "Build files present!"; \
	else \
		echo "Missing build files!"; \
		exit 1; \
	fi

# Show project structure
tree:
	@echo "Project structure:"
	@find . -type f -not -path '*/\.*' | sort

# Generate documentation
docs:
	@echo "Generating documentation..."
	@mkdir -p docs
	@cp README.md docs/
	@cp QUICKSTART.md docs/

# Package release
release: clean build
	@echo "Creating release..."
	@mkdir -p release
	@cp $(OUTPUT_DIR)/$(ISO_NAME) release/
	@sha256sum $(OUTPUT_DIR)/$(ISO_NAME) > release/checksums.txt
	@tar -czf release/dizzyo-os-source.tar.gz --exclude=.git --exclude=release --exclude=output .
	@echo "Release created in release/"

# Show help for specific target
%:
	@echo "Unknown target: $@"
	@echo "Run 'make help' for available targets"
