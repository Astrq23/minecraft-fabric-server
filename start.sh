#!/bin/bash
set -e

cd /server

# Tự động chấp nhận EULA
echo "eula=true" > eula.txt

# Khởi động Minecraft Fabric Server
java -Xms1G -Xmx4G -jar fabric-server-launch.jar nogui