#!/bin/bash

# list of container ids we need to iterate through 
ct_id=($(pct list | tail -n +2 | cut -f1 -d' '))
ct_name=($(pct list | tail -n +2 |  cut -d ' ' -f 26-))

# for all ids in ct_id, get the ip. if the ip exists, then add it to lan.list
for i in "${!ct_id[@]}"; do
    if [[ ${ct_id[$i]} != 105 ]] ; then
    ip=$(pct exec ${ct_id[$i]} -- bash -c "ip a | grep 192.168. | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | grep -ve '255'")
    if [[ ${#ip} != 0 ]] ; then
      echo "$ip   ${ct_name[$i]}.lan    ${ct_name[$i]}"
      echo "$ip   ${ct_name[$i]}.lan    ${ct_name[$i]}" >> /root/lan.list
    fi
    fi
done
