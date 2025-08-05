# 🎯 Cludy Study App - API Dokümantasyonu

Bu dokümantasyon, Cludy Study App REST API'nın nasıl kullanılacağını detaylı bir şekilde açıklar.

## 📋 İçindekiler
- [Genel Bilgiler](#genel-bilgiler)
- [Kimlik Doğrulama](#kimlik-doğrulama)
- [Auth Endpoints](#auth-endpoints)
- [Tasks Endpoints](#tasks-endpoints)
- [Sessions Endpoints](#sessions-endpoints)
- [Hata Kodları](#hata-kodları)
- [Örnek Kullanım Senaryoları](#örnek-kullanım-senaryoları)

## 🌐 Genel Bilgiler

**Base URL:** `http://localhost:5004` (Development)
**Base URL:** `https://localhost:5005` (Development HTTPS)

**Content-Type:** `application/json`
**API Version:** v1

### 🔗 Swagger UI
Interaktif API dokümantasyonuna erişim:
- **HTTP:** http://localhost:5004/swagger
- **HTTPS:** https://localhost:5005/swagger

## 🔐 Kimlik Doğrulama

API, JWT (JSON Web Token) tabanlı kimlik doğrulama kullanır.

### Token Kullanımı
```http
Authorization: Bearer <your_jwt_token>
```

### Anonim Erişim
Bazı endpoint'ler anonim kullanıcılar tarafından kullanılabilir (Tasks ve Sessions).

---

## 🔑 Auth Endpoints

### 1. Kullanıcı Kayıt

**POST** `/api/auth/register`

Yeni kullanıcı kaydı oluşturur.

**Request Body:**
```json
{
  "username": "string (3-50 karakter)",
  "email": "string (geçerli email)",
  "password": "string (6-100 karakter)"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "createdAt": "2025-08-05T10:30:00Z"
  }
}
```

**Örnek cURL:**
```bash
curl -X POST "http://localhost:5004/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com", 
    "password": "securepassword123"
  }'
```

### 2. Kullanıcı Girişi

**POST** `/api/auth/login`

Mevcut kullanıcı girişi yapar.

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "createdAt": "2025-08-05T10:30:00Z"
  }
}
```

**Örnek cURL:**
```bash
curl -X POST "http://localhost:5004/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "securepassword123"
  }'
```

### 3. Profil Bilgisi

**GET** `/api/auth/profile`
🔒 **Yetkilendirme Gerekli**

Giriş yapmış kullanıcının profil bilgilerini getirir.

**Headers:**
```http
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "createdAt": "2025-08-05T10:30:00Z"
}
```

**Örnek cURL:**
```bash
curl -X GET "http://localhost:5004/api/auth/profile" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📝 Tasks Endpoints

### 1. Görevleri Listele

**GET** `/api/tasks`

Kullanıcının görevlerini listeler. Login olmayan kullanıcılar için anonymous görevler döner.

**Response (200):**
```json
[
  {
    "id": 1,
    "title": "Matematik Çalışması",
    "description": "Lineer cebir konularını tekrar et",
    "createdAt": "2025-08-05T10:30:00Z",
    "isCompleted": false,
    "sessionCount": 5,
    "totalStudyTime": 150
  }
]
```

**Örnek cURL:**
```bash
# Login olmuş kullanıcı için
curl -X GET "http://localhost:5004/api/tasks" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Anonim kullanıcı için
curl -X GET "http://localhost:5004/api/tasks"
```

### 2. Tek Görev Getir

**GET** `/api/tasks/{id}`

Belirli bir görevi getirir.

**Parameters:**
- `id` (path): Görev ID'si

**Response (200):**
```json
{
  "id": 1,
  "title": "Matematik Çalışması",
  "description": "Lineer cebir konularını tekrar et",
  "createdAt": "2025-08-05T10:30:00Z",
  "isCompleted": false,
  "sessionCount": 5,
  "totalStudyTime": 150
}
```

**Örnek cURL:**
```bash
curl -X GET "http://localhost:5004/api/tasks/1" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. Görev Oluştur

**POST** `/api/tasks`

Yeni görev oluşturur.

**Request Body:**
```json
{
  "title": "string (1-200 karakter)",
  "description": "string (0-1000 karakter)"
}
```

**Response (201):**
```json
{
  "id": 2,
  "title": "Yeni Görev",
  "description": "Görev açıklaması",
  "createdAt": "2025-08-05T11:00:00Z",
  "isCompleted": false,
  "sessionCount": 0,
  "totalStudyTime": 0
}
```

**Örnek cURL:**
```bash
curl -X POST "http://localhost:5004/api/tasks" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "İngilizce Çalışması",
    "description": "Grammar konularını çalış"
  }'
```

### 4. Görev Güncelle

**PUT** `/api/tasks/{id}`

Mevcut görevi günceller.

**Parameters:**
- `id` (path): Görev ID'si

**Request Body:**
```json
{
  "title": "string (1-200 karakter)",
  "description": "string (0-1000 karakter)",
  "isCompleted": "boolean"
}
```

**Response (200):**
```json
{
  "id": 1,
  "title": "Güncellenmiş Görev",
  "description": "Yeni açıklama",
  "createdAt": "2025-08-05T10:30:00Z",
  "isCompleted": true,
  "sessionCount": 5,
  "totalStudyTime": 150
}
```

**Örnek cURL:**
```bash
curl -X PUT "http://localhost:5004/api/tasks/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "Matematik Çalışması - Tamamlandı",
    "description": "Lineer cebir tamamlandı",
    "isCompleted": true
  }'
```

### 5. Görev Sil

**DELETE** `/api/tasks/{id}`

Görevi siler.

**Parameters:**
- `id` (path): Görev ID'si

**Response (204):** No Content

**Örnek cURL:**
```bash
curl -X DELETE "http://localhost:5004/api/tasks/1" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## ⏱️ Sessions Endpoints

### 1. Oturumları Listele

**GET** `/api/sessions`

Kullanıcının çalışma oturumlarını listeler.

**Response (200):**
```json
[
  {
    "id": 1,
    "taskId": 1,
    "taskTitle": "Matematik Çalışması",
    "duration": 25,
    "type": "pomodoro",
    "createdAt": "2025-08-05T10:30:00Z",
    "startedAt": "2025-08-05T10:30:00Z",
    "completedAt": "2025-08-05T10:55:00Z",
    "isCompleted": true
  }
]
```

**Örnek cURL:**
```bash
curl -X GET "http://localhost:5004/api/sessions" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 2. Görev Oturumlarını Listele

**GET** `/api/sessions/task/{taskId}`

Belirli bir göreve ait oturumları listeler.

**Parameters:**
- `taskId` (path): Görev ID'si

**Response (200):**
```json
[
  {
    "id": 1,
    "taskId": 1,
    "taskTitle": "Matematik Çalışması",
    "duration": 25,
    "type": "pomodoro",
    "createdAt": "2025-08-05T10:30:00Z",
    "startedAt": "2025-08-05T10:30:00Z",
    "completedAt": "2025-08-05T10:55:00Z",
    "isCompleted": true
  }
]
```

**Örnek cURL:**
```bash
curl -X GET "http://localhost:5004/api/sessions/task/1" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. Oturum Oluştur

**POST** `/api/sessions`

Yeni çalışma oturumu oluşturur.

**Request Body:**
```json
{
  "taskId": "number",
  "duration": "number (1-1440 dakika)",
  "type": "string ('pomodoro' veya 'free')"
}
```

**Response (201):**
```json
{
  "id": 2,
  "taskId": 1,
  "taskTitle": "Matematik Çalışması",
  "duration": 25,
  "type": "pomodoro",
  "createdAt": "2025-08-05T11:00:00Z",
  "startedAt": null,
  "completedAt": null,
  "isCompleted": false
}
```

**Örnek cURL:**
```bash
curl -X POST "http://localhost:5004/api/sessions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "taskId": 1,
    "duration": 25,
    "type": "pomodoro"
  }'
```

### 4. Oturumu Tamamla

**PUT** `/api/sessions/{id}/complete`

Çalışma oturumunu tamamlar.

**Parameters:**
- `id` (path): Oturum ID'si

**Response (200):**
```json
{
  "message": "Oturum başarıyla tamamlandı."
}
```

**Örnek cURL:**
```bash
curl -X PUT "http://localhost:5004/api/sessions/1/complete" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 5. İstatistikleri Getir

**GET** `/api/sessions/stats`
🔒 **Yetkilendirme Gerekli**

Kullanıcının çalışma istatistiklerini getirir.

**Response (200):**
```json
{
  "totalSessions": 15,
  "totalStudyTime": 375,
  "completedSessions": 12,
  "pomodoroSessions": 8,
  "freeSessions": 7,
  "averageSessionDuration": 25.0,
  "dailyStats": [
    {
      "date": "2025-08-05T00:00:00Z",
      "sessionCount": 3,
      "totalMinutes": 75
    }
  ]
}
```

**Örnek cURL:**
```bash
curl -X GET "http://localhost:5004/api/sessions/stats" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## ❌ Hata Kodları

### HTTP Status Kodları

| Kod | Anlamı | Açıklama |
|-----|--------|----------|
| 200 | OK | İstek başarılı |
| 201 | Created | Kaynak başarıyla oluşturuldu |
| 204 | No Content | İstek başarılı, içerik yok |
| 400 | Bad Request | Geçersiz istek |
| 401 | Unauthorized | Yetkilendirme gerekli |
| 404 | Not Found | Kaynak bulunamadı |
| 500 | Internal Server Error | Sunucu hatası |

### Hata Response Formatı

```json
{
  "message": "Hata açıklaması"
}
```

**Örnek Hatalar:**

```json
// 400 Bad Request
{
  "message": "Geçersiz email formatı."
}

// 401 Unauthorized  
{
  "message": "Geçersiz token."
}

// 404 Not Found
{
  "message": "Görev bulunamadı."
}
```

---

## 🎮 Örnek Kullanım Senaryoları

### Senaryo 1: Yeni Kullanıcı Kaydı ve İlk Görev

```bash
# 1. Kullanıcı kaydı
curl -X POST "http://localhost:5004/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "ahmet",
    "email": "ahmet@example.com",
    "password": "securepass123"
  }'

# Response'dan token'ı al
# Örnek: "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# 2. İlk görev oluştur
curl -X POST "http://localhost:5004/api/tasks" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "title": "JavaScript Öğren",
    "description": "ES6 özelliklerini çalış"
  }'

# 3. Görev için çalışma oturumu başlat
curl -X POST "http://localhost:5004/api/sessions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "taskId": 1,
    "duration": 25,
    "type": "pomodoro"
  }'
```

### Senaryo 2: Anonim Kullanıcı Deneyimi

```bash
# 1. Anonim görev oluştur
curl -X POST "http://localhost:5004/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Deneme Görevi",
    "description": "Test için oluşturuldu"
  }'

# 2. Anonim oturum başlat
curl -X POST "http://localhost:5004/api/sessions" \
  -H "Content-Type: application/json" \
  -d '{
    "taskId": 1,
    "duration": 30,
    "type": "free"
  }'

# 3. Oturumu tamamla
curl -X PUT "http://localhost:5004/api/sessions/1/complete"
```

### Senaryo 3: Günlük Çalışma Rutini

```bash
# 1. Giriş yap
TOKEN=$(curl -s -X POST "http://localhost:5004/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmet@example.com",
    "password": "securepass123"
  }' | jq -r '.token')

# 2. Günün görevlerini listele
curl -X GET "http://localhost:5004/api/tasks" \
  -H "Authorization: Bearer $TOKEN"

# 3. İstatistikleri kontrol et
curl -X GET "http://localhost:5004/api/sessions/stats" \
  -H "Authorization: Bearer $TOKEN"

# 4. Yeni pomodoro oturumu başlat
curl -X POST "http://localhost:5004/api/sessions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "taskId": 1,
    "duration": 25,
    "type": "pomodoro"
  }'
```

---

## 📱 Frontend Entegrasyonu

### JavaScript Fetch Örnekleri

```javascript
// API Base URL
const API_BASE = 'http://localhost:5004/api';

// Token'ı localStorage'dan al
const getToken = () => localStorage.getItem('auth_token');

// Headers oluştur
const getHeaders = (includeAuth = true) => {
  const headers = {
    'Content-Type': 'application/json',
  };
  
  if (includeAuth && getToken()) {
    headers.Authorization = `Bearer ${getToken()}`;
  }
  
  return headers;
};

// Kullanıcı girişi
async function login(email, password) {
  const response = await fetch(`${API_BASE}/auth/login`, {
    method: 'POST',
    headers: getHeaders(false),
    body: JSON.stringify({ email, password })
  });
  
  const data = await response.json();
  
  if (response.ok) {
    localStorage.setItem('auth_token', data.token);
    return data;
  } else {
    throw new Error(data.message);
  }
}

// Görevleri listele
async function getTasks() {
  const response = await fetch(`${API_BASE}/tasks`, {
    headers: getHeaders()
  });
  
  return response.json();
}

// Yeni görev oluştur
async function createTask(title, description) {
  const response = await fetch(`${API_BASE}/tasks`, {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify({ title, description })
  });
  
  return response.json();
}

// Oturum başlat
async function createSession(taskId, duration, type = 'free') {
  const response = await fetch(`${API_BASE}/sessions`, {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify({ taskId, duration, type })
  });
  
  return response.json();
}
```

---

## 🔧 Geliştirici Notları

### Validasyon Kuralları

**Username:**
- 3-50 karakter arası
- Gerekli alan

**Email:**
- Geçerli email formatı
- Gerekli alan

**Password:**
- 6-100 karakter arası
- Gerekli alan

**Task Title:**
- 1-200 karakter arası
- Gerekli alan

**Task Description:**
- 0-1000 karakter arası
- Opsiyonel

**Session Duration:**
- 1-480 dakika arası (CreateSession)
- 1-1440 dakika arası (Model seviyesinde)

**Session Type:**
- Sadece "pomodoro" veya "free"
- Varsayılan: "free"

### Rate Limiting
Şu anda rate limiting uygulanmamıştır. Production ortamında eklenmesi önerilir.

### Timezone
Tüm tarih/saat değerleri UTC formatındadır.

---

## 🎯 Sonuç

Bu API dokümantasyonu, Cludy Study App'in tüm endpoint'lerini kapsamaktadır. Herhangi bir sorunuz olursa veya yeni özellik talepleri için lütfen iletişime geçin.

**Happy Coding! 🚀**
