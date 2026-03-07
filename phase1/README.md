# Phase 1: Environment Provisioning and Git Workflow

## 1. Phase Overview
This document outlines the objectives, methodologies, and technical implementations for Phase 1 of the DevOps deployment lifecycle. The primary focus of this phase is to establish a robust collaborative environment utilizing Git and to automate the initial server provisioning process using a Bash script.

## 2. Collaborative Git Workflow
To ensure code quality, maintain a clean repository history, and facilitate team collaboration, the following Git workflow practices have been strictly implemented:
* **Branch Protection Rules**: The `main` branch is fortified against direct commits. All codebase modifications must be proposed and integrated via Pull Requests (PRs).
* **Mandatory Code Review**: At least one approved review from a designated team member is required before any Pull Request can be merged into the production branch.
* **Feature Branching Strategy**: Development tasks are systematically isolated into specific branches (categorized using prefixes such as `feature/`, `chore/`, or `docs/`) prior to integration.

## 3. Server Automation Script
The `scripts/setup.sh` file is a comprehensive Bash automation script engineered to prepare a pristine Ubuntu Linux operating system for application deployment. Upon execution, the script automates the following critical operations:
* **System Synchronization**: Refreshes the local package index and upgrades existing system packages to their latest stable versions.
* **Runtime Initialization**: Installs the Node.js runtime environment (via the official NodeSource repository) and the Node Package Manager (NPM).
* **Web Server Provisioning**: Installs the Nginx web server to function as a reverse proxy for the internal application.
* **Process Manager Deployment**: Installs PM2 globally to daemonize the Node.js application, ensuring process persistence and automatic restarts across server reboots.

## 4. Execution Instructions
To execute the provisioning script on a target Ubuntu virtual machine, execute the following commands in the terminal:

```bash
# Navigate to the scripts directory within Phase 1
cd phase1/scripts/

# Grant execution permissions to the Bash script
chmod +x setup.sh

# Execute the script with administrative privileges
sudo ./setup.sh