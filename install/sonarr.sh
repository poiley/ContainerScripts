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
# Sonarr Installation    #
##########################

## User and Groups Setup
groupadd media
adduser --system --shell=/sbin/nologin sonarr
usermod -a -G media sonarr

## File permissions for TV Shows folder
mkdir /storage/TV\ Shows
chmod -R 775 /storage/TV\ Shows
chown -R sonarr:media /storage/TV\ Shows

## Add Sonarr's Repository
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xA236C58F409091A18ACA53CBEBFF6B99D9B78493
echo "deb http://apt.sonarr.tv/ master main" | tee /etc/apt/sources.list.d/sonarr.list

## Install Sonarr
apt update
apt install nzbdrone -y

## File permissions for installation directory
chmod -R 775 /opt/NzbDrone
chown -R sonarr:media /opt/NzbDrone

## Create Systemd script so the service will run on boot
echo "[Unit]
Description=Sonarr Daemon
After=network.target

[Service]
# Change the user and group variables here.
User=sonarr
Group=media
UMask=002

Type=simple
ExecStart=/usr/bin/mono /opt/NzbDrone/NzbDrone.exe -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/sonarr.service

## Initialize and start service
systemctl enable sonarr.service
systemctl start sonarr.service