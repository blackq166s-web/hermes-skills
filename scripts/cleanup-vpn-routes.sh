#!/bin/bash
# Clean up orphaned VPN/proxy routes (split-tunnel leftovers)
# Routes through utun* interfaces that go to 198.18.x.x or 198.19.x.x are proxy residue

echo "[cleanup-vpn-routes] $(date)"

cleaned=0
while IFS= read -r line; do
    # Parse: network gateway flags netif
    read -r network gateway rest <<< "$line"
    # Skip local interface routes
    [[ "$gateway" == "198.19.0.1" && "$network" == "198.19.0.1" ]] && continue
    [[ "$gateway" == "198.18.0.1" && "$network" == "198.18.0.1" ]] && continue

    if [[ "$gateway" == 198.19.* ]] || [[ "$gateway" == 198.18.* ]]; then
        # Convert CIDR notation (e.g., 128.0/1 → 128.0.0.0/1)
        net_clean=$(echo "$network" | sed 's/^\([0-9]*\)$/\1.0.0.0\/8/')
        echo "  Deleting route: -net $net_clean via $gateway"
        sudo route delete -net "$net_clean" 2>&1
        ((cleaned++))
    fi
done < <(netstat -rn -f inet | grep utun)

if [ $cleaned -eq 0 ]; then
    echo "  No VPN residue found. Clean."
else
    echo "  Cleaned $cleaned orphaned routes."
fi
