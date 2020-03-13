##########################
# Universal Requirements #
##########################

## Update base Ubuntu
apt update
apt upgrade -y

apt install curl gnupg ca-certificates libchromaprint-tools -y

## Add Mono Repositories
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list

## Refresh repositories and install mono-devel
apt update
apt install mono-devel -y

##########################
# Lidarr Installation    #
##########################

## User and Groups Setup
groupadd media
adduser --system --shell=/sbin/nologin lidarr
usermod -a -G media lidarr

## File permissions for Music folder
mkdir /storage/Music
chmod -R 775 /storage/Music
chown -R lidarr:media /storage/Music

## Download, unzip, and move install to /opt/Lidarr
curl -L -O $( curl -s https://api.github.com/repos/Lidarr/Lidarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )
tar -xvzf Lidarr.*.*.linux.tar.gz
mv Lidarr /opt

## File permissions for installation directory
chmod -R 775 /opt/Lidarr
chown -R lidarr:media /opt/Lidarr

## Create Systemd script so the service will run on boot
echo "[Unit]
Description=Lidarr Daemon
After=network.target

[Service]
User=lidarr
Group=media
UMask=002
Type=simple

ExecStart=/usr/bin/mono /opt/Lidarr/Lidarr.exe -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/lidarr.service

## Initialize and start service
systemctl enable lidarr.service
systemctl start lidarr.service