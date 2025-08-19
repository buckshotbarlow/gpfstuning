#!/bin/bash
#
# GPFS / Spectrum Scale Config Summary Script
#

# Commands to run
declare -A PARAMS=(
  ["Ignore Prefetch LUN Count"]="ignorePrefetchLunCount"
  ["Worker/Pagepool Threads"]="Threads"
  ["Max MB per Second"]="maxMBpS"
  ["NSD Max Worker Threads"]="nsdMaxWorkerThreads"
  ["Pagepool"]="pagepool"
  ["Max TCP Conns Per NodeConn"]="maxTcpConnsPerNodeConn"
)

echo "======================================="
echo " GPFS Configuration Summary (mmfsadm) "
echo "======================================="

for LABEL in "${!PARAMS[@]}"; do
    VALUE=$(mmfsadm dump config | grep -i "${PARAMS[$LABEL]}")
    if [ -n "$VALUE" ]; then
        echo -e "\n$LABEL:"
        echo "  $VALUE"
    else
        echo -e "\n$LABEL:"
        echo "  Not set / not found"
    fi
done

echo -e "\n======================================="
echo " Done."
echo "======================================="
