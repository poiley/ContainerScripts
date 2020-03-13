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
# Jackett Installation   #
##########################

## User and Groups Setup
groupadd media
adduser --system --shell=/sbin/nologin jackett
usermod -aG media jackett

## Prerequisites for Jackett per https://github.com/dotnet/core/blob/master/Documentation/linux-prereqs.md
apt install libicu60 openssl -y 

curl -L -O $( curl -s https://api.github.com/repos/Jackett/Jackett/releases | grep LinuxAMDx64.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )
tar -xvzf Jackett.Binaries.LinuxAMDx64.tar.gz
mv Jackett /opt

## File permissions for installation directory
chmod -R 775 /opt/Jackett
chown -R jackett:media /opt/Jackett

## Run Jackett on boot with pre-written script
/opt/Jackett/install_service_systemd.sh

systemctl daemon-reload
systemctl enable jackett