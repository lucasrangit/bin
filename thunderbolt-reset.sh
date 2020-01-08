#!/usr/bin/env bash
set -o xtrace
echo 1 | sudo tee /sys/bus/pci/devices/0000\:00\:1d.6/remove > /dev/null
sleep 1
echo 1 | sudo tee /sys/bus/pci/rescan > /dev/null

