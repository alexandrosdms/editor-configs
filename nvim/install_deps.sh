#!bin\bash

# Packer package manager
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
# Linux
sudo apt install clangd \
    clangd-format \
    cmake \
    ninja-build \
    tmux
# Latest version of neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim

# Delete any previous neovim packages
rm -rf ~/.local/share/nvim/site/pack/packer
rm -rf ~/.local/share/nvim/site/pack/*/start/*
