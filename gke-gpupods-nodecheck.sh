#this is a quick script to diagnose possible issues with NVIDIA and CUDA in K8S environment
#run it as root on the nodes you want to check
#!/bin/bash

# Set color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo privileges${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

echo -e "${BLUE}=== NVIDIA System Check Script ===${NC}\n"

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Function to check command existence
check_command() {
    if command -v $1 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ $1 found${NC}"
        return 0
    else
        echo -e "${RED}✗ $1 not found${NC}"
        return 1
    fi
}

# Check PCI connection
print_header "Checking NVIDIA PCI Connection"
NVIDIA_PCI=$(lspci | grep NVIDIA)
if [ -n "$NVIDIA_PCI" ]; then
    echo -e "${GREEN}Found NVIDIA device:${NC}"
    echo "$NVIDIA_PCI"
else
    echo -e "${RED}No NVIDIA PCI device found${NC}"
fi

# Check NVIDIA driver
print_header "Checking NVIDIA Driver"
if [ -f "/proc/driver/nvidia/version" ]; then
    echo -e "${GREEN}NVIDIA driver found:${NC}"
    cat /proc/driver/nvidia/version
else
    echo -e "${RED}NVIDIA driver not found${NC}"
fi

# Check NVIDIA container runtime components
print_header "Checking NVIDIA Container Runtime Components"
for component in nvidia-container-runtime nvidia-container-runtime-hook nvidia-ctk; do
    check_command $component
done

# Find nvidia-smi
print_header "Locating nvidia-smi"
NVIDIA_SMI=$(find / -type f -name "nvidia-smi" 2>/dev/null)
if [ -n "$NVIDIA_SMI" ]; then
    echo -e "${GREEN}nvidia-smi found at:${NC}"
    echo "$NVIDIA_SMI"
else
    echo -e "${RED}nvidia-smi not found${NC}"
fi

# Check containerd runtime configuration
print_header "Checking Containerd Runtime Configuration"
if [ -f "/etc/containerd/config.toml" ]; then
    echo "Checking for NVIDIA runtime in containerd config:"
    NVIDIA_RUNTIME=$(grep "containerd.runtimes.nvidia." /etc/containerd/config.toml)
    if [ -n "$NVIDIA_RUNTIME" ]; then
        echo -e "${GREEN}NVIDIA runtime found:${NC}"
        echo "$NVIDIA_RUNTIME"
    else
        echo -e "${RED}No NVIDIA runtime found in containerd config${NC}"
    fi
    
    echo -e "\nChecking bin directory configuration:"
    BIN_DIR=$(grep "bin_dir" /etc/containerd/config.toml)
    if [ -n "$BIN_DIR" ]; then
        echo -e "${GREEN}Found bin directory configuration:${NC}"
        echo "$BIN_DIR"
    fi
else
    echo -e "${RED}containerd config file not found${NC}"
fi

# Check NVIDIA binaries
print_header "Checking NVIDIA Binaries in Kubernetes Directory"
K8S_NVIDIA_DIR="/home/kubernetes/bin/nvidia/bin"
if [ -d "$K8S_NVIDIA_DIR" ]; then
    echo -e "${GREEN}NVIDIA binaries directory found:${NC}"
    ls -l $K8S_NVIDIA_DIR
else
    echo -e "${RED}NVIDIA binaries directory not found at $K8S_NVIDIA_DIR${NC}"
fi
