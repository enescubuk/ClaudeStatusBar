## 2026-09-01

Proje fikri: macOS menu bar'da (top bar) referans görsellerdeki gibi tek bir
renkli nokta ikonu. Claude Code CLI session durumunu gösterecek:

- **Sarı nokta** — session çalışıyor (Claude bir işi işliyor).
- **Yeşil nokta** — session bitti / bekliyor, iş tamamlandı.
- **Kırmızı nokta** — Claude kullanıcıya soru soruyor / onay bekliyor (permission prompt, AskUserQuestion vb).

Referans görseller `image-cache`'te: sarı/turuncu, mint yeşil, kırmızı-mercan
nokta örnekleri — kesin hex kodlar asset üretilirken görsellerden birebir
alınacak (yaklaşık: sarı `#F5B573`, yeşil `#7EEBC5`, kırmızı `#FF7B72`).

### Durum tespiti — olası yaklaşım
Claude Code CLI'nin hook sistemi kullanılabilir (`settings.json` → `hooks`):
- `SessionStart` / `PreToolUse` → sarı (çalışıyor)
- `Stop` / `SessionEnd` → yeşil (bitti)
- `Notification` (permission/izin istemi, soru) → kırmızı

Hook'lar bir shell script tetikleyip local bir dosyaya veya unix socket'e
durum yazabilir; menu bar app bunu (FSEvents ile dosya izleyerek veya socket
dinleyerek) okuyup `NSStatusItem` ikonunu günceller. Birden fazla paralel
session olursa (birden fazla terminal sekmesi) durumların nasıl birleştirileceği
(en "acil" olan mı gösterilecek — kırmızı > sarı > yeşil önceliği gibi)
sonraki adımda netleştirilmeli.

### Sonraki adım
Xcode projesini kur (SwiftUI + `NSStatusItem`), hook → dosya yazma mekanizmasını
prototiple, tek session için uçtan uca çalıştır.
