/etc/sysctl.d/99-gpfs-tuning.conf
# GPFS / Spectrum Scale network + memory tuning

# Increase network buffer sizes
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.ipv4.tcp_window_scaling = 1
# Apply the file with:
sysctl --system

#Udev rules for FC devices

# Create /etc/udev/rules.d/99-gpfs-storage.rules:
# This way every NetApp FC device gets queue_depth=128 and readahead=64 MB automatically.
# Set queue_depth and readahead for NetApp LUNs (vendor "NETAPP")
ACTION=="add|change", SUBSYSTEM=="block", ATTRS{vendor}=="NETAPP", \
  ATTR{device/queue_depth}="128", \
  RUN+="/sbin/blockdev --setra 65536 /dev/%k"
# Apply udev controls with:
udevadm control --reload-rules && udevadm trigger

# Create Gpfs script:
#!/bin/bash
# Apply GPFS tuning parameters for NetApp backend
# Safety check: must be root + GPFS running
if ! mmgetstate -a | grep -q 'active'; then
  echo "GPFS cluster is not active on this node."
  exit 1
fi
echo "Applying GPFS tunables..."
# Ignore LUN count for prefetch
mmchconfig ignorePrefetchLunCount=yes -i
# Worker threads
mmchconfig workerThreads=512 -i
# NSD worker threads
mmchconfig nsdMaxWorkerThreads=128 -i
# Pagepool (example: 32 GB per node — adjust for your RAM)
mmchconfig pagepool=32G -i
# Max throughput cap (set high so GPFS doesn’t throttle)
mmchconfig maxMBpS=16384 -i
# Max TCP connections per node connection
mmchconfig maxTcpConnsPerNodeConn=64 -i
echo "Done. Use 'mmlsconfig' to verify settings."
# Write the file
# Make it executable, chmod 755 $SCRIPT
# Run it, ./gpfs_tune.sh
