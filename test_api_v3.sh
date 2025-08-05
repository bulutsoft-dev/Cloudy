#!/bin/bash

# 🎯 Cludy Study App - API Test Script V3 (Basit ve Güvenilir)
# Bu script API'yi test eder ve dummy veriler oluşturur

set -e  # Hata durumunda scripti durdur

# Renkli output için
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# API Base URL
API_BASE="http://localhost:5006/api"

# Global değişkenler
TOKENS=()
USER_IDS=()
TASK_IDS=()
SESSION_IDS=()

# Utility fonksiyonlar
print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}🎯 $1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# API durumunu kontrol et
check_api_status() {
    print_header "API Durum Kontrolü"
    
    if curl -s "$API_BASE/../swagger" > /dev/null 2>&1; then
        print_success "API çalışıyor: $API_BASE"
        print_info "Swagger UI: $API_BASE/../swagger"
    else
        print_error "API'ye erişilemiyor. Lütfen uygulamanın çalıştığından emin olun."
        print_warning "Şu komutu çalıştırın: cd Cludy && dotnet run --urls='http://localhost:5006'"
        exit 1
    fi
}

# Test kullanıcısı oluştur/giriş yap
create_test_user() {
    print_header "Test Kullanıcısı Hazırlanıyor"
    
    local username="testuser"
    local email="test@example.com"
    local password="password123"
    
    print_info "Test kullanıcısı: $username"
    
    # Önce kayıt olmayı dene
    local register_data="{\"username\":\"$username\",\"email\":\"$email\",\"password\":\"$password\"}"
    local response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X POST "$API_BASE/auth/register" \
        -H "Content-Type: application/json" \
        -d "$register_data")
    
    local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    local body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$http_code" -eq 200 ]; then
        print_success "Yeni kullanıcı oluşturuldu"
        local token=$(echo "$body" | jq -r '.token')
        local user_id=$(echo "$body" | jq -r '.user.id')
        
        TOKENS+=("$token")
        USER_IDS+=("$user_id")
    else
        # Kullanıcı zaten varsa login ol
        print_info "Kullanıcı mevcut, giriş yapılıyor..."
        
        local login_data="{\"email\":\"$email\",\"password\":\"$password\"}"
        local login_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
            -X POST "$API_BASE/auth/login" \
            -H "Content-Type: application/json" \
            -d "$login_data")
        
        local login_http_code=$(echo "$login_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        local login_body=$(echo "$login_response" | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$login_http_code" -eq 200 ]; then
            print_success "Giriş başarılı"
            local token=$(echo "$login_body" | jq -r '.token')
            local user_id=$(echo "$login_body" | jq -r '.user.id')
            
            TOKENS+=("$token")
            USER_IDS+=("$user_id")
        else
            print_error "Giriş başarısız"
            echo "Response: $login_body"
            exit 1
        fi
    fi
    
    print_success "Kullanıcı hazır: ID ${USER_IDS[0]}"
}

# Test görevleri oluştur
create_test_tasks() {
    print_header "Test Görevleri Oluşturuluyor"
    
    local token="${TOKENS[0]}"
    
    local tasks=(
        "JavaScript Öğrenme:ES6 özelliklerini çalış"
        "Matematik Çalışması:Calculus konularını tekrar et"
        "İngilizce Pratiği:Grammar ve vocabulary çalış"
        "Spor Aktivitesi:30 dakika koşu yap"
        "Kitap Okuma:Clean Code kitabını oku"
    )
    
    for task_info in "${tasks[@]}"; do
        IFS=':' read -r title description <<< "$task_info"
        
        local task_data="{\"title\":\"$title\",\"description\":\"$description\"}"
        
        local response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
            -X POST "$API_BASE/tasks" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$task_data")
        
        local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        local body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$http_code" -eq 201 ]; then
            local task_id=$(echo "$body" | jq -r '.id')
            TASK_IDS+=("$task_id")
            print_success "Görev oluşturuldu: $title (ID: $task_id)"
        else
            print_error "Görev oluşturulamadı: $title"
            print_info "HTTP Code: $http_code"
            print_info "Response: $body"
        fi
        
        sleep 0.3
    done
    
    # Anonim görev oluştur
    print_info "Anonim görev oluşturuluyor..."
    local anon_data='{"title":"Anonim Görev","description":"Test için anonim görev"}'
    local anon_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X POST "$API_BASE/tasks" \
        -H "Content-Type: application/json" \
        -d "$anon_data")
    
    local anon_http_code=$(echo "$anon_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    local anon_body=$(echo "$anon_response" | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$anon_http_code" -eq 201 ]; then
        local anon_task_id=$(echo "$anon_body" | jq -r '.id')
        TASK_IDS+=("$anon_task_id")
        print_success "Anonim görev oluşturuldu (ID: $anon_task_id)"
    fi
    
    print_success "Toplam ${#TASK_IDS[@]} görev oluşturuldu"
}

