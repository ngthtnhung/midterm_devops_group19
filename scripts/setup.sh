
set -e

echo "=== 1. Updating the system ==="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "=== 2. Installing essential OS packages ==="
sudo apt-get install -y curl git ufw nginx unzip

echo "=== 3. Installing Node.js (Runtime) ==="

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "=== 4. Installing Process Manager (PM2) ==="

sudo npm install -g pm2

echo "=== 5. Creating application directory structure ==="
APP_DIR="/var/www/midterm_devops_group19"

sudo mkdir -p $APP_DIR

sudo mkdir -p $APP_DIR/logs
sudo mkdir -p $APP_DIR/public/uploads

sudo chown -R $USER:$USER /var/www/

echo "=== Linux environment preparation completed successfully! ==="
echo "Note: This script does not contain any sensitive credentials or secrets."