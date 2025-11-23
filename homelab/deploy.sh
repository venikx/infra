#!/usr/bin/env sh

echo "Rebuilding:" $CHAKRA_IP
nixos-rebuild switch --fast --flake .#chakra \
    --target-host $CHAKRA_IP \
    --build-host $CHAKRA_IP \
    --option eval-cache false

echo "Rebuilding:" $MIRAGE_IP
nixos-rebuild switch --fast --flake .#mirage \
    --target-host $MIRAGE_IP \
    --build-host $MIRAGE_IP \
    --option eval-cache false

echo "Rebuilding:" $VM_PROD_MEDIA_01_IP
nixos-rebuild switch --flake .#vm-prod-media-01 \
    --target-host $VM_PROD_MEDIA_01_IP
