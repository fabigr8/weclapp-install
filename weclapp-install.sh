#!/bin/bash

# WeclappON Installation und Verwaltungsscript
# Autor: Automatisierte Installation basierend auf offizieller Anleitung
# Alle Befehle müssen als root ausgeführt werden

set -e  # Bei Fehlern abbrechen

# Konfiguration
WECLAPP_DIR="/opt/weclapp"
DATA_DIR="/opt/weclapp-data"
COMPOSE_URL="https://support.weclapp.com/webapp/document/52b51d99-3651-47b6-b1d2-04147b583e3b/kuxclekzjhrrvoax/docker-compose.yml"
# COMPOSE_EXTENDED_URL=""  # URL für erweiterte Datei hier einfügen

# Farben für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Root-Berechtigung prüfen
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Dieses Script muss als root ausgeführt werden"
        exit 1
    fi
}

# Docker installieren (Ubuntu/Debian)
install_docker() {
    log_info "=== Docker Installation ==="
    
    if command -v docker >/dev/null 2>&1; then
        log_info "Docker ist bereits installiert"
        docker --version
        docker compose version
        return 0
    fi
    
    log_info "Docker wird installiert..."
    
    # Pakete aktualisieren
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    
    # Docker GPG Key hinzufügen
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Docker Repository hinzufügen
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Docker installieren
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Docker Service aktivieren
    systemctl enable docker
    systemctl start docker
    
    log_success "Docker erfolgreich installiert"
    docker --version
    docker compose version
}

# Datenverzeichnisse erstellen
create_directories() {
    log_info "=== Datenverzeichnisse erstellen ==="
    
    mkdir -p "$DATA_DIR/db" "$DATA_DIR/blobs" "$DATA_DIR/solr"
    chmod 777 "$DATA_DIR/db" "$DATA_DIR/blobs" "$DATA_DIR/solr"
    
    log_success "Verzeichnisse erstellt: $DATA_DIR/{db,blobs,solr}"
}

# Docker Compose Datei herunterladen
download_compose() {
    local extended=${1:-false}
    log_info "=== Docker Compose Datei herunterladen ==="
    
    mkdir -p "$WECLAPP_DIR"
    
    if [[ "$extended" == "true" ]]; then
        if [[ -z "$COMPOSE_EXTENDED_URL" ]]; then
            log_error "COMPOSE_EXTENDED_URL ist nicht gesetzt"
            exit 1
        fi
        log_info "Lade erweiterte docker-compose.yml herunter..."
        curl -L "$COMPOSE_EXTENDED_URL" > "$WECLAPP_DIR/docker-compose.yml"
        log_success "Erweiterte docker-compose.yml heruntergeladen"
    else
        log_info "Lade docker-compose.yml herunter..."
        curl -L "$COMPOSE_URL" > "$WECLAPP_DIR/docker-compose.yml"
        log_success "docker-compose.yml heruntergeladen"
    fi
}

# WeclappON starten
start_weclapp() {
    log_info "=== WeclappON starten ==="
    
    if [[ ! -f "$WECLAPP_DIR/docker-compose.yml" ]]; then
        log_error "docker-compose.yml nicht gefunden. Führen Sie zuerst die Installation durch."
        exit 1
    fi
    
    cd "$WECLAPP_DIR"
    docker compose up -d
    
    log_success "WeclappON gestartet"
    log_info "Zugriff über: http://localhost:8080"
    log_info "Logs anzeigen mit: $0 logs"
}

# WeclappON stoppen
stop_weclapp() {
    log_info "=== WeclappON stoppen ==="
    
    cd "$WECLAPP_DIR"
    docker compose stop
    
    log_success "WeclappON gestoppt"
}

# WeclappON neu starten
restart_weclapp() {
    log_info "=== WeclappON neu starten ==="
    
    cd "$WECLAPP_DIR"
    docker compose restart
    
    log_success "WeclappON neu gestartet"
}

# WeclappON aktualisieren
update_weclapp() {
    log_info "=== WeclappON Update ==="
    
    cd "$WECLAPP_DIR"
    docker compose pull
    docker compose up -d
    
    log_success "WeclappON auf neueste Version aktualisiert"
}

# Logs anzeigen
show_logs() {
    log_info "=== WeclappON Logs (Ctrl+C zum Beenden) ==="
    
    cd "$WECLAPP_DIR"
    docker logs -f weclapp_app
}

# Status anzeigen
show_status() {
    log_info "=== Container Status ==="
    
    cd "$WECLAPP_DIR"
    docker compose ps
}

# Container entfernen (Daten bleiben)
clean_containers() {
    log_warning "=== Container entfernen ==="
    
    read -p "Sind Sie sicher, dass Sie alle Container entfernen möchten? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$WECLAPP_DIR"
        docker compose down
        log_success "Container entfernt. Daten in $DATA_DIR bleiben erhalten."
    else
        log_info "Abgebrochen."
    fi
}

# Vollständige Deinstallation
uninstall_weclapp() {
    log_error "=== WARNUNG: Vollständige Deinstallation ==="
    log_error "Dies löscht ALLE weclappON Daten unwiderruflich!"
    
    read -p "Sind Sie WIRKLICH sicher? Geben Sie 'LÖSCHEN' ein: " confirm
    if [[ "$confirm" == "LÖSCHEN" ]]; then
        cd "$WECLAPP_DIR"
        docker compose down -v
        rm -rf "$WECLAPP_DIR" "$DATA_DIR"
        log_success "WeclappON vollständig deinstalliert."
    else
        log_info "Abgebrochen."
    fi
}

# Hilfe anzeigen
show_help() {
    cat << EOF
WeclappON Installation und Verwaltungsscript

Verwendung: $0 [OPTION]

Optionen:
  install           Komplette Installation durchführen
  install-extended  Installation mit erweiterter Compose-Datei (für Drucken)
  start             WeclappON starten
  stop              WeclappON stoppen  
  restart           WeclappON neu starten
  update            Auf neueste Version aktualisieren
  logs              Logs anzeigen
  status            Container Status anzeigen
  clean             Container entfernen (Daten bleiben)
  uninstall         Vollständige Deinstallation (ALLE Daten werden gelöscht!)
  help              Diese Hilfe anzeigen

Beispiele:
  $0 install        # Komplette Installation
  $0 start          # WeclappON starten
  $0 logs           # Logs verfolgen
  $0 update         # Update durchführen

Hinweise:
- Alle Befehle müssen als root ausgeführt werden
- Nach der Installation ist WeclappON unter http://localhost:8080 erreichbar
- Daten werden in $DATA_DIR gespeichert
EOF
}

# Hauptfunktion
main() {
    case "${1:-}" in
        "install")
            check_root
            install_docker
            create_directories
            download_compose false
            log_success "=== WeclappON Installation abgeschlossen ==="
            log_info "Starten Sie weclappON mit: $0 start"
            ;;
        "install-extended")
            check_root
            install_docker
            create_directories
            download_compose true
            log_success "=== WeclappON Installation (erweitert) abgeschlossen ==="
            log_info "Starten Sie weclappON mit: $0 start"
            ;;
        "start")
            check_root
            start_weclapp
            ;;
        "stop")
            check_root
            stop_weclapp
            ;;
        "restart")
            check_root
            restart_weclapp
            ;;
        "update")
            check_root
            update_weclapp
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "clean")
            check_root
            clean_containers
            ;;
        "uninstall")
            check_root
            uninstall_weclapp
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
            show_help
            ;;
        *)
            log_error "Unbekannte Option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Script ausführen
main "$@"
