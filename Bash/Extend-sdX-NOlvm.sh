df -H # Show available data space
echo 1 > /sys/class/block/sda/device/rescan
growpart /dev/sda 2
resize2fs /dev/sda2
df -H