#!/bin/bash

# add -f to run ssh in background, parallellize
SSH="ssh -i id_geni_ssh_rsa "

RTR1="cooperdd@pcvm2-17.instageni.illinois.edu -p 22"
NODE11="cooperdd@pc2.instageni.illinois.edu -p 27011"
NODE12="cooperdd@pc2.instageni.illinois.edu -p 27012"

RTR2="cooperdd@pcvm3-18.geni.it.cornell.edu -p 22"
NODE21="cooperdd@pc1.geni.it.cornell.edu -p 30410"
NODE22="cooperdd@pc1.geni.it.cornell.edu -p 30411"

RTR3="cooperdd@pcvm1-14.instageni.idre.ucla.edu -p 22"
NODE31="cooperdd@pc2.instageni.idre.ucla.edu -p 28210"
NODE32="cooperdd@pc2.instageni.idre.ucla.edu -p 28211"

ALL_NODES=("$RTR1" "$RTR2" "$RTR3"
	   "$NODE11" "$NODE12"
	   "$NODE21" "$NODE22"
	   "$NODE31" "$NODE32")

RTRS=("$RTR1" "$RTR2" "$RTR3")

HOSTS=("$NODE11" "$NODE12"
       "$NODE21" "$NODE22"
       "$NODE31" "$NODE32")

# Run commands below
# For example, this clears all IPs from dataplane interfaces
# and resets /etc/hosts

# NOTE: build a map of which ethX interfaces connect to each other
# before flushing!

# e.g.
# rtr1:eth3 < - > rtr3:eth4
# rtr1:eth4 < - > rtr2:eth3
# rtr2:eth4 < - > rtr3:eth3
for h in "${RTRS[@]}"; do
    $SSH $h "hostname; sudo ip addr flush dev eth1; \
    	    	       sudo ip addr flush dev eth2; \
		       sudo ip addr flush dev eth3; \
		       sudo ip addr flush dev eth4; \
		       head -n 1 /etc/hosts | sudo tee /etc/hosts"
done

for h in "${HOSTS[@]}"; do
    $SSH $h "hostname; sudo ip addr flush dev eth1; \
    	     head -n 1 /etc/hosts | sudo tee /etc/hosts"
done

# We will use OpenVSwitch and OpenFlow to configure the routers
# but we still need static "public" routes for all client nodes

$SSH $NODE11 "hostname; sudo ip addr add 10.10.1.11/24 dev eth1; \
                        sudo ip route add 10.10.0.0/16 via 10.10.1.1"
$SSH $NODE12 "hostname; sudo ip addr add 10.10.1.12/24 dev eth1; \
                        sudo ip route add 10.10.0.0/16 via 10.10.1.1"

$SSH $NODE21 "hostname; sudo ip addr add 10.10.2.21/24 dev eth1; \
                        sudo ip route add 10.10.0.0/16 via 10.10.2.1"
$SSH $NODE22 "hostname; sudo ip addr add 10.10.2.22/24 dev eth1; \
                        sudo ip route add 10.10.0.0/16 via 10.10.2.1"

$SSH $NODE31 "hostname; sudo ip addr add 10.10.3.31/24 dev eth1; \
                        sudo ip route add 10.10.0.0/16 via 10.10.3.1"
$SSH $NODE32 "hostname; sudo ip addr add 10.10.3.32/24 dev eth1; \
                        sudo ip route add 10.10.0.0/16 via 10.10.3.1"
