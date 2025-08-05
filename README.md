# 📚 Study Web Sitesi - Full Stack Proje

> **Çalışma sürelerini pomodoro yöntemi veya serbest sayaçla takip edebileceğin, görevler oluşturup yönetebileceğin modern bir çalışma uygulaması.**

[![.NET](https://img.shields.io/badge/.NET-8.0-blue.svg)](https://dotnet.microsoft.com/)
[![SQLite](https://img.shields.io/badge/SQLite-3.0-green.svg)](https://www.sqlite.org/)
[![JWT](https://img.shields.io/badge/JWT-Authentication-orange.svg)](https://jwt.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🎯 Proje Tanımı

Study Web Sitesi, kullanıcıların ders çalışma sürelerini pomodoro yöntemi veya serbest sayaçla takip edebildiği, görevler oluşturup yönetebildiği bir web uygulamasıdır. 

**Temel Özellikler:**
- 📋 Görev oluşturma ve yönetimi
- ⏰ Pomodoro zamanlayıcısı (25 dakika odaklanma + 5 dakika mola)
- 🆓 Serbest zamanlayıcı modu
- 👤 Kullanıcı kayıt ve giriş sistemi
- 📊 Detaylı çalışma istatistikleri
- 🔓 Anonim kullanım desteği (giriş yapmadan da kullanılabilir)

## 🏗️ Teknoloji Stack'i

### Backend
- **ASP.NET Core 8.0** - Web API Framework
- **Entity Framework Core** - ORM (Object-Relational Mapping)
- **SQLite** - Hafif veritabanı (geliştirme için)
- **ASP.NET Core Identity** - Güvenli kullanıcı yönetimi
- **JWT (JSON Web Tokens)** - Authentication & Authorization
- **Swagger/OpenAPI** - API Dokümantasyonu

### Veritabanı Yapısı
```
Users (Identity)        StudyTasks              StudySessions
├── Id                 ├── Id                  ├── Id
├── UserName           ├── UserId (nullable)   ├── TaskId
├── Email              ├── Title               ├── UserId (nullable)
├── PasswordHash       ├── Description         ├── Duration
├── CreatedAt          ├── CreatedAt           ├── Type (pomodoro/free)
└── ...                ├── IsCompleted         ├── CreatedAt
                       └── ...                 ├── StartedAt
                                              ├── CompletedAt
                                              └── IsCompleted
```

## 🚀 Hızlı Başlangıç

### Gereksinimler
- [.NET 8.0 SDK](https://dotnet.microsoft.com/download)
- [Git](https://git-scm.com/)

### Kurulum

1. **Projeyi klonlayın:**
```bash
git clone https://github.com/yourusername/study-website.git
cd study-website
```

2. **Bağımlılıkları yükleyin:**
```bash
cd Cludy
dotnet restore
```

3. **Uygulamayı çalıştırın:**
```bash
dotnet run
```

4. **API'ye erişin:**
- **Swagger UI:** http://localhost:5000/swagger
- **API Base URL:** http://localhost:5000/api

Veritabanı ilk çalıştırmada otomatik olarak oluşturulacaktır.

## 📋 API Dokümantasyonu

### 🔐 Authentication Endpoints

#### Kullanıcı Kaydı
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "kullaniciadi",
  "email": "email@example.com",
  "password": "sifre123"
}
```

#### Kullanıcı Girişi
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "email@example.com",
  "password": "sifre123"
}
```

#### Profil Bilgileri (🔒 Authentication Gerekli)
```http
GET /api/auth/profile
Authorization: Bearer {jwt_token}
```

### 📋 Task (Görev) Endpoints

#### Görev Listesi
```http
GET /api/tasks
```

#### Yeni Görev Oluştur
```http
POST /api/tasks
Content-Type: application/json

{
  "title": "JavaScript Çalışması",
  "description": "React ve Node.js konularını çalış"
}
```

#### Görev Detayı
```http
GET /api/tasks/{id}
```

#### Görev Güncelle
```http
PUT /api/tasks/{id}
Content-Type: application/json

{
  "title": "Güncellenmiş Başlık",
  "description": "Güncellenmiş açıklama",
  "isCompleted": false
}
```

#### Görev Sil
```http
DELETE /api/tasks/{id}
```

### ⏱️ Session (Çalışma Oturumu) Endpoints

#### Yeni Oturum Başlat
```http
POST /api/sessions
Content-Type: application/json

{
  "taskId": 1,
  "duration": 25,
  "type": "pomodoro"
}
```

#### Oturum Listesi
```http
GET /api/sessions
```

#### Görev Bazlı Oturumlar
```http
GET /api/sessions/task/{taskId}
```

#### Oturum Tamamla
```http
PUT /api/sessions/{id}/complete
```

#### İstatistikler (🔒 Authentication Gerekli)
```http
GET /api/sessions/stats
Authorization: Bearer {jwt_token}
```

## 🔧 Geliştirme

### Proje Yapısı
```
Cludy/
├── Controllers/          # API Controller'ları
│   ├── AuthController.cs
│   ├── TasksController.cs
│   └── SessionsController.cs
├── Data/                 # Veritabanı Context
│   └── ApplicationDbContext.cs
├── Models/               # Veri Modelleri
│   ├── User.cs
│   ├── StudyTask.cs
│   ├── StudySession.cs
│   └── DTOs/            # Data Transfer Objects
├── Services/            # İş Mantığı Servisleri
│   ├── IAuthService.cs
│   ├── AuthService.cs
│   ├── ITaskService.cs
│   ├── TaskService.cs
│   ├── ISessionService.cs
│   └── SessionService.cs
└── Program.cs           # Uygulama Başlangıç Noktası
```

### Önemli Konfigürasyonlar

#### appsettings.json
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=studyapp.db"
  },
  "JwtSettings": {
    "SecretKey": "YourSecretKeyHere",
    "Issuer": "StudyApp",
    "Audience": "StudyAppUsers",
    "ExpiryInHours": 24
  }
}
```

### Git Commit Geçmişi
```
🎉 Initial project setup
⚙️ Add project configuration and dependencies  
🗃️ Add data models and Entity Framework setup
📝 Add DTO models for API contracts
🔧 Implement service layer and business logic
🌐 Add API controllers and HTTP endpoints
🔧 Add development environment configuration
🔧 Add automatic database creation and fix startup issues
⚙️ Configure launch settings and fix port conflicts
🧪 Add API testing file
```

## 🧪 Test Senaryoları

### Manuel API Testleri

1. **Anonim Görev Oluşturma:**
```bash
curl -X POST "http://localhost:5000/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Görevi", "description": "Test açıklaması"}'
```

2. **Kullanıcı Kaydı:**
```bash
curl -X POST "http://localhost:5000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "email": "test@example.com", "password": "Test123456"}'
```

3. **Pomodoro Oturumu Başlatma:**
```bash
curl -X POST "http://localhost:5000/api/sessions" \
  -H "Content-Type: application/json" \
  -d '{"taskId": 1, "duration": 25, "type": "pomodoro"}'
```

## 🔒 Güvenlik Özellikleri

- **JWT Authentication:** Güvenli token tabanlı kimlik doğrulama
- **ASP.NET Core Identity:** Profesyonel kullanıcı yönetimi
- **Password Hashing:** Güvenli şifre saklama
- **CORS Policy:** Güvenli cross-origin istekleri
- **Input Validation:** API endpoint'lerinde veri doğrulama

## 📊 Özellikler

### ✅ Tamamlanmış Özellikler

- [x] **Kullanıcı Yönetimi**
  - [x] Kullanıcı kaydı ve girişi
  - [x] JWT token authentication
  - [x] Profil bilgileri yönetimi

- [x] **Görev Yönetimi**
  - [x] CRUD operasyonları (Create, Read, Update, Delete)
  - [x] Anonim kullanıcı desteği
  - [x] Görev tamamlama durumu

- [x] **Çalışma Oturumu Takibi**
  - [x] Pomodoro zamanlayıcısı (25 dakika)
  - [x] Serbest zamanlayıcı modu
  - [x] Oturum geçmişi
  - [x] Oturum istatistikleri

- [x] **Veritabanı**
  - [x] SQLite entegrasyonu
  - [x] Entity Framework Core migrations
  - [x] Otomatik veritabanı oluşturma

### 🔄 Gelecek Özellikler (Roadmap)

- [ ] **Frontend (React)**
  - [ ] Modern React UI
  - [ ] Responsive tasarım
  - [ ] Real-time zamanlayıcı
  - [ ] Dashboard ve istatistikler

- [ ] **Gelişmiş Özellikler**
  - [ ] Kategori bazlı görev organizasyonu
  - [ ] Haftalık/aylık raporlar
  - [ ] Hedef belirleme sistemi
  - [ ] Bildirim sistemi

- [ ] **Deployment**
  - [ ] Docker containerization
  - [ ] Azure/AWS deployment
  - [ ] CI/CD pipeline

## 🤝 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Feature branch'i oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 👨‍💻 Geliştirici

**Study Web Sitesi** - Modern çalışma takip uygulaması

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!

## 📞 İletişim

Proje hakkında sorularınız için:
- 📧 Email: your.email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/study-website/issues)
- 📖 Wiki: [Project Wiki](https://github.com/yourusername/study-website/wiki)

---

*Son güncelleme: Ağustos 2025*
