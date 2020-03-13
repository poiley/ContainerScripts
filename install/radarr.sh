##########################
# Universal Requirements #
##########################

## Update base Ubuntu
apt update
apt upgrade -y

apt install curl gnupg ca-certificates -y

## Add Mono Repositories
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list

## Refresh repositories and install mono-devel
apt update
apt install mono-devel -y

##########################
# Radarr Installation    #
##########################

## User and Groups Setup
groupadd media
adduser --system --shell=/sbin/nologin radarr
usermod -aG media radarr

## File permissions for Movies folder
mkdir /storage/Movies
chmod -R 775 /storage/Movies
chown -R radarr:media /storage/Movies

## Installing service prerequisites
apt install mediainfo -y

## Download, unzip, and move install to /opt/Radarr
cd
curl -L -O $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )
tar -xvzf Radarr.develop.*.linux.tar.gz
mv Radarr /opt

## File permissions for installation directory
chmod -R 775 /opt/Radarr
chown -R radarr:media /opt/Radarr

## Create Systemd script so the service will run on boot
echo "[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
# Change the user and group variables here.
User=radarr
Group=media
UMask=002

Type=simple

# Change the path to Radarr or mono here if it is in a different location for you.
ExecStart=/usr/bin/mono --debug /opt/Radarr/Radarr.exe -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure

# These lines optionally isolate (sandbox) Radarr from the rest of the system.
# Make sure to add any paths it might use to the list below (space-separated).
#ReadWritePaths=/opt/Radarr /path/to/movies/folder
#ProtectSystem=strict
#PrivateDevices=true
#ProtectHome=true

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/radarr.service

## Initialize and start service
systemctl enable radarr.service
systemctl start radarr.service