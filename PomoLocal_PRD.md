# PomoLocal — Proje Dokümantasyonu (PRD)

**Versiyon:** 1.0
**Tarih:** 15 Mart 2026
**Motto:** "Sıfır Sunucu, Tam Gizlilik, Maksimum Odak."

---

## 1. Ürün Özeti

PomoLocal, kullanıcının tüm verilerini yalnızca kendi cihazında saklayan (local-first), internet bağlantısı gerektirmeyen, minimalist bir Pomodoro zamanlayıcı uygulamasıdır.

**Hedef Platformlar:**
- macOS (masaüstü)
- Windows (masaüstü)
- Android (tablet optimizeli)

**Hedef Kullanıcı:** Odaklanma tekniği kullanan öğrenciler, yazılımcılar ve bilgi işçileri.

---

## 2. Teknik Stack

| Katman | Teknoloji | Versiyon | Gerekçe |
|---|---|---|---|
| Framework | Flutter | 3.x (stable) | Tek kod tabanından 3 platforma derleme |
| Dil | Dart | 3.x | Flutter'ın ana dili |
| Veritabanı | Isar | 4.x | Hive'ın halefi, aktif bakım, hızlı NoSQL |
| State Management | Provider | 6.x | MVP için yeterli basitlik |
| Bildirimler | flutter_local_notifications | latest | Masaüstü + mobil desteği |
| Dosya Yolu | path_provider | latest | Platforma özgü uygulama dizini |
| Grafikler | fl_chart | latest | Haftalık bar chart için |
| Tray (masaüstü) | system_tray | latest | **Faz 2 — MVP sonrası** |

### 2.1 Kullanılmayacak Paketler (Gizlilik Garantisi)

Aşağıdaki paket türleri projede **kesinlikle** yer almayacaktır:

- `http`, `dio`, `retrofit` veya herhangi bir HTTP istemcisi
- `firebase_*` (Analytics, Crashlytics, Auth dahil)
- `sentry`, `amplitude`, `mixpanel` veya herhangi bir telemetri
- `cloud_firestore`, `supabase` veya herhangi bir uzak veritabanı
- `google_sign_in`, `sign_in_with_apple` veya herhangi bir kimlik doğrulama

---

## 3. Desteklenen Platformlar ve Gereksinimler

### 3.1 macOS
- Minimum: macOS 10.14 (Mojave)
- Derleme: Xcode + CocoaPods gerekli
- Bildirimler: macOS Notification Center üzerinden

### 3.2 Windows
- Minimum: Windows 10 (1809+)
- Derleme: Visual Studio 2022 + C++ Desktop Development workload
- Bildirimler: Windows Toast Notifications üzerinden

### 3.3 Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34
- Tablet optimizasyonu: Responsive layout, geniş ekran düzeni
- Bildirimler: Android Notification Channel üzerinden

---

## 4. Fonksiyonel Gereksinimler (MVP)

### 4.1 Zamanlayıcı (Timer)

| Özellik | Açıklama |
|---|---|
| Odaklanma süresi | Varsayılan 25 dakika (özelleştirilebilir) |
| Kısa mola | Varsayılan 5 dakika (özelleştirilebilir) |
| Uzun mola | Varsayılan 15 dakika (özelleştirilebilir) |
| Uzun mola aralığı | Her 4 pomodoro'dan sonra |
| Kontroller | Başlat, Duraklat, Sıfırla |
| Otomatik geçiş | Odaklanma bitince molaya, mola bitince odaklanmaya geçiş (kullanıcı onayıyla) |
| Arka plan davranışı | Zaman damgası yaklaşımı (aşağıda detaylı) |

### 4.2 Arka Plan Timer Stratejisi (Kritik)

`Timer.periodic` Android'de arka planda güvenilir çalışmaz. Bu yüzden **zaman damgası yaklaşımı** kullanılacaktır:

```
BAŞLAT butonuna basıldığında:
  1. endTime = DateTime.now().add(kalanSüre)
  2. endTime'ı Isar'a kaydet
  3. Timer.periodic(1 saniye) ile UI güncelle

Uygulama arka plana geçtiğinde (AppLifecycleState.paused):
  4. Timer'ı iptal et, endTime zaten kayıtlı

Uygulama öne geldiğinde (AppLifecycleState.resumed):
  5. Isar'dan endTime'ı oku
  6. remaining = endTime - DateTime.now()
  7. remaining <= 0 ise → süre bitmiş, bildirim tetikle
  8. remaining > 0 ise → kalan süreyle Timer'ı yeniden başlat
```

