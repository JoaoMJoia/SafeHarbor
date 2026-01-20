# Ansible Playbook Example

A simple Ansible playbook demonstrating configuration management and application deployment.

## Overview

This playbook automates the deployment of a demo application to target servers, including:
- System package installation
- User and directory creation
- Application file deployment
- Service configuration (systemd)
- Service management and health verification

## Project Structure

```
ansible/
├── playbook.yml           # Main playbook
├── inventory.ini          # Inventory file (hosts)
├── ansible.cfg           # Ansible configuration
├── templates/            # Jinja2 templates
│   ├── demo-app.service.j2
│   └── demo-app.env.j2
├── group_vars/           # Group variables
│   ├── all.yml
│   └── webservers.yml
└── README.md            # This file
```

## Prerequisites

### On Control Node (where you run Ansible):
```bash
# Install Ansible
pip install ansible

# Or on macOS
brew install ansible

# Verify installation
ansible --version
```

### On Target Servers:
- SSH access with key-based authentication
- Python 3 installed
- Sudo privileges for the ansible user
- Internet access for package installation

## Configuration

### 1. Update Inventory

Edit `inventory.ini` with your target servers:

```ini
[webservers]
web1 ansible_host=192.168.1.10 ansible_user=ubuntu
web2 ansible_host=192.168.1.11 ansible_user=ubuntu
```

### 2. Test Connectivity

```bash
# Test SSH connectivity
ansible all -i inventory.ini -m ping

# Test with specific group
ansible webservers -i inventory.ini -m ping
```

### 3. Review Variables

Check and modify variables in:
- `group_vars/webservers.yml` - Group-specific variables
- `group_vars/all.yml` - Global variables
- `playbook.yml` - Playbook-level variables

## Running the Playbook

### Dry Run (Check Mode)
```bash
ansible-playbook playbook.yml --check
```

### Run Playbook
```bash
# Run on all webservers
ansible-playbook playbook.yml

# Run on specific host
ansible-playbook playbook.yml --limit web1

# Run with verbose output
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vvv  # More verbose
```

### Run with Extra Variables
```bash
ansible-playbook playbook.yml \
  -e "app_version=v2.0.0" \
  -e "environment=staging"
```

### Run with Tags
```bash
# Run only tasks tagged with 'service'
ansible-playbook playbook.yml --tags service

# Skip tasks tagged with 'package'
ansible-playbook playbook.yml --skip-tags package
```

## Common Tasks

### Check Service Status
```bash
ansible webservers -m shell -a "systemctl status demo-app"
```

### View Application Logs
```bash
ansible webservers -m shell -a "journalctl -u demo-app -n 50"
```

### Restart Service
```bash
ansible webservers -m systemd -a "name=demo-app state=restarted" --become
```

### Verify Application Health
```bash
ansible webservers -m uri -a "url=http://localhost:8080/health method=GET"
```

### Gather Facts
```bash
ansible webservers -m setup
```

## Playbook Components

### Tasks
- **Package Management**: Install system packages (curl, wget)
- **User Management**: Create application user
- **File Management**: Create directories and copy files
- **Service Configuration**: Create systemd service
- **Service Management**: Enable and start service
- **Health Verification**: Verify application is running

### Handlers
- **restart demo-app**: Restarts service when configuration changes

### Templates
- **demo-app.service.j2**: Systemd service unit file
- **demo-app.env.j2**: Environment variables file

### Variables
- `app_user`: Application user name
- `app_dir`: Application installation directory
- `app_port`: Application listening port
- `app_version`: Application version

## Key Features

1. **Idempotency**: Playbook can be run multiple times safely
2. **Modularity**: Uses templates and variables for flexibility
3. **Error Handling**: Includes health checks and verification
4. **Best Practices**: 
   - Uses handlers for service restarts
   - Separates variables by scope
   - Uses templates for configuration files
   - Includes health verification

## Troubleshooting

### Connection Issues
```bash
# Test SSH connection manually
ssh -i ~/.ssh/id_rsa ubuntu@192.168.1.10

# Check SSH configuration in ansible.cfg
# Verify inventory file format
```

### Permission Issues
```bash
# Test sudo access
ansible webservers -m shell -a "sudo whoami" --become

# Check become configuration in ansible.cfg
```

### Service Issues
```bash
# Check service status
ansible webservers -m systemd -a "name=demo-app" --become

# View service logs
ansible webservers -m shell -a "journalctl -u demo-app -n 100" --become
```

## Advanced Usage

### Using Vault for Secrets
```bash
# Create encrypted variable file
ansible-vault create group_vars/webservers/secrets.yml

# Edit encrypted file
ansible-vault edit group_vars/webservers/secrets.yml

# Run playbook with vault
ansible-playbook playbook.yml --ask-vault-pass
```

### Using Roles (Optional Enhancement)
For larger projects, consider organizing tasks into roles:
```
roles/
├── common/
│   ├── tasks/main.yml
│   └── handlers/main.yml
├── app/
│   ├── tasks/main.yml
│   ├── templates/
│   └── handlers/main.yml
```

### Parallel Execution
```bash
# Run on multiple hosts in parallel
ansible-playbook playbook.yml -f 10
```

## Best Practices Demonstrated

1. **Idempotent Operations**: All tasks can be run multiple times
2. **Variable Organization**: Variables organized by scope
3. **Template Usage**: Configuration files use Jinja2 templates
4. **Handler Usage**: Service restarts only when needed
5. **Health Checks**: Verification tasks ensure deployment success
6. **Error Handling**: Proper error handling and verification
7. **Documentation**: Clear comments and structure

## Optional Enhancements

For production use, consider adding:
- **Ansible Vault**: Encrypt sensitive data
- **Roles**: Organize tasks into reusable roles
- **Tags**: Add tags to tasks for selective execution
- **Conditionals**: More sophisticated conditional logic
- **Loops**: Use loops for repetitive tasks
- **Error Handling**: Add more robust error handling
- **Testing**: Add Molecule or similar testing framework
- **CI/CD Integration**: Integrate with CI/CD pipelines
