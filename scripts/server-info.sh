#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/tmp/server-info-$(date +%F).log"

print_header() { echo -e "\033[1;34m=== $1 ===\033[0m"; }
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_FILE"; }

show_help() {
    echo "Usage: $(basename "$0") [URL1] [URL2] ..."
    echo "  --help  Show this help message"
    echo "  Collects system info and checks service availability."
    exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && show_help

check_dependencies() {
    command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }
}

get_system_info() {
    print_header "Server Diagnostics"
    log "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    log "Hostname: $(hostname)"
    log "OS: $(awk -F= '/^PRETTY_NAME=/ {gsub(/^"|"$/,"",$2); print $2; exit}' /etc/os-release 2>/dev/null || echo unknown)"
    log "Kernel: $(uname -r)"
    log "Uptime: $(uptime -p)"
}

get_resources() {
    print_header "Resources"
    local cores load ram_total ram_used disk_total disk_used
    cores=$(nproc)
    load=$(awk '{print $1}' /proc/loadavg)
    ram_total=$(free -h | awk '/Mem:/ {print $2}')
    ram_used=$(free -h | awk '/Mem:/ {print $3}')
    disk_total=$(df -h / | awk 'NR==2 {print $2}')
    disk_used=$(df -h / | awk 'NR==2 {print $3}')
    log "CPU: ${cores} cores, load: ${load}"
    log "RAM: ${ram_used}/${ram_total}"
    log "Disk(/): ${disk_used}/${disk_total}"
}

check_docker() {
    if command -v docker >/dev/null 2>&1; then
        print_header "Docker"
        if docker info >/dev/null 2>&1; then
            docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}" | tee -a "$LOG_FILE"
        else
            log "Docker CLI present but daemon is not reachable."
        fi
    else
        log "Docker not installed."
    fi
}

check_services() {
    print_header "Service Health Checks"
    local ok=0 fail=0 total=$# code
    for url in "$@"; do
        start_time=$(date +%s%N)
        code=$(curl -sS -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 15 "$url" || true)
        end_time=$(date +%s%N)
        if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then
            ms=$(( (end_time - start_time) / 1000000 ))
            log "[OK]  $url (HTTP ${code}, ${ms}ms)"
            ((ok++)) || true
        else
            log "[FAIL] $url (HTTP ${code:-???}, connection error or non-2xx)"
            ((fail++)) || true
        fi
    done
    log "Result: ${ok}/${total} services healthy"
    [[ $fail -gt 0 ]] && exit 1 || exit 0
}

check_dependencies
get_system_info
get_resources
check_docker
if [[ $# -gt 0 ]]; then
    check_services "$@"
fi