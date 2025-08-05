#!/bin/bash

# 🎯 Cludy Study App - API Test Script (Düzeltilmiş Versiyon)
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
declare -a TOKENS
declare -a USER_IDS
declare -a TASK_IDS
declare -a SESSION_IDS
declare -a TASK_OWNERS

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

# Test kullanıcıları oluştur
create_test_users() {
    print_header "Test Kullanıcıları Oluşturuluyor"
    
    # Test kullanıcı verileri
    local users=(
        '{"username":"ahmet","email":"ahmet@test.com","password":"password123"}'
        '{"username":"ayse","email":"ayse@test.com","password":"password123"}'
        '{"username":"mehmet","email":"mehmet@test.com","password":"password123"}'
        '{"username":"fatma","email":"fatma@test.com","password":"password123"}'
        '{"username":"admin","email":"admin@test.com","password":"password123"}'
    )
    
    for i in "${!users[@]}"; do
        local user_data="${users[$i]}"
        local username=$(echo "$user_data" | jq -r '.username')
        
        print_info "Kullanıcı oluşturuluyor: $username"
        
        local response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
            -X POST "$API_BASE/auth/register" \
            -H "Content-Type: application/json" \
            -d "$user_data")
        
        local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        local body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$http_code" -eq 200 ]; then
            local token=$(echo "$body" | jq -r '.token')
            local user_id=$(echo "$body" | jq -r '.user.id')
            
            TOKENS+=("$token")
            USER_IDS+=("$user_id")
            
            print_success "✓ $username (ID: $user_id) oluşturuldu"
        else
            # Kullanıcı zaten varsa login ol
            print_warning "$username zaten mevcut, giriş yapılıyor..."
            
            local login_data="{\"email\":\"$(echo "$user_data" | jq -r '.email')\",\"password\":\"$(echo "$user_data" | jq -r '.password')\"}"
            
            local login_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                -X POST "$API_BASE/auth/login" \
                -H "Content-Type: application/json" \
                -d "$login_data")
            
            local login_http_code=$(echo "$login_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            local login_body=$(echo "$login_response" | sed -e 's/HTTPSTATUS\:.*//g')
            
            if [ "$login_http_code" -eq 200 ]; then
                local token=$(echo "$login_body" | jq -r '.token')
                local user_id=$(echo "$login_body" | jq -r '.user.id')
                
                TOKENS+=("$token")
                USER_IDS+=("$user_id")
                
                print_success "✓ $username (ID: $user_id) giriş yaptı"
            else
                print_error "❌ $username için giriş başarısız"
            fi
        fi
        
        sleep 0.5
    done
    
    print_success "Toplam ${#TOKENS[@]} kullanıcı hazır"
}

