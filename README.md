# iOS E-Commerce App

Spring Boot E-Commerce API için geliştirilmiş iOS mobil istemci uygulaması.

## Teknolojiler

- **UIKit** — Programmatic UI (Storyboard kullanılmadı)
- **MVVM** — Model-View-ViewModel mimarisi, Delegate pattern ile
- **Codable** — JSON parse ve serialize
- **URLSession** — Native networking

## Proje Yapısı

```
ECommerceApp/
├── Models/                 # Codable modeller (Request/Response)
│   ├── Product.swift
│   ├── Category.swift
│   ├── Customer.swift
│   ├── Order.swift
│   └── Assistant.swift
├── Network/                # API iletişim katmanı
│   ├── APIConstants.swift
│   ├── NetworkError.swift
│   └── NetworkManager.swift
├── ViewModels/             # İş mantığı ve state yönetimi
│   ├── ProductViewModel.swift
│   ├── CategoryViewModel.swift
│   ├── CustomerViewModel.swift
│   ├── OrderViewModel.swift
│   └── AssistantViewModel.swift
└── Views/                  # UIKit ekranları
    ├── MainTabBarController.swift
    ├── Products/           # Ürün listele, detay, ekle/düzenle
    ├── Categories/         # Kategori listele, ekle
    ├── Customers/          # Müşteri listele, detay, ekle/düzenle
    ├── Orders/             # Sipariş listele, detay, oluştur, durum güncelle
    └── Assistant/          # AI alışveriş asistanı chat ekranı
```

## Özellikler

| Modül | İşlevler |
|-------|----------|
| **Ürünler** | Listeleme, detay, ekleme, düzenleme, silme |
| **Kategoriler** | Listeleme, ekleme, silme |
| **Müşteriler** | Listeleme, detay, ekleme, düzenleme, silme |
| **Siparişler** | Listeleme, detay, oluşturma, durum güncelleme (PENDING → SHIPPED → DELIVERED / CANCELLED), silme |
| **AI Asistan** | Chat ekranı, ürün önerileri |

## API Bağlantısı

Uygulama `http://localhost:8080/api` adresindeki Spring Boot backend'e bağlanır.

| Endpoint | Açıklama |
|----------|----------|
| `GET/POST/PUT/DELETE /api/products` | Ürün CRUD |
| `GET/POST/PUT/DELETE /api/categories` | Kategori CRUD |
| `GET/POST/PUT/DELETE /api/customers` | Müşteri CRUD |
| `GET/POST/DELETE /api/orders` | Sipariş CRUD |
| `PATCH /api/orders/{id}/status` | Sipariş durum güncelleme |
| `POST /api/assistant/chat` | AI asistan |

> Backend reposu: [spring-ecommerce-api](https://github.com/hcemayaz/spring-ecommerce-api)

## Kurulum

1. Repoyu klonlayın:
   ```bash
   git clone https://github.com/hcemayaz/ios-ecommerce-app.git
   ```

2. Xcode'da yeni bir iOS App projesi oluşturun (UIKit, Storyboard yok).

3. `ECommerceApp/` klasöründeki tüm Swift dosyalarını projeye ekleyin.

4. `Info.plist` içeriğini projenizin Info.plist'ine kopyalayın (`NSAllowsLocalNetworking` gerekli).

5. Backend'i çalıştırın ve uygulamayı simulator'da başlatın.

## Gereksinimler

- Xcode 15+
- iOS 16+
- Çalışan Spring Boot backend (localhost:8080)
