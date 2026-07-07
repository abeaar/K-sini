# K-SINI Architecture Documentation

K-SINI menggunakan pendekatan **MVVM + Repository + Service** untuk memisahkan tanggung jawab setiap komponen sehingga aplikasi tetap mudah dipelihara, diuji, dan dikembangkan seiring bertambahnya fitur navigasi indoor.

---

# Project Structure

```text
K-SINI

├── App
├── Resources
├── Models
├── Extensions
├── Services
├── Loaders
├── Repositories
├── ViewModels
├── Views
└── Utilities
```

---

# App

```text
App
└── KSiniApp.swift
```

## Tujuan

Folder ini berisi titik awal aplikasi.

Bertanggung jawab untuk:

- Menginisialisasi aplikasi
- Menentukan tampilan awal
- Mengatur konfigurasi global aplikasi

## Isi Folder

```text
KSiniApp.swift
```

---

# Resources

```text
Resources
│
├── Assets.xcassets
├── GeoJSON
└── Localizable.xcstrings
```

## Tujuan

Menyimpan seluruh aset yang digunakan oleh K-SINI.

## Assets.xcassets

Berisi:

- App Icon
- Marker peta
- Simbol fasilitas stasiun
- Ikon navigasi
- Gambar anotasi MapKit

## GeoJSON

Menyimpan data spasial yang digunakan oleh sistem navigasi indoor.

Contoh:

```text
building.geojson
level.geojson
unit.geojson
platform.geojson
endpoint.geojson
pathway.geojson
```

## Localizable.xcstrings

Translation multi bahasa aplikasi.

---

# Models

```text
Models
│
├── Building.swift
├── Level.swift
├── Platform.swift
├── Unit.swift
├── Endpoint.swift
├── Pathway.swift
└── PathDirection.swift
```

## Tujuan

Mendefinisikan struktur data utama pada K-SINI.

Model hanya bertanggung jawab menyimpan data.

Model tidak mengandung business logic maupun logika tampilan.

## Contoh

### Building

Representasi bangunan utama.

```swift
Building
```

### Level

Representasi lantai.

```swift
Level
```

### Unit

Representasi ruangan atau fasilitas.

```swift
Unit
```

### Platform

Representasi area peron.

```swift
Platform
```

### Endpoint

Representasi titik awal dan tujuan navigasi.

```swift
Endpoint
```

### Pathway

Representasi jalur navigasi.

```swift
Pathway
```

---

# Extensions

```text
Extensions
│
├── Color+Hex.swift
└── MKPolygon+Coordinates.swift
```

## Tujuan

Menambahkan kemampuan tambahan pada framework bawaan Apple.

## Color+Hex

Digunakan untuk mengubah nilai HEX menjadi SwiftUI Color.

Contoh:

```swift
Color(hex: "#0055FF")
```

## MKPolygon+Coordinates

Memudahkan konversi objek MapKit menjadi array koordinat.

Contoh:

```swift
polygon.coordinates
```

---

# Services

```text
Services
│
├── RouteService.swift
├── GuidanceService.swift
└── BuildingRegionService.swift
```

## Tujuan

Menyimpan business logic K-SINI.

Service tidak mengetahui SwiftUI.

Service hanya bertugas memproses data.

---

## RouteService

Bertanggung jawab terhadap proses pencarian jalur.

Fitur:

- BFS Routing
- Pathfinding
- Shortest Path
- Route Calculation

Contoh:

```swift
findRoute()
```

---

## GuidanceService

Bertanggung jawab terhadap visualisasi panduan navigasi.

Fitur:

- Segmentasi jalur
- Pemisahan jalur antar lantai
- Pembuatan polyline navigasi

Contoh:

```swift
segments()
```

---

## BuildingRegionService

Bertanggung jawab untuk menghitung area tampilan MapKit.

Fitur:

- Bounding Box
- Zoom otomatis
- Initial camera region

Contoh:

```swift
region(from:)
```

---

# Loaders

```text
Loaders
│
├── GeoJSONLoader.swift
├── BuildingLoader.swift
├── LevelLoader.swift
├── PlatformLoader.swift
├── UnitLoader.swift
├── EndpointLoader.swift
└── PathwayLoader.swift
```

## Tujuan

Membaca file GeoJSON dan mengubahnya menjadi model Swift.

Loader hanya bertugas melakukan parsing data.

Loader tidak menyimpan state aplikasi.

Loader tidak melakukan navigasi.

---

## BuildingLoader

Membaca:

```text
building.geojson
```

menghasilkan:

```swift
[Building]
```

---

## LevelLoader

Membaca:

```text
level.geojson
```

menghasilkan:

```swift
[Level]
```

---

## PlatformLoader

