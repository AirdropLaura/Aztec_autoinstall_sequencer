#!/usr/bin/env node

const fs = require('fs');
const readline = require('readline');
const { execSync, spawn } = require('child_process');
const path = require('path');
const os = require('os');

// Configuration variables
const CONFIG_FILE = path.join(os.homedir(), '.aztec-config.json');
let config = {
  ethereumHosts: '',
  l1ConsensusHostUrls: '',
  validatorPrivateKey: '',
  coinbase: '',
  p2pIp: '',
  network: 'alpha-testnet',
  stakingAssetHandler: '0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2',
  l1ChainId: '11155111'
};

// Create readline interface
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Helper function to ask questions
function question(query) {
  return new Promise((resolve) => {
    rl.question(query, resolve);
  });
}

// Helper function to execute shell commands
function execCommand(command) {
  try {
    console.log(`Executing: ${command}`);
    return execSync(command, { stdio: 'inherit' });
  } catch (error) {
    console.error(`Command failed: ${error.message}`);
    return null;
  }
}

// Display menu
async function showMenu() {
  console.clear();
  console.log('╔════════════════════════════════════════════╗');
  console.log('║            AIRDROP LAURA                   ║');
  console.log('║       AZTEC SEQUENCER NODE INSTALLER       ║');
  console.log('╠════════════════════════════════════════════╣');
  console.log('║ 1. Install Aztec CLI                       ║');
  console.log('║ 2. Configure Node Settings                 ║');
  console.log('║ 3. Start Sequencer Node                    ║');
  console.log('║ 4. Register as Validator                   ║');
  console.log('║ 5. View Configuration                      ║');
  console.log('║ 6. Fix Common Issues                       ║');
  console.log('║ 0. Exit                                    ║');
  console.log('╠════════════════════════════════════════════╣');
  console.log('║ Channel Telegram: @AirdropLaura            ║');
  console.log('║ Grup Telegram: @AirdropLauraDisc           ║');
  console.log('╚════════════════════════════════════════════╝');
  
  const choice = await question('Enter your choice (0-6): ');
  
  switch (choice) {
    case '1':
      await installAztec();
      break;
    case '2':
      await configureNode();
      break;
    case '3':
      await startNode();
      break;
    case '4':
      await registerValidator();
      break;
    case '5':
      await viewConfig();
      break;
    case '6':
      await fixCommonIssues();
      break;
    case '0':
      console.log('Exiting...');
      rl.close();
      return;
    default:
      console.log('Invalid option, please try again.');
  }
  
  await question('\nPress Enter to return to the menu...');
  await showMenu();
}

// Install Aztec
async function installAztec() {
  console.log('\n=== Installing Aztec CLI ===\n');
  
  // Check if system is Linux or MacOS
  const platform = os.platform();
  if (platform !== 'linux' && platform !== 'darwin') {
    console.error('This script only supports Linux and MacOS.');
    return;
  }
  
  // Check system requirements
  console.log('Checking system requirements...');
  const cpuCount = os.cpus().length;
  const totalMem = Math.floor(os.totalmem() / (1024 * 1024 * 1024)); // GB
  
  console.log(`CPU Cores: ${cpuCount} (Recommended: 8+)`);
  console.log(`RAM: ${totalMem}GB (Recommended: 16GB+)`);
  
  if (cpuCount < 8 || totalMem < 16) {
    console.warn('\n⚠️  WARNING: Your system does not meet the recommended requirements.');
    const proceed = await question('Do you want to proceed anyway? (y/n): ');
    if (proceed.toLowerCase() !== 'y') {
      return;
    }
  }
  
  try {
    // Install dependencies
    console.log('\nInstalling dependencies...');
    if (platform === 'linux') {
      execCommand('sudo apt-get update');
      execCommand('sudo apt-get install -y curl build-essential');
    } else if (platform === 'darwin') {
      execCommand('xcode-select --install || true');
    }
    
    // Install Aztec CLI
    console.log('\nInstalling Aztec CLI...');
    execCommand('bash -i <(curl -s https://install.aztec.network)');
    
    // Install the alpha-testnet version
    console.log('\nInstalling alpha-testnet version...');
    execCommand('aztec-up alpha-testnet');
    
    console.log('\n✅ Aztec CLI installation completed.');
  } catch (error) {
    console.error(`Installation failed: ${error.message}`);
  }
}

