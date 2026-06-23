# Hướng dẫn host server trên GitHub Codespaces + playit.gg + Cloudflare

Mô hình:

```
Người chơi  →  mc.tendomain.com  →  (Cloudflare DNS CNAME/SRV)  →  địa-chỉ.playit.gg  →  playit agent (trong Codespace)  →  Minecraft server :25565
```

- **Codespaces**: máy chủ chạy server (Java + Fabric).
- **playit.gg**: tạo địa chỉ public TCP/UDP cho Minecraft (Codespaces không mở được port TCP thuần ra ngoài, nên cần playit).
- **Cloudflare**: trỏ tên miền dễ nhớ của bạn về địa chỉ playit (CNAME + SRV để khỏi gõ port).

---

## Bước 1 — Đưa code lên GitHub

```bash
git add -A
git commit -m "Add Codespaces + playit hosting setup"
git push
```

## Bước 2 — Mở Codespace

1. Vào repo trên GitHub → nút **Code** (xanh) → tab **Codespaces** → **Create codespace on main**.
2. Chờ build (lần đầu vài phút). Devcontainer sẽ tự cài Java và tải `playit`.
3. Kiểm tra: `java -version` và `~/bin/playit --version`.

> ⚠️ Codespaces miễn phí: ~60–120 giờ/tháng, **tự tắt sau 30 phút không hoạt động**. Server sẽ tắt theo. Đây là môi trường để test/chơi tạm, không phải 24/7.

## Bước 3 — Chạy Minecraft server (Terminal 1)

```bash
bash start-mc.sh
```

Chờ đến khi thấy `Done (x.xxxs)! For help, type "help"`. Server đang nghe ở `localhost:25565`.

## Bước 4 — Chạy playit (Terminal 2)

Mở terminal mới (dấu `+` trong panel Terminal), rồi:

```bash
~/bin/playit
```

- Lần đầu nó in một **link claim** (vd `https://playit.gg/claim/xxxx`). Mở link → đăng nhập/đăng ký playit → **Claim agent**.
- Trên web playit, vào **Tunnels → Add Tunnel → Minecraft Java** → trỏ local về `127.0.0.1:25565`.
- playit sẽ cấp cho bạn một địa chỉ dạng: `something.craft.playit.gg` kèm **port** (vd `:54321`), hoặc một địa chỉ `*.playit.gg`.

Test ngay: dán địa chỉ playit (kèm port) vào Minecraft → Add Server → vào chơi.

## Bước 5 — Trỏ tên miền qua Cloudflare

Giả sử bạn muốn dùng `mc.tendomain.com` và playit cấp `your-id.craft.playit.gg:54321`.

Vào **Cloudflare → Domain của bạn → DNS → Add record**:

**1) CNAME** (DNS only — nhấn tắt đám mây cam thành xám):

| Type  | Name | Target                    | Proxy     |
|-------|------|---------------------------|-----------|
| CNAME | `mc` | `your-id.craft.playit.gg` | DNS only ☁️(xám) |

→ Người chơi vào bằng: `mc.tendomain.com:54321`

**2) SRV** (để khỏi phải gõ port — người chơi chỉ gõ `mc.tendomain.com`):

| Type | Name                    | Service      | Proto  | Priority | Weight | Port    | Target                    |
|------|-------------------------|--------------|--------|----------|--------|---------|---------------------------|
| SRV  | `_minecraft._tcp.mc`    | `_minecraft` | `_tcp` | 0        | 0      | `54321` | `your-id.craft.playit.gg` |

> Form Cloudflare hỏi: **Name** = `mc`, **Service** = `_minecraft`, **Protocol** = `_tcp`, rồi điền Priority/Weight/Port/Target. Cloudflare tự ghép thành `_minecraft._tcp.mc.tendomain.com`.

→ Sau khi DNS lan truyền (vài phút), người chơi chỉ cần gõ **`mc.tendomain.com`** (không port).

> ❗ **Quan trọng**: Cloudflare KHÔNG proxy được Minecraft (TCP thuần) miễn phí — luôn để **DNS only / đám mây xám**. Cloudflare ở đây chỉ làm "danh bạ" trỏ tên miền đẹp về playit. Nếu port playit đổi, chỉ cần sửa lại Port trong bản ghi SRV.

---

## Mẹo

- **Giữ địa chỉ playit cố định**: trong dashboard playit, tunnel của bạn giữ nguyên host/port miễn agent còn được claim → không phải sửa Cloudflare thường xuyên.
- **Chạy nền**: nếu muốn đóng tab terminal mà server vẫn chạy, dùng `tmux`:
  ```bash
  tmux new -s mc 'bash start-mc.sh'      # Ctrl+B rồi D để thoát
  tmux new -s playit '~/bin/playit'
  ```
- **OP cho mình**: trong console server gõ `op <tên_nhân_vật>`.
- Server đang `online-mode=false` (cho phép tài khoản lậu). Muốn chặn, đổi `online-mode=true` trong `server.properties`.