Membaca:

```text
platform.geojson
```

menghasilkan:

```swift
[Platform]
```

---

## UnitLoader

Membaca:

```text
unit.geojson
```

menghasilkan:

```swift
[Unit]
```

---

## EndpointLoader

Membaca:

```text
endpoint.geojson
```

menghasilkan:

```swift
[Endpoint]
```

---

## PathwayLoader

Membaca:

```text
pathway.geojson
```

menghasilkan:

```swift
[Pathway]
```

---

# Repositories

```text
Repositories
│
├── GeoJSONRepository.swift
└── GeoJSONRepositoryProtocol.swift
```

## Tujuan

Menjadi akses data tunggal untuk seluruh modul K-SINI.

ViewModel tidak berinteraksi langsung dengan Loader.

Seluruh pengambilan data dilakukan melalui Repository.

---

## GeoJSONRepository

Menggabungkan seluruh loader menjadi satu sumber data.

Contoh:

```swift
loadBuildings()

loadLevels()

loadPlatforms()

loadUnits()

loadEndpoints()

loadPathways()
```

---

## GeoJSONRepositoryProtocol

Digunakan untuk:

- Dependency Injection
- Mock Repository
- Unit Testing
- Future API Integration

---

# ViewModels

```text
ViewModels
│
├── MapViewModel.swift
├── MapViewModel+Loading.swift
├── MapViewModel+Navigation.swift
├── MapViewModel+Floor.swift
└── MapViewModel+Guidance.swift
```

## Tujuan

Mengelola state aplikasi.

Menjadi penghubung antara tampilan dan business logic.

---

## MapViewModel

Menyimpan state utama aplikasi.

Contoh:

```swift
buildings

levels

platforms

units

endpoints

pathways

selectedLevelID

selectedStartID

selectedDestinationID

routeSegments
```

---

## Loading

Memuat seluruh data GeoJSON.

```swift
loadData()
```

---

## Navigation

Mengelola proses pencarian rute.

```swift
navigate()
```

---

## Guidance

Menghasilkan jalur navigasi yang akan ditampilkan pada MapKit.

```swift
currentSegments()
```

---

## Floor

Mengelola perpindahan antar lantai.

```swift
switchFloor()
```

---

# Views

```text
Views
│
├── ContentView.swift
│
├── Components
│
└── Layers
```

## Tujuan

Menyediakan seluruh tampilan aplikasi K-SINI.

Views tidak mengandung business logic.

Views hanya bertanggung jawab terhadap rendering UI.

---

# Components

```text
Components
│
├── FloorSelectorView.swift
└── EndpointSelectorView.swift
```

## Tujuan

Kumpulan komponen yang dapat digunakan kembali.

---

## FloorSelectorView

Digunakan untuk memilih lantai aktif.

---

## EndpointSelectorView

Digunakan untuk memilih titik awal dan tujuan navigasi.

---

# Layers

```text
Layers
│
├── BuildingLayer.swift
├── LevelLayer.swift
├── PlatformLayer.swift
├── UnitLayer.swift
├── EndpointLayer.swift
└── GuidanceLayer.swift
```

## Tujuan

Merepresentasikan elemen-elemen peta pada MapKit.

Setiap layer memiliki tanggung jawab tunggal.

---

## BuildingLayer

Menampilkan bangunan utama.

---

## LevelLayer

Menampilkan area lantai.

---

## PlatformLayer

Menampilkan area peron.

---

## UnitLayer

Menampilkan ruangan dan fasilitas.

---

## EndpointLayer

Menampilkan titik navigasi.

---

## GuidanceLayer

Menampilkan jalur panduan pengguna.

---

# Utilities

```text
Utilities
│
└── UnitIconProvider.swift
```

## Tujuan

Menyimpan helper kecil yang digunakan lintas modul.

Utilities tidak menyimpan state aplikasi.

Utilities tidak memiliki business logic kompleks.

---

## UnitIconProvider

Mengubah kategori unit menjadi SF Symbol.

Contoh:

```text
stairs
escalator
elevator
platform
```

menjadi:

```text
figure.stairs

arrow.up.right

arrow.up.arrow.down

tram.fill
```

---

# Architecture Flow

```text
GeoJSON

↓

Loaders

↓

Repository

↓

Services

↓

ViewModels

↓

Views

↓

MapKit
```

---

# Design Principles

K-SINI menerapkan prinsip **Single Responsibility Principle (SRP)**.

Setiap folder memiliki satu tanggung jawab utama.

```text
Models
→ Data Representation

Loaders
→ Data Parsing

Repository
→ Data Access Layer

Services
→ Business Logic

ViewModels
→ State Management

Views
→ User Interface

Utilities
→ Shared Helpers
```