// Configure Node
async function configureNode() {
  console.log('\n=== Configure Node Settings ===\n');
  
  // Load existing config if available
  try {
    if (fs.existsSync(CONFIG_FILE)) {
      config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
      console.log('Loaded existing configuration.');
    }
  } catch (error) {
    console.warn('Could not load existing configuration.');
  }
  
  // Get RPC URLs
  config.ethereumHosts = await question(`Ethereum RPC URL(s) [${config.ethereumHosts}]: `) || config.ethereumHosts;
  config.l1ConsensusHostUrls = await question(`L1 Consensus Host URL(s) [${config.l1ConsensusHostUrls}]: `) || config.l1ConsensusHostUrls;
  
  // Get validator private key
  const maskedKey = config.validatorPrivateKey ? '********' : '';
  const newValidatorKey = await question(`Validator Private Key [${maskedKey}]: `);
  if (newValidatorKey && newValidatorKey !== maskedKey) {
    config.validatorPrivateKey = newValidatorKey.startsWith('0x') ? newValidatorKey : `0x${newValidatorKey}`;
  }
  
  // Get coinbase address
  config.coinbase = await question(`Coinbase Address [${config.coinbase}]: `) || config.coinbase;
  
  // Get P2P IP
  let defaultIp = config.p2pIp;
  if (!defaultIp) {
    try {
      // Try to get the public IP
      const ip = execSync('curl -s api.ipify.org', { encoding: 'utf8' }).trim();
      defaultIp = ip;
    } catch (error) {
      console.warn('Could not fetch public IP automatically.');
    }
  }
  
  config.p2pIp = await question(`P2P IP Address [${defaultIp}]: `) || defaultIp;
  
  // Save configuration to file
  try {
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2), 'utf8');
    console.log('\n✅ Configuration saved successfully.');
    
    // Set file permissions to user-only read/write
    fs.chmodSync(CONFIG_FILE, 0o600);
  } catch (error) {
    console.error(`Failed to save configuration: ${error.message}`);
  }
}

// Start Node
async function startNode() {
  console.log('\n=== Starting Sequencer Node ===\n');
  
  // Check if configuration exists
  if (!fs.existsSync(CONFIG_FILE)) {
    console.error('Configuration not found. Please configure your node first.');
    return;
  }
  
  // Load configuration
  config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
  
  // Validate required configuration
  const requiredFields = ['ethereumHosts', 'l1ConsensusHostUrls', 'validatorPrivateKey', 'coinbase', 'p2pIp'];
  const missingFields = requiredFields.filter(field => !config[field]);
  
  if (missingFields.length > 0) {
    console.error(`Missing required configuration: ${missingFields.join(', ')}`);
    return;
  }
  
  console.log('Starting Aztec sequencer node...');
  console.log('NOTE: You should run this in a screen or tmux session to keep it running after you close the terminal.');
  console.log('\nCommand to create a screen session:');
  console.log('  screen -S aztec-node');
  
  const startCommand = `aztec start --node --archiver --sequencer \
  --network ${config.network} \
  --l1-rpc-urls "${config.ethereumHosts}" \
  --l1-consensus-host-urls "${config.l1ConsensusHostUrls}" \
  --sequencer.validatorPrivateKey "${config.validatorPrivateKey}" \
  --sequencer.coinbase "${config.coinbase}" \
  --p2p.p2pIp "${config.p2pIp}" \
  --p2p.maxTxPoolSize 1000000000`;
  
  console.log('\nCommand that will be executed:');
  console.log(startCommand);
  
  const runNow = await question('\nDo you want to run this command now? (y/n): ');
  if (runNow.toLowerCase() === 'y') {
    console.log('\nStarting node... Press Ctrl+C to stop.');
    const nodeProcess = spawn('bash', ['-c', startCommand], { stdio: 'inherit' });
    
    nodeProcess.on('error', (error) => {
      console.error(`Failed to start node: ${error.message}`);
    });
    
    // This will keep the script running until the node process exits
    await new Promise(resolve => {
      nodeProcess.on('exit', (code) => {
        console.log(`Node process exited with code ${code}`);
        resolve();
      });
    });
  }
}

