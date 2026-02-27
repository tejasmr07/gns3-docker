#!/bin/bash
set -e

echo "========================================"
echo "  GNS3 Server - Docker Edition"
echo "  College Lab Ready | No VM Required"
echo "========================================"

# Check ubridge capability (needed for network bridging)
if ! capsh --print 2>/dev/null | grep -q "cap_net_admin"; then
    echo "[WARN] NET_ADMIN capability not detected."
    echo "[WARN] Run container with --cap-add NET_ADMIN for full functionality"
fi

echo "[INFO] Starting GNS3 Server on port 3080..."
exec gns3server --host 0.0.0.0 --port 3080 "$@"