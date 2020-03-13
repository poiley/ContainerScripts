##########################
# Universal Requirements #
##########################

## Update base Ubuntu
apt update
apt upgrade -y

apt install curl wget gnupg -y

##########################
# Ombi Installation      #
##########################

## Add apt repository
echo "deb [arch=amd64,armhf] http://repo.ombi.turd.me/stable/ jessie main" | tee "/etc/apt/sources.list.d/ombi.list"
wget -qO - https://repo.ombi.turd.me/pubkey.txt | sudo apt-key add -

apt update
apt install ombi -y