# Test görevleri oluştur
create_test_tasks() {
    print_header "Test Görevleri Oluşturuluyor"
    
    # Görev kategorileri
    local task_categories=(
        "JavaScript ES6 özelliklerini öğren:Async/await, destructuring, arrow functions"
        "Calculus I:Türev ve integral konularını çalış"
        "İngilizce Grammar:Present perfect ve past perfect zamanlar"
        "Koşu Antrenmanı:Dayanıklılık için 5km koşu planı"
        "Piyano Pratiği:Bach Invention No.1 çalışması"
        "Kitap Okuma:Clean Code kitabının 3. bölümü"
        "UI/UX Çalışması:Figma ile prototype oluşturma"
        "Fizik:Quantum mekaniği temel prensipleri"
        "Çizim Pratiği:Perspektif ve gölgelendirme teknikleri"
        "Docker:Container ve image kavramları"
    )
    
    # Her kullanıcı için görevler oluştur
    for i in "${!TOKENS[@]}"; do
        local token="${TOKENS[$i]}"
        local user_id="${USER_IDS[$i]}"
        
        print_info "Kullanıcı $user_id için görevler oluşturuluyor..."
        
        # Her kullanıcı için 2-3 görev oluştur
        local num_tasks=$((RANDOM % 2 + 2))
        
        for ((j=0; j<num_tasks; j++)); do
            # Rastgele görev seç
            local random_index=$((RANDOM % ${#task_categories[@]}))
            local task_info="${task_categories[$random_index]}"
            
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
                TASK_OWNERS+=("$i")  # Token index'ini sakla
                print_success "  ✓ Görev oluşturuldu: $title (ID: $task_id, Owner: $user_id)"
            else
                print_error "  ❌ Görev oluşturulamadı: $title"
            fi
            
            sleep 0.2
        done
    done
    
    # Anonim görevler oluştur
    print_info "Anonim görevler oluşturuluyor..."
    
    local anonymous_tasks=(
        '{"title":"Anonim Çalışma","description":"Giriş yapmadan çalışma denemesi"}'
        '{"title":"Demo Görev","description":"Test amaçlı anonim görev"}'
        '{"title":"Hızlı Notlar","description":"Geçici notlar için görev"}'
    )
    
    for task_data in "${anonymous_tasks[@]}"; do
        local title=$(echo "$task_data" | jq -r '.title')
        
        local response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
            -X POST "$API_BASE/tasks" \
            -H "Content-Type: application/json" \
            -d "$task_data")
        
        local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        local body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$http_code" -eq 201 ]; then
            local task_id=$(echo "$body" | jq -r '.id')
            TASK_IDS+=("$task_id")
            TASK_OWNERS+=("-1")  # Anonim görev
            print_success "  ✓ Anonim görev: $title (ID: $task_id)"
        fi
        
        sleep 0.2
    done
    
    print_success "Toplam ${#TASK_IDS[@]} görev oluşturuldu"
}

# Test çalışma oturumları oluştur
create_test_sessions() {
    print_header "Test Çalışma Oturumları Oluşturuluyor"
    
    local session_types=("pomodoro" "free")
    local durations=(15 25 30 45 60)
    local session_count=0
    
    # Her görev için oturumlar oluştur
    for i in "${!TASK_IDS[@]}"; do
        local task_id="${TASK_IDS[$i]}"
        local owner_index="${TASK_OWNERS[$i]}"
        
        # Her görev için 1-3 oturum oluştur
        local num_sessions=$((RANDOM % 3 + 1))
        
        for ((j=0; j<num_sessions; j++)); do
            # Rastgele oturum özellikleri
            local session_type="${session_types[$((RANDOM % ${#session_types[@]}))]}"
            local duration="${durations[$((RANDOM % ${#durations[@]}))]}"
            
            local session_data="{\"taskId\":$task_id,\"duration\":$duration,\"type\":\"$session_type\"}"
            
            local response
            
            if [ "$owner_index" -eq -1 ]; then
                # Anonim oturum
                response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                    -X POST "$API_BASE/sessions" \
                    -H "Content-Type: application/json" \
                    -d "$session_data")
            else
                # Kullanıcı oturumu - Doğru token kullan
                local token="${TOKENS[$owner_index]}"
                response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                    -X POST "$API_BASE/sessions" \
                    -H "Content-Type: application/json" \
                    -H "Authorization: Bearer $token" \
                    -d "$session_data")
            fi
            
            local http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            local body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
            
            if [ "$http_code" -eq 201 ]; then
                local session_id=$(echo "$body" | jq -r '.id')
                SESSION_IDS+=("$session_id")
                session_count=$((session_count + 1))
                
                # %60 olasılıkla oturumu tamamla
                if [ $((RANDOM % 10)) -lt 6 ]; then
                    local complete_response
                    
                    if [ "$owner_index" -eq -1 ]; then
                        complete_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                            -X PUT "$API_BASE/sessions/$session_id/complete")
                    else
                        local token="${TOKENS[$owner_index]}"
                        complete_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                            -X PUT "$API_BASE/sessions/$session_id/complete" \
                            -H "Authorization: Bearer $token")
                    fi
                    
                    local complete_http_code=$(echo "$complete_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
                    
                    if [ "$complete_http_code" -eq 200 ]; then
                        print_success "  ✓ Oturum oluşturuldu ve tamamlandı: $session_type ($duration dk) - Görev $task_id"
                    else
                        print_success "  ✓ Oturum oluşturuldu: $session_type ($duration dk) - Görev $task_id"
                    fi
                else
                    print_success "  ✓ Oturum oluşturuldu: $session_type ($duration dk) - Görev $task_id"
                fi
            else
                # Hata detayını göster
                local error_message=$(echo "$body" | jq -r '.message // .title // "Bilinmeyen hata"' 2>/dev/null || echo "JSON parse hatası")
                print_error "  ❌ Oturum oluşturulamadı - Görev $task_id: HTTP $http_code - $error_message"
            fi
            
            sleep 0.2
        done
    done
    
    print_success "Toplam $session_count çalışma oturumu oluşturuldu"
}

