#!/bin/bash

# Überprüfen, ob das Skript als root ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
  echo "Dieses Skript muss als root ausgeführt werden. Bitte führen Sie es mit 'sudo' aus."
  exit 1
fi

# Überprüfen, ob das System WSL (Windows Subsystem for Linux) ist
if grep -q "Microsoft" /proc/version; then
  echo "Dieses Skript ist nicht für WSL-Systeme vorgesehen. Bitte führen Sie es unter einem nativen Linux-System aus."
  exit 1
fi

# Die .env-Datei einlesen
if [ ! -f .env ]; then
  echo "Die .env-Datei wurde nicht gefunden. Bitte stellen Sie sicher, dass sie im aktuellen Verzeichnis vorhanden ist."
  exit 1
fi
source .env

# Die /etc/hosts-Datei aktualisieren
if grep -q "^[^#]*\s*$DOMAIN\s*$" /etc/hosts; then
  sed -i "/\s$DOMAIN\s*$/ s/^[^#]*/127.0.0.1/" /etc/hosts
  if [ $? -eq 0 ]; then
    echo "Die /etc/hosts-Datei wurde erfolgreich aktualisiert."
  else
    echo "Fehler beim Aktualisieren der /etc/hosts-Datei."
    exit 1
  fi
else
  echo -e "127.0.0.1\t$DOMAIN" >> /etc/hosts
  if [ $? -eq 0 ]; then
    echo "Die /etc/hosts-Datei wurde erfolgreich aktualisiert."
  else
    echo "Fehler beim Hinzufügen der Domain zur /etc/hosts-Datei."
    exit 1
  fi
fi

exit 0