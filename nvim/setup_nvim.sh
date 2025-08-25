#!/bin/bash

# Enhanced Neovim Setup Script
# Sets up Neovim with LSP support for C/C++ development

set -e  # Exit on any error

echo "🚀 Starting Neovim setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to compare version numbers
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# Check if Neovim is installed and get version
check_neovim_version() {
    if command -v nvim >/dev/null 2>&1; then
        local nvim_version=$(nvim --version | head -n1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0")
        echo "$nvim_version"
    else
        echo "0.0.0"
    fi
}

# Remove existing Neovim installation
remove_neovim() {
    print_status "Removing existing Neovim installation..."
    
    # Remove via package manager
    sudo apt remove neovim -y 2>/dev/null || true
    sudo apt autoremove -y 2>/dev/null || true
    
    # Remove snap version if exists
    sudo snap remove nvim 2>/dev/null || true
    
    # Remove flatpak version if exists
    flatpak uninstall io.neovim.nvim -y 2>/dev/null || true
    
    # Remove AppImage or manual installations
    sudo rm -f /usr/local/bin/nvim 2>/dev/null || true
    sudo rm -f /usr/bin/nvim 2>/dev/null || true
    
    print_success "Existing Neovim installations removed"
}

# Install latest Neovim
install_neovim() {
    print_status "Installing latest Neovim..."
    
    # Add PPA and install
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install neovim -y
    
    # Verify installation
    if command -v nvim >/dev/null 2>&1; then
        local new_version=$(check_neovim_version)
        print_success "Neovim $new_version installed successfully"
    else
        print_error "Failed to install Neovim"
        exit 1
    fi
}

# Main version check and installation logic
print_status "Checking Neovim version..."

current_version=$(check_neovim_version)
required_version="0.10.0"

if [ "$current_version" = "0.0.0" ]; then
    print_warning "Neovim not found. Installing latest version..."
    install_neovim
elif version_gt "$required_version" "$current_version"; then
    print_warning "Neovim $current_version is below required version $required_version"
    print_status "Upgrading to latest version..."
    remove_neovim
    install_neovim
else
    print_success "Neovim $current_version meets requirements (>= $required_version)"
fi

# Clean up existing Neovim data
print_status "Cleaning up existing Neovim configuration data..."
rm -rf ~/.local/share/nvim/site/pack/packer
rm -rf ~/.local/share/nvim/site/pack/*/start/*
rm -rf ~/.config/nvim/plugin/packer_compiled.lua

# Install system dependencies
print_status "Installing system dependencies..."
sudo apt update
sudo apt install -y \
    clangd \
    clang-format \
    cmake \
    ninja-build \
    tmux \
    git \
    curl \
    build-essential

# Install Packer package manager
print_status "Installing Packer package manager..."
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

print_success "Setup completed successfully!"

# Print setup instructions
echo ""
echo "📋 NEXT STEPS:"
echo "=============="
echo ""
echo "1. 📁 Place your init.lua file at: ~/.config/nvim/init.lua"
echo ""
echo "2. 🚀 Start Neovim and run the following commands:"
echo "   :PackerSync"
echo "   :MasonInstallAll"
echo ""
echo "3. 🏗️  CMAKE PROJECT SETUP:"
echo "   To ensure your C/C++ project structure is recognized by LSP:"
echo ""
echo "   Option A - For existing CMake projects:"
echo "   • Make sure you have a CMakeLists.txt in your project root"
echo "   • Run: cmake -B build -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
echo "   • This creates compile_commands.json that clangd uses"
echo "   • Run: ln -sf build/compile_commands.json . from the project root"
echo ""
echo "   Sample CMakeLists.txt:"
echo "   ====================="
echo "   cmake_minimum_required(VERSION 3.16)"
echo "   project(MyProject)"
echo "   set(CMAKE_CXX_STANDARD 17)"
echo "   set(CMAKE_EXPORT_COMPILE_COMMANDS ON)  # Important for LSP!"
echo "   add_executable(main src/main.cpp)"
echo ""
echo "4. 🔧 CLANGD CONFIGURATION (Optional):"
echo "   Create ~/.config/clangd/config.yaml:"
echo "   CompileFlags:"
echo "     Add: [-std=c++17, -Wall, -Wextra]"
echo "     Remove: [-W*]"
echo ""
echo "5. 🎯 KEY BINDINGS:"
echo "   • Space + f  : Format code"
echo "   • Space + e  : Toggle file explorer"
echo "   • Ctrl + p   : Find files"
echo "   • Ctrl + f   : Search in files"
echo "   • gd         : Go to definition"
echo "   • K          : Show hover info"
echo "   • Space + rn : Rename symbol"
echo "   • Space + ca : Code actions"
echo ""
print_success "Happy coding! 🎉"