Bu yaklaşımın avantajları:
- Foreground service gerektirmez
- Pil dostu
- Tüm platformlarda aynı mantık

### 4.3 Yerel Veri Saklama

Her tamamlanan seans için kaydedilecek veriler:

```dart
@collection
class Session {
  Id id = Isar.autoIncrement;
  DateTime startTime;      // Seansın başlangıç zamanı
  int durationMinutes;     // Planlanan süre (dakika)
  String type;             // 'focus' | 'short_break' | 'long_break'
  bool completed;          // Süre tamamlandı mı, yoksa iptal mi?
}
```

### 4.4 Bildirim Sistemi

- Süre bittiğinde **sistem bildirimi** gönderilecek (özel ses dosyası yok)
- Masaüstünde (macOS/Windows): Native toast/banner bildirimi
- Android: Notification channel üzerinden standart bildirim
- Bildirim içeriği: "Odaklanma süresi bitti! Mola zamanı." / "Mola bitti! Odaklanma zamanı."

### 4.5 İstatistikler (Dashboard)

| Metrik | Açıklama |
|---|---|
| Bugünkü toplam | Bugün tamamlanan pomodoro sayısı |
| Bugünkü süre | Bugün toplam odaklanma süresi (dakika) |
| Haftalık grafik | Son 7 günün günlük pomodoro sayısı (bar chart) |
| Mevcut seri | Arka arkaya kaç gün en az 1 pomodoro yapıldı |

### 4.6 Ayarlar

| Ayar | Tür | Varsayılan |
|---|---|---|
| Odaklanma süresi | Slider (1-60 dk) | 25 dk |
| Kısa mola süresi | Slider (1-30 dk) | 5 dk |
| Uzun mola süresi | Slider (1-60 dk) | 15 dk |
| Uzun mola aralığı | Dropdown (2-8) | 4 |
| Otomatik başlatma | Toggle | Kapalı |
| Bildirim | Toggle | Açık |

Ayarlar Isar'da `Settings` collection'ında saklanacak.

---

## 5. Mimari Yapı (Clean Architecture)

### 5.1 Klasör Yapısı

```
pomolocal/
├── lib/
│   ├── main.dart                          # Uygulama giriş noktası, Isar init
│   ├── app.dart                           # MaterialApp, tema, routing
│   │
│   ├── core/
│   │   ├── constants.dart                 # Varsayılan süreler, renkler, stringler
│   │   ├── theme.dart                     # Açık/koyu tema tanımları
│   │   └── enums.dart                     # TimerState, SessionType enum'ları
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── session_model.dart         # Isar Session collection
│   │   │   └── settings_model.dart        # Isar Settings collection
│   │   └── repositories/
│   │       ├── session_repository.dart    # Session CRUD işlemleri
│   │       └── settings_repository.dart   # Settings okuma/yazma
│   │
│   ├── logic/
│   │   ├── timer_service.dart             # Geri sayım motoru (stream tabanlı)
│   │   ├── notification_service.dart      # Platform-agnostic bildirim yönetimi
│   │   └── providers/
│   │       ├── timer_provider.dart        # Timer state yönetimi (ChangeNotifier)
│   │       ├── stats_provider.dart        # İstatistik hesaplamaları
│   │       └── settings_provider.dart     # Ayar state yönetimi
│   │
│   └── ui/
│       ├── screens/
│       │   ├── timer_screen.dart          # Ana zamanlayıcı ekranı
│       │   ├── stats_screen.dart          # İstatistik/dashboard ekranı
│       │   └── settings_screen.dart       # Ayarlar ekranı
│       └── widgets/
│           ├── circular_timer.dart        # Dairesel progress göstergesi
│           ├── timer_controls.dart        # Başlat/Duraklat/Sıfırla butonları
│           ├── stat_card.dart             # Tekil istatistik kartı
│           └── weekly_chart.dart          # Haftalık bar chart widget
│
├── android/
│   └── app/src/main/AndroidManifest.xml   # İzinler burada
├── macos/
│   └── Runner/                            # macOS-specific ayarlar
├── windows/
│   └── runner/                            # Windows-specific ayarlar
├── pubspec.yaml                           # Paket bağımlılıkları
└── test/
    ├── timer_service_test.dart
    ├── session_repository_test.dart
    └── settings_repository_test.dart
```