// Register as Validator
async function registerValidator() {
  console.log('\n=== Register as Validator ===\n');
  
  // Check if configuration exists
  if (!fs.existsSync(CONFIG_FILE)) {
    console.error('Configuration not found. Please configure your node first.');
    return;
  }
  
  // Load configuration
  config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
  
  // Get attester and proposer
  const attester = await question(`Attester Address [${config.coinbase}]: `) || config.coinbase;
  const proposer = await question(`Proposer EOA Address [${config.coinbase}]: `) || config.coinbase;
  
  const registerCommand = `aztec add-l1-validator \
  --l1-rpc-urls "${config.ethereumHosts}" \
  --private-key "${config.validatorPrivateKey}" \
  --attester "${attester}" \
  --proposer-eoa "${proposer}" \
  --staking-asset-handler "${config.stakingAssetHandler}" \
  --l1-chain-id ${config.l1ChainId}`;
  
  console.log('\nCommand that will be executed:');
  console.log(registerCommand);
  
  const runNow = await question('\nDo you want to run this command now? (y/n): ');
  if (runNow.toLowerCase() === 'y') {
    execCommand(registerCommand);
    console.log('\nNote: If you see "ValidatorQuotaFilledUntil", try again after the timestamp shown.');
  }
}

// View Configuration
async function viewConfig() {
  console.log('\n=== Current Configuration ===\n');
  
  if (!fs.existsSync(CONFIG_FILE)) {
    console.log('No configuration found.');
    return;
  }
  
  try {
    config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
    
    // Display config with masked private key
    const displayConfig = { ...config };
    if (displayConfig.validatorPrivateKey) {
      displayConfig.validatorPrivateKey = '********';
    }
    
    console.log(JSON.stringify(displayConfig, null, 2));
  } catch (error) {
    console.error(`Error reading configuration: ${error.message}`);
  }
}

// Fix Common Issues
async function fixCommonIssues() {
  console.log('\n=== Fix Common Issues ===\n');
  console.log('1. Clear world state (fix sync block errors)');
  console.log('2. Update to latest alpha-testnet version');
  console.log('3. Port forwarding check');
  console.log('4. Back to main menu');
  
  const choice = await question('\nEnter your choice (1-4): ');
  
  switch (choice) {
    case '1':
      console.log('\nClearing world state data...');
      execCommand('rm -rf ~/.aztec/alpha-testnet/data/archiver');
      console.log('✅ World state data cleared. You should restart your node.');
      break;
      
    case '2':
      console.log('\nUpdating to latest alpha-testnet version...');
      execCommand('aztec-up alpha-testnet');
      console.log('✅ Update completed. You should restart your node.');
      break;
      
    case '3':
      console.log('\nChecking port forwarding...');
      const port = await question('Enter your P2P port (default 40400): ') || '40400';
      execCommand(`nc -zv localhost ${port}`);
      console.log('\nTo verify external port forwarding, visit https://portchecker.co/ and check port', port);
      break;
      
    case '4':
      return;
      
    default:
      console.log('Invalid option, returning to main menu.');
  }
}

// Main function
async function main() {
  console.log('\n\n');
  console.log('=================================================');
  console.log('                  AIRDROP LAURA                  ');
  console.log('           Aztec Sequencer Node Installer        ');
  console.log('=================================================');
  console.log('    Channel Telegram: @AirdropLaura              ');
  console.log('    Grup Telegram: @AirdropLauraDisc             ');
  console.log('=================================================');
  console.log('\n');
  await showMenu();
}

// Start the program
main().catch(err => {
  console.error('An error occurred:', err);
  rl.close();
});