# Bazı görevleri tamamlanmış olarak işaretle
mark_some_tasks_completed() {
    print_header "Bazı Görevler Tamamlanıyor"
    
    local completed_count=0
    
    for i in "${!TASK_IDS[@]}"; do
        local task_id="${TASK_IDS[$i]}"
        local owner_index="${TASK_OWNERS[$i]}"
        
        # %30 olasılıkla görevi tamamla
        if [ $((RANDOM % 10)) -lt 3 ] && [ "$owner_index" -ne -1 ]; then
            local token="${TOKENS[$owner_index]}"
            
            # Görev bilgilerini al
            local get_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                -X GET "$API_BASE/tasks/$task_id" \
                -H "Authorization: Bearer $token")
            
            local get_http_code=$(echo "$get_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
            local get_body=$(echo "$get_response" | sed -e 's/HTTPSTATUS\:.*//g')
            
            if [ "$get_http_code" -eq 200 ]; then
                local title=$(echo "$get_body" | jq -r '.title')
                local description=$(echo "$get_body" | jq -r '.description')
                
                # Görevi tamamlanmış olarak güncelle
                local update_data="{\"title\":\"$title\",\"description\":\"$description\",\"isCompleted\":true}"
                
                local update_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
                    -X PUT "$API_BASE/tasks/$task_id" \
                    -H "Content-Type: application/json" \
                    -H "Authorization: Bearer $token" \
                    -d "$update_data")
                
                local update_http_code=$(echo "$update_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
                
                if [ "$update_http_code" -eq 200 ]; then
                    completed_count=$((completed_count + 1))
                    print_success "  ✓ Görev tamamlandı: $title"
                fi
            fi
        fi
        
        sleep 0.1
    done
    
    print_success "$completed_count görev tamamlanmış olarak işaretlendi"
}

