#!/usr/bin/env bash
# Chạy 1 lần khi Codespace được tạo: tải playit agent về.
set -e

echo ">> Tải playit agent..."
mkdir -p "$HOME/bin"
curl -L -o "$HOME/bin/playit" \
  https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64
chmod +x "$HOME/bin/playit"

# Thêm vào PATH cho các phiên bash sau này
if ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo ">> Xong. Java: $(java -version 2>&1 | head -1)"
echo ">> playit đã cài tại ~/bin/playit"
