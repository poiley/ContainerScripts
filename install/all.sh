#!/bin/bash
declare -a services=("radarr" "sonarr" "lidarr" "jackett" "deluge" "plex" "tautulli" "ombi" "heimdall")

for service in "${services[@]}" do
    echo "Working on $service"
    id=$(pct list | tail -n +2 | grep $service | cut -f1 -d' ')

    pct push $id /root/scripts/install/$service.sh /root/$service.sh
    pct exec $id -- bash -c "chmod +x /root/$service.sh; /root/$service.sh &"
done