# API endpoint'leri test et
test_api_endpoints() {
    print_header "API Endpoint'leri Test Ediliyor"
    
    if [ ${#TOKENS[@]} -eq 0 ]; then
        print_warning "Test için kullanıcı bulunamadı, sadece anonim testler yapılacak"
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
        print_success "  ✓ Profile endpoint çalışıyor"
    else
        print_error "  ❌ Profile endpoint hatası"
    fi
    
    # Tasks list test
    print_info "📝 Tasks list endpoint testi..."
    local tasks_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X GET "$API_BASE/tasks" \
        -H "Authorization: Bearer $token")
    
    local tasks_http_code=$(echo "$tasks_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$tasks_http_code" -eq 200 ]; then
        local tasks_body=$(echo "$tasks_response" | sed -e 's/HTTPSTATUS\:.*//g')
        local task_count=$(echo "$tasks_body" | jq length)
        print_success "  ✓ Tasks list endpoint çalışıyor ($task_count görev)"
    else
        print_error "  ❌ Tasks list endpoint hatası"
    fi
    
    # Sessions list test
    print_info "⏱️ Sessions list endpoint testi..."
    local sessions_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X GET "$API_BASE/sessions" \
        -H "Authorization: Bearer $token")
    
    local sessions_http_code=$(echo "$sessions_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$sessions_http_code" -eq 200 ]; then
        local sessions_body=$(echo "$sessions_response" | sed -e 's/HTTPSTATUS\:.*//g')
        local session_count=$(echo "$sessions_body" | jq length)
        print_success "  ✓ Sessions list endpoint çalışıyor ($session_count oturum)"
    else
        print_error "  ❌ Sessions list endpoint hatası"
    fi
    
    # Stats test
    print_info "📊 Stats endpoint testi..."
    local stats_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -X GET "$API_BASE/sessions/stats" \
        -H "Authorization: Bearer $token")
    
    local stats_http_code=$(echo "$stats_response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$stats_http_code" -eq 200 ]; then
        local stats_body=$(echo "$stats_response" | sed -e 's/HTTPSTATUS\:.*//g')
        local total_sessions=$(echo "$stats_body" | jq -r '.totalSessions')
        local total_time=$(echo "$stats_body" | jq -r '.totalStudyTime')
        print_success "  ✓ Stats endpoint çalışıyor (Toplam: $total_sessions oturum, $total_time dakika)"
    else
        print_error "  ❌ Stats endpoint hatası"
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
    
    echo -e "\n${CYAN}👤 Test Kullanıcıları:${NC}"
    local test_users=("ahmet@test.com" "ayse@test.com" "mehmet@test.com" "fatma@test.com" "admin@test.com")
    for email in "${test_users[@]}"; do
        echo -e "  📧 $email ${YELLOW}(password: password123)${NC}"
    done
    
    echo -e "\n${CYAN}🧪 Örnek cURL Komutları:${NC}"
    if [ ${#TOKENS[@]} -gt 0 ]; then
        local sample_token="${TOKENS[0]}"
        echo -e "  ${YELLOW}# Profil bilgilerini al:${NC}"
        echo -e "  curl -H \"Authorization: Bearer $sample_token\" $API_BASE/auth/profile"
        echo -e "  ${YELLOW}# Görevleri listele:${NC}"
        echo -e "  curl -H \"Authorization: Bearer $sample_token\" $API_BASE/tasks"
        echo -e "  ${YELLOW}# İstatistikleri al:${NC}"
        echo -e "  curl -H \"Authorization: Bearer $sample_token\" $API_BASE/sessions/stats"
    fi
    
    echo -e "\n${GREEN}🎉 Test verileri başarıyla oluşturuldu!${NC}"
    echo -e "${CYAN}Artık API'nizi test edebilir ve geliştirmeye devam edebilirsiniz.${NC}"
}

# Ana fonksiyon
main() {
    clear
    echo -e "${PURPLE}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║                                                              ║"
    echo "  ║        🎯 CLUDY STUDY APP - API TEST SCRIPT V2              ║"
    echo "  ║                                                              ║"
    echo "  ║        Bu script API'nizi test eder ve dummy veriler         ║"
    echo "  ║        oluşturur. Test tamamlandıktan sonra API'yi          ║"
    echo "  ║        cURL, Postman veya frontend ile test edebilirsiniz.   ║"
    echo "  ║                                                              ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    # jq kontrolü
    if ! command -v jq &> /dev/null; then
        print_error "jq bulunamadı. Lütfen jq'yu yükleyin:"
        print_info "Ubuntu/Debian: sudo apt-get install jq"
        print_info "CentOS/RHEL: sudo yum install jq"
        print_info "macOS: brew install jq"
        exit 1
    fi
    
    # curl kontrolü
    if ! command -v curl &> /dev/null; then
        print_error "curl bulunamadı. Lütfen curl'u yükleyin."
        exit 1
    fi
    
    # Test aşamaları
    check_api_status
    create_test_users
    create_test_tasks
    create_test_sessions
    mark_some_tasks_completed
    test_api_endpoints
    show_test_summary
}

# Script'i çalıştır
main "$@"
