# 🍅 PomoLocal

**"Sıfır Sunucu, Tam Gizlilik, Maksimum Odak."**

PomoLocal, verilerinizi yalnızca kendi cihazınızda saklayan, internet bağlantısı gerektirmeyen, minimalist bir Pomodoro zamanlayıcı uygulamasıdır.

## Platformlar

- 🍎 macOS
- 🪟 Windows
- 📱 Android (tablet optimizeli)

## Özellikler

- ⏱️ Özelleştirilebilir Pomodoro döngüsü (odaklanma / kısa mola / uzun mola)
- 📊 Günlük ve haftalık istatistikler
- 🔔 Sistem bildirimleri
- 🌙 Açık / koyu tema desteği
- 🔒 Sıfır internet, sıfır telemetri — verileriniz sadece sizde

## Teknik Stack

| Teknoloji | Kullanım |
|---|---|
| Flutter | Cross-platform framework |
| Dart | Uygulama dili |
| Isar | Yerel NoSQL veritabanı |
| Provider | State management |
| fl_chart | İstatistik grafikleri |

## Kurulum

```bash
git clone https://github.com/elvanakln/ponipom.git
cd ponipom
flutter pub get
flutter run
```

## Gizlilik

PomoLocal hiçbir veriyi dışarıya göndermez. HTTP istemcisi, analitik veya telemetri paketi içermez. Uygulama kaldırıldığında tüm veriler silinir.

## Lisans

MIT
