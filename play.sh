#!/usr/bin/env bash
# Một lệnh: bật playit (nền) + bật Minecraft server (foreground).
set -e
cd "$(dirname "$0")"

PLAYIT_BIN="$HOME/bin/playit"
PLAYIT_CFG="$HOME/.config/playit_gg/playit.toml"

# 1) Tải playit nếu chưa có
if [ ! -x "$PLAYIT_BIN" ]; then
  echo ">> Tải playit agent..."
  mkdir -p "$HOME/bin"
  curl -L -o "$PLAYIT_BIN" https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
  chmod +x "$PLAYIT_BIN"
fi

# 2) Ghi secret từ Codespaces secret PLAYIT_SECRET (nếu có và chưa có file)
mkdir -p "$(dirname "$PLAYIT_CFG")"
if [ -n "$PLAYIT_SECRET" ] && [ ! -f "$PLAYIT_CFG" ]; then
  printf 'secret_key = "%s"\n' "$PLAYIT_SECRET" > "$PLAYIT_CFG"
  echo ">> Đã ghi playit secret từ biến PLAYIT_SECRET."
fi

# 3) Bật playit chạy nền
if [ ! -f "$PLAYIT_CFG" ]; then
  echo "!! CHƯA có playit secret ($PLAYIT_CFG)."
  echo "   Lấy secret tại https://playit.gg (Docker agent) rồi chạy:"
  echo "   printf 'secret_key = \"KEY\"\\n' > $PLAYIT_CFG"
  echo "   ... rồi chạy lại ./play.sh"
  exit 1
fi
pkill -f 'playit --socket-path' 2>/dev/null || true
sleep 1
nohup "$PLAYIT_BIN" --socket-path /tmp/playit.sock > playit.log 2>&1 &
echo ">> playit đang chạy nền (xem log: tail -f playit.log)"

# 4) Bật Minecraft server (foreground)
echo "eula=true" > eula.txt
echo ">> Khởi động Minecraft server..."
exec java -Xms1G -Xmx6G -jar fabric-server-launch.jar nogui
