#!/bin/bash

# Ścieżki
RULES_DIR="/var/ossec/etc/rules"
BACKUP_DIR="/var/ossec/etc/rules_backup_$(date +%Y%m%d_%H%M%S)"
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/socfortress/WazuhRules/main/wazuh_socfortress_rules.sh"
LOCAL_SCRIPT="/tmp/wazuh_socfortress_rules.sh"

echo "📦 Tworzenie kopii zapasowej reguł Wazuh..."
if [ -d "$RULES_DIR" ]; then
    cp -r "$RULES_DIR" "$BACKUP_DIR"
    echo "✅ Backup zapisany w: $BACKUP_DIR"
else
    echo "❌ Nie znaleziono katalogu reguł: $RULES_DIR"
    exit 1
fi

echo "🌐 Pobieranie skryptu instalacyjnego SOCFortress..."
curl -s -o "$LOCAL_SCRIPT" "$INSTALL_SCRIPT_URL"

if [ -f "$LOCAL_SCRIPT" ]; then
    echo "🚀 Uruchamianie skryptu instalacyjnego..."
    bash "$LOCAL_SCRIPT"
else
    echo "❌ Nie udało się pobrać skryptu z: $INSTALL_SCRIPT_URL"
    exit 1
fi

echo "🔄 Restartowanie Wazuh Manager..."
systemctl restart wazuh-manager

echo "✅ Instalacja reguł SOCFortress zakończona pomyślnie."
