##########################
# Universal Requirements #
##########################

## Update base Ubuntu
apt update
apt upgrade -y

apt install unzip wget -y

##########################
# PIA Installation       #
##########################

## Install Openvpn, download PrivateInternetAccess VPN zip
apt install openvpn -y
mkdir openvpn
wget https://www.privateinternetaccess.com/openvpn/openvpn-ip.zip
unzip openvpn*.zip -d openvpn

## Copy keys
cp ~/openvpn/*2048.crt /etc/openvpn
cp ~/openvpn/*2048.pem /etc/openvpn

######
## You may need to add the following
## push "dhcp-option DNS 192.168.1.1"
## push "dhcp-option DNS 192.168.1.10"
######

## Generate credential file
echo "p6148937
qQmNMfgRrb" > /etc/openvpn/login.txt
chmod 0600 /etc/openvpn/login.txt

## Make file modifications so VPN starts on boot and can login correctly
sed 's/\<auth-user-pass\>/& \/etc\/openvpn\/login.txt/' ~/openvpn/US\ Seattle.ovpn >> /etc/openvpn/vpn.conf
sed -e '/LimitNPROC/ s/^#*/#/' -i /lib/systemd/system/openvpn@.service
echo 'AUTOSTART="all"' >> /etc/default/openvpn


## IP Variables for Firewall configuration 
LOCAL_IP=$(ip a | grep 192.168. | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | grep -m1 -ve '255')
VPN_IP=$(cat /etc/openvpn/vpn.conf | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | grep -m1 -ve '255')

## Firewall configuration
ufw enable
ufw default deny incoming
ufw default deny outgoing
​ufw allow in on eth0 to $LOCAL_IP from $LOCAL_IP/24
ufw allow in on tun0
ufw allow out on tun0
ufw allow out on eth0 to $LOCAL_IP/24 from $LOCAL_IP
ufw allow out to $VPN_IP

##########################
##
## ON HOST INSTALLATION
##
## echo "lxc.mount.entry = /dev/net/tun dev/net/tun none bind,create=file" >> /etc/pve/lxc/ID.conf
## chmod 666 /dev/net/tun
##                  
##########################

##########################
# Deluge Installation    #
##########################

## User and Groups Setup
groupadd media
adduser --system  --home /var/lib/deluge deluge
usermod -aG media deluge

## Create deluge homedir
mkdir /var/lib/deluge
chown -R deluge:media /var/lib/deluge

## Install deluge packages
apt install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates -y
add-apt-repository ppa:deluge-team/ppa

apt-get update
apt-get install deluged deluge-web -y

## Firewall configuration
sudo ufw allow 22/tcp
sudo ufw allow 8112/tcp

## Create Systemd script so the main service will run on boot
echo "[Unit]
Description=Deluge Bittorrent Client Daemon
After=network-online.target

[Service]
Type=simple
User=deluge
Group=media
UMask=002
ExecStart=/usr/bin/deluged -d
Restart=on-failure
# Configures the time to wait before service is stopped forcefully.
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/deluged.service

## Create Systemd script so the web service will run on boot
echo "[Unit]
Description=Deluge Bittorrent Client Web Interface
Documentation=man:deluge-web
After=network-online.target deluged.service
Wants=deluged.service

[Service]
Type=simple
UMask=027

ExecStart=/usr/bin/deluge-web -d

Restart=on-failure

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/deluge-web.service


ufw allow 56881:56889/tcp
ufw allow ssh
echo 'net.ipv6.conf.all.disable_ipv6=1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6=1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.lo.disable_ipv6=1' | sudo tee -a /etc/sysctl.conf
sysctl -p
