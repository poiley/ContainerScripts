
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
apt install curl mediainfo -y

cd

## Download, unzip, and move install to /opt/Radarr
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