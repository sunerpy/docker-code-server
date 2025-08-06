# Docker Code Server - Custom Development Environment

[简体中文](README_EN.md) | English

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![VS Code](https://img.shields.io/badge/Visual%20Studio%20Code-0078d4.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com/)
[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sunerpy/docker-code-server)

> Custom development environment image based on [LinuxServer.io/docker-code-server](https://github.com/linuxserver/docker-code-server)

## 📖 Project Overview

This project is a customized version forked from [LinuxServer.io/docker-code-server](https://github.com/linuxserver/docker-code-server), designed to provide a **ready-to-use** cloud development environment without the need to install various development tools locally.

### 🎯 Project Goals

- **Environment Consistency**: Reproduce the same development environment anywhere through persistent volumes
- **Quick Deployment**: One-click startup of complete development environment without complex configuration
- **Resource Isolation**: Containerized deployment to avoid local environment pollution
- **Remote Development**: Web-based VS Code interface supporting remote development
- **Multi-platform Support**: Support for Docker, Docker Compose, and Kubernetes deployment

## ✨ Key Features

### 🔧 Pre-installed Development Tools
- **Code Server**: Web-based VS Code IDE
- **Shell Enhancement**: Zsh + Oh My Zsh + Powerlevel10k theme
- **Python Environment**: Miniconda + UV package manager
- **Java Environment**: OpenJDK 21
- **Container Tools**: Docker-in-Docker support
- **Cloud Tools**: AWS CLI, Skopeo, etc.
- **Development Tools**: Git, Vim, Maven, JQ, etc.

### 🚀 Main Changes

Compared to the original LinuxServer.io image, this project's main changes:

1. **Custom Build**: Use `Dockerfile-global` for custom builds, packaging commonly used software and commands
2. **Programming Language Version Management**: Recommend using [mise](https://github.com/jdx/mise) or [asdf](https://asdf-vm.com/) for multi-version language management instead of hardcoding language versions in the image
3. **Multiple Deployment Methods**: Support Docker, Docker Compose, and Kubernetes deployment
4. **Development Experience Optimization**: Pre-configured with rich development tools and environment

## 🛠️ Quick Start

### Method 1: Docker Run

```bash
# Basic run
docker run -d \
    --name code-server \
    --privileged \
    -v /path/to/your/workspace:/config \
    -p 8443:8443 \
    -e PASSWORD="your_password" \
    -e TZ=Asia/Shanghai \
    -e DEFAULT_WORKSPACE=/config/workspace \
    -e PUID=1000 \
    -e PGID=1000 \
    sunerpy/code-server:latest
```

For detailed Docker run script, see [examples/docker.bash](examples/docker.bash)

### Method 2: Docker Compose (Recommended)

```yaml
version: '3.8'

services:
  code-server:
    image: sunerpy/code-server:latest
    container_name: code-server
    privileged: true
    volumes:
      - /path/to/your/workspace:/config
    environment:
      - PASSWORD=your_password
      - TZ=Asia/Shanghai
      - DEFAULT_WORKSPACE=/config/workspace
      - PUID=1000
      - PGID=1000
    ports:
      - "8443:8443"
    restart: unless-stopped
```

Start the service:
```bash
docker compose up -d
```

For complete Docker Compose configuration, see [examples/docker-compose.yml](examples/docker-compose.yml)

### Method 3: Kubernetes Deployment

```bash
kubectl apply -f examples/k8s.yml
```

For detailed Kubernetes configuration, see [examples/k8s.yml](examples/k8s.yml)

## 🌐 Access Development Environment

After starting the container, access via browser: `http://your-server-ip:8443`

![Code Server Interface](examples/example.png)

## 🔧 Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `PASSWORD` | Web interface login password | - | No |
| `HASHED_PASSWORD` | Hashed password (higher priority than PASSWORD) | - | No |
| `TZ` | Timezone setting | `Etc/UTC` | No |
| `DEFAULT_WORKSPACE` | Default workspace path | `/config/workspace` | No |
| `PUID` | User ID | `1000` | No |
| `PGID` | Group ID | `1000` | No |

## 📦 Language Version Management

### Recommended: Use mise

This project recommends using [mise](https://github.com/jdx/mise) for multi-version language management instead of hardcoding language versions in the image.

```bash
# Install mise
curl https://mise.run | sh

# Install Node.js
mise install node@20
mise use node@20

# Install Python
mise install python@3.13.5
mise use python@3.13.5

# Install Go
mise install go@1.24.3
mise use go@1.24.3

# Install Rust
mise install rust@1.83.0
mise use rust@1.83.0
```

### Alternative: Use asdf

```bash
# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

# Add plugins and install languages
asdf plugin add nodejs
asdf install nodejs 20.0.0
asdf set -u nodejs 20.0.0
```

## 🏗️ Custom Build

If you need to customize the image, you can modify the `Dockerfile-global` file:

```bash
# Clone the project
git clone https://github.com/sunerpy/docker-code-server.git
cd docker-code-server

# Modify Dockerfile-global to add your needed tools

# Build the image
docker build -f Dockerfile-global -t your-custom-code-server .

# Or use makefile to build directly
make build-local-docker
```

## 🔍 Usage Tips

### Git Configuration

For first-time use, it's recommended to configure Git user information:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### SSH Key Configuration

To use SSH for Git operations, place SSH keys in the `/config/.ssh/` directory.

### Extension Installation

You can install extensions through the VS Code interface or command line:

```bash
# Use built-in script to install extensions
install-extension ms-python.python
install-extension ms-vscode.vscode-typescript-next
```

You can also use the [vscode-syncing](https://github.com/sunerpy/vscode-syncing) plugin (pre-release stage) for synchronization.

## 🐳 Docker-in-Docker Support

If you need to use Docker inside the container, you can enable Docker-in-Docker (DinD) support:

```bash
# Start DinD container
docker run -d \
  --name dind \
  --privileged \
  --volume cache-dir:/var/run \
  docker:26.0.1-dind \
  dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:8000
```

## 📁 Directory Structure

```
/config/
├── workspace/          # Default workspace
├── .ssh/              # SSH keys directory
├── .oh-my-zsh/        # Zsh configuration
├── .local/            # User local programs
└── extensions/        # VS Code extensions
```

## 🔧 Troubleshooting

### Permission Issues

If you encounter permission issues, check the `PUID` and `PGID` settings:

```bash
# Check current user ID
id $(whoami)
```

### Port Conflicts

If port 8443 is occupied, you can modify the port mapping:

```bash
-p 9443:8443  # Access via port 9443
```

### Memory Issues

It's recommended to allocate sufficient memory resources for the container:

```bash
docker run --memory=4g --memory-swap=8g ...
```

## 📄 License

This project is open source under the GPL-3.0 license. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [LinuxServer.io](https://github.com/linuxserver/docker-code-server) - Original project
- [Coder](https://github.com/coder/code-server) - Code Server project
- [mise](https://github.com/jdx/mise) - Modern development tool version manager

## 📞 Contact

- GitHub Issues: [Submit Issues](https://github.com/sunerpy/docker-code-server/issues)
- Project Homepage: [https://github.com/sunerpy/docker-code-server](https://github.com/sunerpy/docker-code-server)

---

⭐ If this project helps you, please give it a Star!