### 5.2 Katman Sorumlulukları

**Data Layer** → Isar veritabanı ile iletişim. Model tanımları ve CRUD.
- UI hakkında hiçbir şey bilmez
- Sadece repository sınıfları dışarıya açılır

**Logic Layer** → İş mantığı. Timer motoru, bildirim koordinasyonu, state yönetimi.
- Data layer'ı repository'ler üzerinden kullanır
- UI'a Provider aracılığıyla veri sağlar

**UI Layer** → Ekranlar ve widget'lar. Kullanıcı etkileşimi.
- Logic layer'a Provider üzerinden erişir
- Doğrudan Data layer'a erişmez

### 5.3 Veri Akış Diyagramı

```
[Kullanıcı "Başlat"a basar]
       │
       ▼
[TimerProvider] ──► [TimerService.start()]
       │                    │
       │                    ├── endTime hesapla
       │                    ├── Isar'a endTime kaydet
       │                    └── Stream<int> (kalan saniye) yayınla
       │
       ▼
[UI güncellenir] ◄── Stream dinleyerek her saniye
       │
       ▼ (süre bittiğinde)
[TimerProvider] ──► [NotificationService.show()]
       │            [SessionRepository.save()]
       │
       ▼
[Otomatik sonraki aşamaya geç veya kullanıcıya sor]
```

---

## 6. UI/UX Tasarım Rehberi

### 6.1 Ekranlar

**Timer Screen (Ana Ekran)**
```
┌─────────────────────────────┐
│                             │
│     [Odaklanma / Mola]      │  ← Mevcut aşama etiketi
│                             │
│       ╭───────────╮         │
│      │             │        │
│      │   24:59     │        │  ← Dairesel progress bar içinde kalan süre
│      │             │        │
│       ╰───────────╯         │
│                             │
│    [▶ Başlat]  [↺ Sıfırla]  │  ← Kontrol butonları
│                             │
│   Pomodoro: 2/4             │  ← Mevcut döngü durumu
│                             │
├─────────────────────────────┤
│  🕐 Timer  │ 📊 Stats │ ⚙  │  ← Bottom navigation
└─────────────────────────────┘
```

**Stats Screen**
```
┌─────────────────────────────┐
│  Bugün                      │
│  ┌──────┐ ┌──────┐         │
│  │  6   │ │ 150  │         │  ← Pomodoro sayısı / Toplam dakika
│  │ pomo │ │  dk  │         │
│  └──────┘ └──────┘         │
│                             │
│  Bu Hafta                   │
│  ████                       │
│  ██████                     │
│  ███                        │  ← Haftalık bar chart
│  █████████                  │
│  ██████                     │
│  ████████                   │
│  ██                         │
│  Pzt Sal Çar Per Cum Cmt Paz│
│                             │
│  🔥 Seri: 5 gün             │
│                             │
├─────────────────────────────┤
│  🕐 Timer  │ 📊 Stats │ ⚙  │
└─────────────────────────────┘
```

**Settings Screen**
```
┌─────────────────────────────┐
│  Ayarlar                    │
│                             │
│  Odaklanma Süresi           │
│  ──●────────────── 25 dk    │  ← Slider
│                             │
│  Kısa Mola                  │
│  ──●────────────── 5 dk     │
│                             │
│  Uzun Mola                  │
│  ──●────────────── 15 dk    │
│                             │
│  Uzun Mola Aralığı          │
│  [4 pomodoro ▼]             │  ← Dropdown
│                             │
│  Otomatik Başlatma          │
│  [  ○ ]                     │  ← Toggle
│                             │
│  Bildirimler                │
│  [  ● ]                     │
│                             │
├─────────────────────────────┤
│  🕐 Timer  │ 📊 Stats │ ⚙  │
└─────────────────────────────┘
```

### 6.2 Tema