# Test çalışma oturumları oluştur
create_test_sessions() {
    print_header "Test Çalışma Oturumları Oluşturuluyor"
    
    local token="${TOKENS[0]}"
    local session_count=0
    
    # İlk 3 görev için authenticated sessions
    for i in {0..2}; do
        if [ $i -lt ${#TASK_IDS[@]} ]; then
            local task_id="${TASK_IDS[$i]}"
            
            # Pomodoro session
            local pomodoro_data="{\"taskId\":$task_id,\"duration\":25,\"type\":\"pomodoro\"}"
            local response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                -X POST "$API_BASE/sessions" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $token" \
                -d "$pomodoro_data")
            
            local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            local body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
            
            if [ "$http_code" -eq 201 ]; then
                local session_id=$(echo "$body" | jq -r '.id')
                SESSION_IDS+=("$session_id")
                session_count=$((session_count + 1))
                print_success "Pomodoro oturumu oluşturuldu: Görev $task_id (ID: $session_id)"
                
                # Oturumu tamamla
                local complete_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                    -X PUT "$API_BASE/sessions/$session_id/complete" \
                    -H "Authorization: Bearer $token")
                
                local complete_code=$(echo "$complete_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
                if [ "$complete_code" -eq 200 ]; then
                    print_success "Oturum tamamlandı: $session_id"
                fi
            else
                print_error "Pomodoro oturumu oluşturulamadı: Görev $task_id"
                print_info "HTTP Code: $http_code, Response: $body"
            fi
            
            # Free session
            local free_data="{\"taskId\":$task_id,\"duration\":45,\"type\":\"free\"}"
            local free_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                -X POST "$API_BASE/sessions" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $token" \
                -d "$free_data")
            
            local free_http_code=$(echo "$free_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            local free_body=$(echo "$free_response" | sed -e 's/HTTPSTATUS\:.*//g')
            
            if [ "$free_http_code" -eq 201 ]; then
                local free_session_id=$(echo "$free_body" | jq -r '.id')
                SESSION_IDS+=("$free_session_id")
                session_count=$((session_count + 1))
                print_success "Free oturumu oluşturuldu: Görev $task_id (ID: $free_session_id)"
            else
                print_error "Free oturumu oluşturulamadı: Görev $task_id"
                print_info "HTTP Code: $free_http_code, Response: $free_body"
            fi
            
            sleep 0.5
        fi
    done
    
    # Son görev için anonim session (eğer varsa)
    if [ ${#TASK_IDS[@]} -gt 0 ]; then
        local last_task_id="${TASK_IDS[-1]}"
        print_info "Anonim oturum oluşturuluyor..."
        
        local anon_session_data="{\"taskId\":$last_task_id,\"duration\":30,\"type\":\"free\"}"
        local anon_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
            -X POST "$API_BASE/sessions" \
            -H "Content-Type: application/json" \
            -d "$anon_session_data")
        
        local anon_http_code=$(echo "$anon_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        local anon_body=$(echo "$anon_response" | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$anon_http_code" -eq 201 ]; then
            local anon_session_id=$(echo "$anon_body" | jq -r '.id')
            SESSION_IDS+=("$anon_session_id")
            session_count=$((session_count + 1))
            print_success "Anonim oturum oluşturuldu (ID: $anon_session_id)"
        else
            print_error "Anonim oturum oluşturulamadı"
            print_info "HTTP Code: $anon_http_code, Response: $anon_body"
        fi
    fi
    
    print_success "Toplam $session_count çalışma oturumu oluşturuldu"
}

# API endpoint'leri test et
test_api_endpoints() {
    print_header "API Endpoint'leri Test Ediliyor"
    
    if [ ${#TOKENS[@]} -eq 0 ]; then
        print_error "Test için kullanıcı bulunamadı"
        return
    fi
    
    local token="${TOKENS[0]}"
    local user_id="${USER_IDS[0]}"
    
    print_info "Test kullanıcısı: ID $user_id"
    
    # Auth profile test
    print_info "🔐 Auth/Profile endpoint testi..."
    local profile_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X GET "$API_BASE/auth/profile" \
        -H "Authorization: Bearer $token")
    
    local profile_http_code=$(echo "$profile_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$profile_http_code" -eq 200 ]; then
        print_success "✓ Profile endpoint çalışıyor"
    else
        print_error "❌ Profile endpoint hatası: HTTP $profile_http_code"
    fi
    
    # Tasks list test
    print_info "📝 Tasks list endpoint testi..."
    local tasks_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X GET "$API_BASE/tasks" \
        -H "Authorization: Bearer $token")
    
    local tasks_http_code=$(echo "$tasks_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$tasks_http_code" -eq 200 ]; then
        local tasks_body=$(echo "$tasks_response" | sed -e 's/HTTPSTATUS\:.*//g')
        local task_count=$(echo "$tasks_body" | jq length 2>/dev/null || echo "?")
        print_success "✓ Tasks list endpoint çalışıyor ($task_count görev)"
    else
        print_error "❌ Tasks list endpoint hatası: HTTP $tasks_http_code"
    fi
    
    # Sessions list test
    print_info "⏱️ Sessions list endpoint testi..."
    local sessions_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X GET "$API_BASE/sessions" \
        -H "Authorization: Bearer $token")
    
    local sessions_http_code=$(echo "$sessions_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$sessions_http_code" -eq 200 ]; then
        local sessions_body=$(echo "$sessions_response" | sed -e 's/HTTPSTATUS\:.*//g')
        local session_count=$(echo "$sessions_body" | jq length 2>/dev/null || echo "?")
        print_success "✓ Sessions list endpoint çalışıyor ($session_count oturum)"
    else
        print_error "❌ Sessions list endpoint hatası: HTTP $sessions_http_code"
    fi
    
    # Stats test
    print_info "📊 Stats endpoint testi..."
    local stats_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X GET "$API_BASE/sessions/stats" \
        -H "Authorization: Bearer $token")
    
    local stats_http_code=$(echo "$stats_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$stats_http_code" -eq 200 ]; then
        local stats_body=$(echo "$stats_response" | sed -e 's/HTTPSTATUS\:.*//g')
        local total_sessions=$(echo "$stats_body" | jq -r '.totalSessions' 2>/dev/null || echo "?")
        local total_time=$(echo "$stats_body" | jq -r '.totalStudyTime' 2>/dev/null || echo "?")
        print_success "✓ Stats endpoint çalışıyor (Toplam: $total_sessions oturum, $total_time dakika)"
    else
        print_error "❌ Stats endpoint hatası: HTTP $stats_http_code"
    fi
}

# Test sonuçlarını göster
show_test_summary() {
    print_header "Test Özeti"
    
    echo -e "${CYAN}📊 Oluşturulan Test Verileri:${NC}"
    echo -e "  👥 Kullanıcılar: ${GREEN}${#TOKENS[@]}${NC}"
    echo -e "  📝 Görevler: ${GREEN}${#TASK_IDS[@]}${NC}"
    echo -e "  ⏱️ Çalışma Oturumları: ${GREEN}${#SESSION_IDS[@]}${NC}"
    
    echo -e "\n${CYAN}🔗 Yararlı Linkler:${NC}"
    echo -e "  🌐 API Base URL: ${BLUE}$API_BASE${NC}"
    echo -e "  📚 Swagger UI: ${BLUE}$API_BASE/../swagger${NC}"
    echo -e "  📖 API Docs: ${BLUE}./API_DOCUMENTATION.md${NC}"
    
    echo -e "\n${CYAN}👤 Test Kullanıcısı:${NC}"
    echo -e "  📧 test@example.com ${YELLOW}(password: password123)${NC}"
    
    if [ ${#TOKENS[@]} -gt 0 ]; then
        echo -e "\n${CYAN}🧪 Örnek cURL Komutları:${NC}"
        local sample_token="${TOKENS[0]}"
        echo -e "  ${YELLOW}# Profil bilgilerini al:${NC}"
        echo -e "  curl -H \"Authorization: Bearer $sample_token\" $API_BASE/auth/profile"
        echo -e "  ${YELLOW}# Görevleri listele:${NC}"
        echo -e "  curl -H \"Authorization: Bearer $sample_token\" $API_BASE/tasks"
        echo -e "  ${YELLOW}# İstatistikleri al:${NC}"
        echo -e "  curl -H \"Authorization: Bearer $sample_token\" $API_BASE/sessions/stats"
    fi
    
    echo -e "\n${GREEN}🎉 Test tamamlandı!${NC}"
    echo -e "${CYAN}API'niz test verileriyle hazır ve çalışıyor.${NC}"
}

# Ana fonksiyon
main() {
    clear
    echo -e "${PURPLE}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║        🎯 CLUDY STUDY APP - API TEST SCRIPT V3              ║"
    echo "  ║                   (Basit ve Güvenilir)                      ║"
    echo "  ║                                                              ║"
    echo "  ║        Bu script API'nizi test eder ve dummy veriler         ║"
    echo "  ║        oluşturur. Hata mesajları detaylı gösterilir.        ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    # Gereksinimler kontrolü
    if ! command -v jq &> /dev/null; then
        print_error "jq bulunamadı. Lütfen jq'yu yükleyin:"
        print_info "Ubuntu/Debian: sudo apt-get install jq"
        print_info "CentOS/RHEL: sudo yum install jq"
        print_info "macOS: brew install jq"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        print_error "curl bulunamadı. Lütfen curl'u yükleyin."
        exit 1
    fi
    
    # Test aşamaları
    check_api_status
    create_test_user
    create_test_tasks
    create_test_sessions
    test_api_endpoints
    show_test_summary
}

# Script'i çalıştır
main "$@"
