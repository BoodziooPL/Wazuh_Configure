#!/bin/bash

# Ścieżka do katalogu z pluginem
PLUGIN_DIR="/usr/share/wazuh-dashboard/bin"
PLUGIN_NAME="anomalyDetectionDashboards"

echo "🔍 Przechodzę do katalogu: $PLUGIN_DIR"
cd "$PLUGIN_DIR" || { echo "❌ Nie można przejść do katalogu $PLUGIN_DIR"; exit 1; }

echo "🚀 Instaluję plugin: $PLUGIN_NAME"
sudo -u wazuh-dashboard ./opensearch-dashboards-plugin install "$PLUGIN_NAME"

# Sprawdzenie, czy plugin został zainstalowany
echo "📦 Lista zainstalowanych pluginów:"
sudo -u wazuh-dashboard ./opensearch-dashboards-plugin list

echo "✅ Instalacja zakończona."