- **Renk Paleti:**
  - Odaklanma: Kırmızı/Turuncu tonları (#E53935 ana, #FF7043 ikincil)
  - Kısa Mola: Yeşil tonları (#43A047 ana)
  - Uzun Mola: Mavi tonları (#1E88E5 ana)
  - Arka plan: #FAFAFA (açık) / #121212 (koyu)

- **Tipografi:** Sistem fontu (platformla uyumlu görünüm)
- **Koyu mod desteği:** Sistem temasını takip etsin (manuel geçiş opsiyonlu)

### 6.3 Responsive / Tablet Uyumu

- Timer ekranındaki dairesel gösterge ekran boyutuna göre ölçeklenecek
- Tablet modunda Stats ekranı yan yana kart düzeni kullanabilir
- `LayoutBuilder` veya `MediaQuery` ile breakpoint'ler:
  - < 600px: Mobil düzen (tek kolon)
  - ≥ 600px: Tablet düzen (iki kolon grid)
  - ≥ 1024px: Masaüstü düzen (geniş merkez panel)

---

## 7. Platform-Specific Konfigürasyonlar

### 7.1 Android — `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

Başka hiçbir izin eklenmeyecek. `INTERNET` izni açıkça **eklenmeyecek**.

### 7.2 macOS — `macos/Runner/DebugProfile.entitlements`

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
```

Ağ erişimi entitlement'ı **eklenmeyecek**.

### 7.3 Windows

Özel konfigürasyon gerekmiyor. `flutter_local_notifications` Windows desteğini otomatik sağlar.

---

## 8. pubspec.yaml (Bağımlılıklar)

```yaml
name: pomolocal
description: "Sıfır Sunucu, Tam Gizlilik, Maksimum Odak."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.0.0

dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.0.0

  # Yerel Veritabanı
  isar: ^4.0.0
  isar_flutter_libs: ^4.0.0

  # Bildirimler
  flutter_local_notifications: ^17.0.0

  # Dosya Yolları
  path_provider: ^2.0.0

  # Grafikler
  fl_chart: ^0.68.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  isar_generator: ^4.0.0
  build_runner: ^2.0.0

flutter:
  uses-material-design: true
```

---

## 9. Geliştirme Fazları (Claude CLI Prompt Sıralaması)

Her faz bağımsız bir Claude CLI oturumunda yapılacak. Her fazın sonunda çalışan, test edilebilir bir çıktı olmalı.

### Faz 1 — Proje İskeleti ve Veri Katmanı
**Hedef:** Flutter projesi oluştur, Isar entegrasyonu yap, modelleri tanımla.
**Çıktı:** `flutter run` ile boş bir uygulama açılır, Isar başlatılır.
**Dosyalar:**
- `main.dart`, `app.dart`
- `core/constants.dart`, `core/enums.dart`
- `data/models/session_model.dart`
- `data/models/settings_model.dart`
- `data/repositories/session_repository.dart`
- `data/repositories/settings_repository.dart`
- `pubspec.yaml`

### Faz 2 — Timer Motoru (Logic Layer)
**Hedef:** Stream tabanlı geri sayım motoru. UI'sız, sadece mantık.
**Çıktı:** Unit test ile timer'ın doğru çalıştığı doğrulanır.
**Dosyalar:**
- `logic/timer_service.dart`
- `logic/providers/timer_provider.dart`
- `logic/providers/settings_provider.dart`
- `test/timer_service_test.dart`

### Faz 3 — Timer Ekranı (UI)
**Hedef:** Dairesel progress bar, kontrol butonları, bottom navigation.
**Çıktı:** Uygulama açıldığında çalışan bir timer görünür.
**Dosyalar:**
- `ui/screens/timer_screen.dart`
- `ui/widgets/circular_timer.dart`
- `ui/widgets/timer_controls.dart`
- `core/theme.dart`

### Faz 4 — Seans Kaydetme ve İstatistikler
**Hedef:** Tamamlanan seansları Isar'a kaydet. Stats ekranını oluştur.
**Çıktı:** Pomodoro tamamlandığında kaydedilir, Stats ekranında görünür.
**Dosyalar:**
- `logic/providers/stats_provider.dart`
- `ui/screens/stats_screen.dart`
- `ui/widgets/stat_card.dart`
- `ui/widgets/weekly_chart.dart`

### Faz 5 — Bildirim Sistemi
**Hedef:** Platform-agnostic bildirim servisi. Süre bittiğinde sistem bildirimi.
**Çıktı:** Timer bitince bildirimi görünür (her 3 platformda).
**Dosyalar:**
- `logic/notification_service.dart`
- Platform-specific konfigürasyonlar (AndroidManifest, entitlements)

### Faz 6 — Ayarlar Ekranı
**Hedef:** Süre özelleştirme, toggle'lar, ayarların Isar'da saklanması.
**Çıktı:** Ayarlar değiştirildiğinde timer süreleri güncellenir.
**Dosyalar:**
- `ui/screens/settings_screen.dart`

### Faz 7 — Arka Plan Davranışı ve Son Cilalama
**Hedef:** AppLifecycleState yönetimi, zaman damgası mantığı, tablet responsive düzen.
**Çıktı:** Uygulama arka plana atılıp açıldığında timer doğru kalır.
**Dosyalar:**
- Timer provider'a lifecycle hook'ları eklenmesi
- Responsive layout iyileştirmeleri

---

## 10. Güvenlik ve Gizlilik Politikası

1. **Sıfır ağ erişimi:** Uygulama hiçbir koşulda internet bağlantısı kurmaz.
2. **Sıfır telemetri:** Kullanım verisi, kilitlenme raporu veya analitik toplanmaz.
3. **Yerel veri:** Tüm veriler cihazın uygulama dizininde Isar dosyası olarak saklanır.
4. **Minimum izin:** Yalnızca bildirim ve ekran uyandırma izinleri istenir.
5. **Silme hakkı:** Kullanıcı uygulamayı kaldırdığında tüm veriler silinir (uygulama dizini).

---

## 11. Varsayımlar ve Kısıtlar

| # | Varsayım / Kısıt |
|---|---|
| 1 | Cihazlar arası senkronizasyon yapılmayacak |
| 2 | Kullanıcı hesabı / giriş sistemi yok |
| 3 | Özel ses dosyası kullanılmayacak (sistem bildirimi yeterli) |
| 4 | Tray icon desteği MVP'de yok (Faz 2 özelliği) |
| 5 | i18n (çoklu dil) MVP'de yok — UI dili Türkçe |
| 6 | iOS desteği bu fazda kapsam dışı |
| 7 | Veri dışa/içe aktarma MVP'de yok |

---

## 12. Test Stratejisi

| Test Türü | Kapsam | Araç |
|---|---|---|
| Unit Test | TimerService, Repository CRUD | flutter_test |
| Widget Test | CircularTimer, TimerControls | flutter_test |
| Manuel Test | Bildirimler, arka plan davranışı | Gerçek cihaz / emülatör |

Öncelik sırası: İlk olarak **macOS** üzerinde geliştir ve test et (en hızlı build döngüsü). Ardından **Android emülatör/tablet**, son olarak **Windows**.

---

## 13. Claude CLI Kullanım Rehberi

### 13.1 Genel Kurallar

1. Her faz için ayrı bir Claude CLI oturumu kullan
2. Her oturumun başında bu dokümanı referans olarak ver
3. Fazla kodu tek seferde değil, dosya dosya üret
4. Her fazın sonunda `flutter analyze` ve `flutter run` ile doğrula

### 13.2 Örnek İlk Prompt (Faz 1)

```
Bu dokümanı (PomoLocal_PRD.md) referans alarak Faz 1'i gerçekleştir:

1. Flutter projesi oluştur: flutter create pomolocal
2. pubspec.yaml'ı PRD'deki bağımlılıklarla güncelle
3. lib/ altındaki klasör yapısını oluştur
4. Isar modellerini (Session, Settings) tanımla
5. Repository sınıflarını yaz
6. main.dart'ta Isar initialization yap
7. flutter analyze ile hata olmadığını doğrula

Platform: macOS, Windows, Android
Dart null safety: Aktif
Hiçbir HTTP/network paketi ekleme.
```

### 13.3 Her Faz Sonrası Kontrol Listesi

- [ ] `flutter analyze` hata vermiyor mu?
- [ ] `flutter run -d macos` çalışıyor mu?
- [ ] Yeni eklenen özellik beklendiği gibi çalışıyor mu?
- [ ] Mevcut özellikler bozulmadı mı?
- [ ] Kod, PRD'deki klasör yapısına uygun mu?

---

## 14. Isar Hakkında Önemli Not

Eğer Isar 4.x Flutter 3.x ile uyumsuzluk çıkarırsa, alternatif olarak **Hive CE** (Community Edition) veya **ObjectBox** kullanılabilir. Claude CLI'a şu ek talimat verilebilir:

```
Isar yerine Hive CE kullan. pubspec.yaml'da:
  hive_ce: ^latest
  hive_ce_flutter: ^latest
Model yapısını TypeAdapter ile güncelle.
```

---

*Bu doküman, Claude CLI ile PomoLocal'ın geliştirilmesi için tek kaynak referans (Single Source of Truth) olarak kullanılacaktır.*
