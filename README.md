# weclapp-install
Scripts for automated WeclappON installation.
This repository provides automated installation and management scripts for **weclappON**, simplifying the deployment process through either Makefile OR shell script approaches.

## Why Use Automated Installation?

The automated installation offers several key advantages over manual setup:

- **🚀 Simplification**: Complete installation with a single command instead of multiple manual steps
- **🛡️ Error Handling**: Automatic checks and validations prevent common installation issues
- **🔄 Consistency**: Identical installations across different systems and environments
- **⚙️ Easy Maintenance**: Simplified updates and ongoing management operations
- **🔐 Security**: Automatic verification of root permissions and system requirements
- **📋 Enhanced Logging**: Colored output and clear status messages for better user experience

## Installation Methods

Choose between two approaches based on your preference:

### Option 1: Makefile Approach

Save the provided Makefile in your desired directory and use these commands:

```bash
# Complete installation
sudo make install

# Start weclappON
sudo make start

# View logs
make logs

# Update to latest version
sudo make update

# Show all available commands
make help
```

### Option 2: Shell Script Approach

Save the script as `weclapp-install.sh` and make it executable:

```bash
# Make script executable
chmod +x weclapp-install.sh

# Complete installation
sudo ./weclapp-install.sh install

# Start weclappON
sudo ./weclapp-install.sh start

# View logs
./weclapp-install.sh logs

# Update to latest version
sudo ./weclapp-install.sh update

# Show help and all available commands
./weclapp-install.sh help
```

## Available Commands

Both approaches support the following operations:

| Command | Description |
|---------|-------------|
| `install` | Performs complete installation (Docker + directories + compose file) |
| `install-extended` | Installation with extended compose file (required for printing features) |
| `start` | Starts weclappON services |
| `stop` | Stops weclappON services |
| `restart` | Restarts weclappON services |
| `update` | Updates weclappON to the latest version |
| `logs` | Shows live application logs |
| `status` | Displays container status |
| `clean` | Removes containers (data is preserved) |
| `uninstall` | Complete uninstallation (**WARNING: Deletes all data!**) |
| `help` | Shows available commands and usage information |

## System Requirements

- **Operating System**: Ubuntu/Debian (script can be adapted for other distributions)
- **Privileges**: Root access required for installation and management
- **Network**: Internet connection for downloading Docker images and compose files

## Quick Start

1. **Clone or download** the installation files
2. **Choose your preferred method** (Makefile or shell script)
3. **Run the installation**:
   ```bash
   # For Makefile
   sudo make install
   
   # For shell script
   sudo ./weclapp-install.sh install
   ```
4. **Start the application**:
   ```bash
   # For Makefile
   sudo make start
   
   # For shell script
   sudo ./weclapp-install.sh start
   ```
5. **Access weclappON** at `http://localhost:8080`

## Post-Installation

After successful installation:

- **Web Interface**: Access weclappON at `http://localhost:8080`
- **First Login**: Create your first user account through the web interface
- **Setup Wizard**: Complete the initial configuration including SMTP settings
- **Data Storage**: Your data is stored in `/opt/weclapp-data/` and persists across updates

## Configuration

### Default Directories

- **Application**: `/opt/weclapp/`
- **Data Storage**: `/opt/weclapp-data/`
  - Database: `/opt/weclapp-data/db`
  - File Blobs: `/opt/weclapp-data/blobs`
  - Search Index: `/opt/weclapp-data/solr`

### Custom Directories

If you need to use different directories, modify the paths in the `docker-compose.yml` file after download but before starting the application.

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you're running installation commands with `sudo`
2. **Port 8080 in use**: Stop other services using port 8080 or modify the port in `docker-compose.yml`
3. **Docker not starting**: Check Docker service status with `systemctl status docker`

### Getting Help

- **View logs**: Use `make logs` or `./weclapp-install.sh logs`
- **Check status**: Use `make status` or `./weclapp-install.sh status`
- **Restart services**: Use `make restart` or `./weclapp-install.sh restart`

## Updates

Keep your weclappON installation up to date:

```bash
# For Makefile
sudo make update

# For shell script  
sudo ./weclapp-install.sh update
```

This will:
1. Download the latest Docker images
2. Stop the current version
3. Start the new version
4. Preserve all your data

## Data Safety

- **Backups**: Your data in `/opt/weclapp-data/` persists across updates
- **Container Removal**: Using `clean` command removes containers but keeps data
- **Complete Removal**: Only `uninstall` command will delete your data permanently

## Contributing

Feel free to submit issues and enhancement requests. Pull requests are welcome for:
- Support for additional Linux distributions
- Enhanced error handling
- Additional management features

## License

This automation script is provided as-is for simplifying weclappON installation. Please refer to weclappON's official documentation for application-specific licensing terms.
