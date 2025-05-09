# Aztec Sequencer Node Auto-Installer

[![Airdrop Laura](https://img.shields.io/badge/Airdrop-Laura-blue)](https://t.me/AirdropLaura)
[![Telegram Group](https://img.shields.io/badge/Telegram-Group-blue)](https://t.me/AirdropLauraDisc)

## 🔶 Overview

This script automates the installation and configuration process for running an Aztec Sequencer Node on the Aztec alpha-testnet. It provides a simple menu-driven interface to help you get your node running quickly and easily.

Repository: [https://github.com/AirdropLaura/Aztec_autoinstall_sequencer.git](https://github.com/AirdropLaura/Aztec_autoinstall_sequencer.git)

## ⚠️ Security Notice

**IMPORTANT**: This script stores your validator private key in a local configuration file (`~/.aztec-config.json`). While the script sets appropriate file permissions (readable only by the file owner), please be aware:

- The private key is stored in plaintext in this local file
- The security of your keys depends on the security of your machine
- Never share your configuration file with anyone
- Consider using a new/separate private key specifically for testing

## 🚀 Features

- One-click installation of Aztec CLI and dependencies
- Guided configuration of your sequencer node
- Easy management of the node process
- Tools to register as a validator
- Utilities for fixing common issues

## 📋 Requirements

- Linux or MacOS operating system
- Recommended: 8+ CPU cores
- Recommended: 16GB+ RAM
- Internet connection
- Ethereum RPC URL(s) for Sepolia testnet

## 🛠️ Installation & Usage

# install node js
```
sudo apt update
sudo apt install -y nodejs npm
```

### Quick Install

```bash
# Clone the repository
git clone https://github.com/AirdropLaura/Aztec_autoinstall_sequencer.git
```

# Go to the directory
```
cd Aztec_autoinstall_sequencer
```
# Make the script executable
```
chmod +x aztecc.sh
```
# Run the script
```
./aztecc.sh
```

### Usage Instructions

1. **Install Aztec CLI** - Installs the Aztec CLI and dependencies
2. **Configure Node Settings** - Set up your node with Ethereum RPC URLs, validator key, etc.
3. **Start Sequencer Node** - Run your node (preferably in a screen or tmux session)
4. **Register as Validator** - Register your node as a validator on the network
5. **View Configuration** - View your current settings (private key is masked)
6. **Fix Common Issues** - Tools to solve common problems

## 📊 Configuration

The script will create a configuration file at `~/.aztec-config.json` with the following settings:

- `ethereumHosts`: Your Ethereum RPC URL(s)
- `l1ConsensusHostUrls`: L1 Consensus Host URL(s)
- `validatorPrivateKey`: Your validator private key
- `coinbase`: Your coinbase address
- `p2pIp`: Your public IP address for P2P communication
- `network`: The Aztec network to use (default: alpha-testnet)
- `stakingAssetHandler`: Contract address for staking
- `l1ChainId`: L1 chain ID (default: Sepolia 11155111)

## 📝 Best Practices

1. **Run the node in a persistent session**:
   ```bash
   screen -S aztec-node
   ```
   
   To detach from the screen: Press `Ctrl+A` followed by `D`
   To reattach to the screen: `screen -r aztec-node`

2. **Secure your machine**:
   - Keep your OS updated
   - Use strong SSH passwords or (preferably) key-based authentication
   - Consider setting up a firewall

3. **Check port forwarding**:
   - Make sure port 40400 is forwarded if you're running behind a router

## ⚖️ Disclaimer

This script is provided as-is without any warranties. Users run this script at their own risk. The creators and contributors are not responsible for any loss of funds, security breaches, or other issues that may arise from using this script.

## 📞 Support

For support and discussions, join our Telegram group:
- Channel: [@AirdropLaura](https://t.me/AirdropLaura)
- Group: [@AirdropLauraDisc](https://t.me/AirdropLauraDisc)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
