#!/usr/bin/env bash
set -o errexit
set -o xtrace

echo 0 | sudo tee /sys/bus/usb/devices/3-1.7/authorized
sleep 2
echo 1 | sudo tee /sys/bus/usb/devices/3-1.7/authorized

exit 0

