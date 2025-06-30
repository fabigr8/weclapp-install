# WeclappON Installation Makefile
# Alle Befehle müssen als root ausgeführt werden

WECLAPP_DIR = /opt/weclapp
DATA_DIR = /opt/weclapp-data
COMPOSE_URL = https://support.weclapp.com/webapp/document/52b51d99-3651-47b6-b1d2-04147b583e3b/kuxclekzjhrrvoax/docker-compose.yml
COMPOSE_EXTENDED_URL = # URL für erweiterte Datei hier einfügen

.PHONY: help install check-root install-docker create-dirs download-compose start stop restart update logs clean

help: ## Zeigt diese Hilfe an
	@echo "WeclappON Installation und Verwaltung"
	@echo ""
	@echo "Verfügbare Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

check-root: ## Prüft ob als root ausgeführt wird
	@if [ "$$(id -u)" != "0" ]; then \
		echo "Fehler: Dieses Script muss als root ausgeführt werden"; \
		exit 1; \
	fi

install-docker: check-root ## Installiert Docker (Ubuntu/Debian)
	@echo "=== Docker Installation ==="
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "Docker wird installiert..."; \
		apt-get update; \
		apt-get install -y ca-certificates curl gnupg lsb-release; \
		mkdir -p /etc/apt/keyrings; \
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
		echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; \
		apt-get update; \
		apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin; \
		systemctl enable docker; \
		systemctl start docker; \
		echo "Docker erfolgreich installiert"; \
	else \
		echo "Docker ist bereits installiert"; \
	fi
	@echo "Docker Version: $$(docker --version)"
	@echo "Docker Compose Version: $$(docker compose version)"

create-dirs: check-root ## Erstellt die Datenverzeichnisse
	@echo "=== Datenverzeichnisse erstellen ==="
	mkdir -p $(DATA_DIR)/db $(DATA_DIR)/blobs $(DATA_DIR)/solr
	chmod 777 $(DATA_DIR)/db $(DATA_DIR)/blobs $(DATA_DIR)/solr
	@echo "Verzeichnisse erstellt: $(DATA_DIR)/{db,blobs,solr}"

download-compose: check-root ## Lädt die docker-compose.yml herunter
	@echo "=== Docker Compose Datei herunterladen ==="
	mkdir -p $(WECLAPP_DIR)
	curl -L $(COMPOSE_URL) > $(WECLAPP_DIR)/docker-compose.yml
	@echo "docker-compose.yml heruntergeladen nach $(WECLAPP_DIR)/"

download-compose-extended: check-root ## Lädt die erweiterte docker-compose.yml herunter (für Drucken)
	@echo "=== Erweiterte Docker Compose Datei herunterladen ==="
	@if [ -z "$(COMPOSE_EXTENDED_URL)" ]; then \
		echo "Fehler: COMPOSE_EXTENDED_URL ist nicht gesetzt"; \
		exit 1; \
	fi
	mkdir -p $(WECLAPP_DIR)
	curl -L $(COMPOSE_EXTENDED_URL) > $(WECLAPP_DIR)/docker-compose.yml
	@echo "Erweiterte docker-compose.yml heruntergeladen nach $(WECLAPP_DIR)/"

install: install-docker create-dirs download-compose ## Komplette Installation durchführen
	@echo "=== WeclappON Installation abgeschlossen ==="
	@echo "Starten Sie weclappON mit: make start"
	@echo "Oder direkt: cd $(WECLAPP_DIR) && docker compose up -d"

install-extended: install-docker create-dirs download-compose-extended ## Installation mit erweiterter Compose-Datei
	@echo "=== WeclappON Installation (erweitert) abgeschlossen ==="
	@echo "Starten Sie weclappON mit: make start"

start: check-root ## Startet weclappON
	@echo "=== WeclappON starten ==="
	cd $(WECLAPP_DIR) && docker compose up -d
	@echo "WeclappON gestartet. Zugriff über: http://localhost:8080"
	@echo "Logs anzeigen mit: make logs"

stop: check-root ## Stoppt weclappON
	@echo "=== WeclappON stoppen ==="
	cd $(WECLAPP_DIR) && docker compose stop
	@echo "WeclappON gestoppt"

restart: check-root ## Startet weclappON neu
	@echo "=== WeclappON neu starten ==="
	cd $(WECLAPP_DIR) && docker compose restart
	@echo "WeclappON neu gestartet"

update: check-root ## Aktualisiert weclappON auf die neueste Version
	@echo "=== WeclappON Update ==="
	cd $(WECLAPP_DIR) && docker compose pull
	cd $(WECLAPP_DIR) && docker compose up -d
	@echo "WeclappON auf neueste Version aktualisiert"

logs: ## Zeigt die Logs von weclappON an
	@echo "=== WeclappON Logs (Ctrl+C zum Beenden) ==="
	cd $(WECLAPP_DIR) && docker logs -f weclapp_app

status: ## Zeigt den Status der Container an
	@echo "=== Container Status ==="
	cd $(WECLAPP_DIR) && docker compose ps

clean: check-root ## Entfernt alle Container (Daten bleiben erhalten)
	@echo "=== Container entfernen ==="
	@read -p "Sind Sie sicher, dass Sie alle Container entfernen möchten? (y/N): " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		cd $(WECLAPP_DIR) && docker compose down; \
		echo "Container entfernt. Daten in $(DATA_DIR) bleiben erhalten."; \
	else \
		echo "Abgebrochen."; \
	fi

uninstall: check-root ## Vollständige Deinstallation (ACHTUNG: Löscht alle Daten!)
	@echo "=== WARNUNG: Vollständige Deinstallation ==="
	@echo "Dies löscht ALLE weclappON Daten unwiderruflich!"
	@read -p "Sind Sie WIRKLICH sicher? Geben Sie 'LÖSCHEN' ein: " confirm && \
	if [ "$$confirm" = "LÖSCHEN" ]; then \
		cd $(WECLAPP_DIR) && docker compose down -v; \
		rm -rf $(WECLAPP_DIR) $(DATA_DIR); \
		echo "WeclappON vollständig deinstalliert."; \
	else \
		echo "Abgebrochen."; \
	fi
