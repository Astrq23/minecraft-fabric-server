#!/usr/bin/env bash
# Khởi động Minecraft Fabric server (dùng cho Codespaces / máy local).
set -e
cd "$(dirname "$0")"

# Tự động chấp nhận EULA
echo "eula=true" > eula.txt

# RAM: chỉnh -Xmx theo máy (Codespaces 8GB -> 6G là hợp lý)
exec java -Xms1G -Xmx6G -jar fabric-server-launch.jar nogui
