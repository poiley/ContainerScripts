##########################
# Universal Requirements #
##########################

## Update base Ubuntu
apt update
apt upgrade -y

apt install curl gnupg -y

##########################
# Plex Installation      #
##########################

## Enable repository updating for supported Linux server distributions per https://support.plex.tv/articles/235974187-enable-repository-updating-for-supported-linux-server-distributions/
echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
curl https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -

## Refresh repositories
apt update
apt install plexmediaserver -y

## Ensure media folders are readable 
# chmod -R 777 /storage/Movies
# chmod -R 777 /storage/TV\ Shows
# chmod -R 777 /storage/Music

chown -R plex:plex /storage/Movies
chown -R plex:plex /storage/TV\ Shows
chown -R plex:plex /storage/Music