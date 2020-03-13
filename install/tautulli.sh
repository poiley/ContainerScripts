##########################
# Universal Requirements #
##########################

## Update base Ubuntu
apt update
apt upgrade -y

apt install git-core curl gnupg python python-setuptools tzdata -y

##########################
# Tautulli Installation  #
##########################

## Clone Repository into /opt folder
git clone https://github.com/Tautulli/Tautulli.git /opt/Tautulli

## Set up Users and Groups
addgroup media
adduser --system --no-create-home tautulli --ingroup media
chown tautulli:media -R /opt/Tautulli

## Copy Systemd files and configure group
cp /opt/Tautulli/init-scripts/init.systemd /etc/systemd/system/tautulli.service
sed -i 's/Group=tautulli/Group=media/g' /etc/systemd/system/tautulli.service

## Enable service, then start service
systemctl enable tautulli
systemctl start tautulli