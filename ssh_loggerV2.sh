#!/bin/bash

# SSH Logger V2
# ===== KONFIGURATION =====
# Discord Webhook URL - NUR HIER EINTRAGEN!
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/<ID>/<TOKEN>"

# Server Display Name - HIER DEINEN SERVERNAMEN EINTRAGEN!
SERVER_DISPLAY_NAME="Server-01"

# ===== SYSTEM INFORMATIONEN =====
SERVER_NAME=$(hostname -f)
SERVER_IP=$(hostname -I | awk '{print $1}')
USERNAME=${USER}
HOSTNAME=$(hostname)

# SSH Connection Details
if [ -n "$SSH_CLIENT" ]; then
    USER_IP=$(echo $SSH_CLIENT | awk '{print $1}')
    USER_PORT=$(echo $SSH_CLIENT | awk '{print $2}')
    SERVER_PORT=$(echo $SSH_CLIENT | awk '{print $3}')
else
    USER_IP="Local"
    USER_PORT="N/A"
    SERVER_PORT="N/A"
fi

# Deutsches Zeitformat mit korrekter Zeitzone (DD.MM.YYYY HH:MM:SS)
export TZ='Europe/Berlin'
LOGIN_TIME=$(date '+%d.%m.%Y %H:%M:%S')

# OS Info
OS_INFO=$(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)

# Uptime
UPTIME_INFO=$(uptime -p | sed 's/up //')

# Load Average
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | xargs)

# Geolocation
if [ -n "$USER_IP" ] && [ "$USER_IP" != "127.0.0.1" ] && [ "$USER_IP" != "Local" ]; then
    GEO_DATA=$(curl -s "https://ipinfo.io/${USER_IP}/json")
    if [ $? -eq 0 ]; then
        CITY=$(echo "$GEO_DATA" | grep -Po '"city":\s*"\K[^"]*' || echo "Unknown")
        REGION=$(echo "$GEO_DATA" | grep -Po '"region":\s*"\K[^"]*' || echo "Unknown")
        COUNTRY=$(echo "$GEO_DATA" | grep -Po '"country":\s*"\K[^"]*' || echo "Unknown")
        ISP=$(echo "$GEO_DATA" | grep -Po '"org":\s*"\K[^"]*' || echo "Unknown")
        GEOLOCATION="${CITY}, ${REGION}, ${COUNTRY}"
    else
        GEOLOCATION="Unable to determine"
        ISP="Unable to determine"
    fi
else
    GEOLOCATION="Local connection"
    ISP="N/A"
fi

# Farbe (rot für root, grün für andere)
if [ "$USERNAME" = "root" ]; then
    COLOR="16711680"
else
    COLOR="65280"
fi

# Discord Nachricht senden
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{
  \"embeds\": [
    {
      \"title\": \"🔐 ${SERVER_DISPLAY_NAME} - SSH Login\",
      \"description\": \"New SSH connection established on ${SERVER_DISPLAY_NAME}\",
      \"color\": ${COLOR},
      \"fields\": [
        {
          \"name\": \"👤 User\",
          \"value\": \"\`${USERNAME}\`\",
          \"inline\": true
        },
        {
          \"name\": \"🖥️ Hostname\",
          \"value\": \"\`${HOSTNAME}\`\",
          \"inline\": true
        },
        {
          \"name\": \"🌐 Server IP\",
          \"value\": \"\`${SERVER_IP}\`\",
          \"inline\": true
        },
        {
          \"name\": \"📍 User IP\",
          \"value\": \"\`${USER_IP}\`\",
          \"inline\": true
        },
        {
          \"name\": \"🔌 User Port\",
          \"value\": \"\`${USER_PORT}\`\",
          \"inline\": true
        },
        {
          \"name\": \"🚪 Server Port\",
          \"value\": \"\`${SERVER_PORT}\`\",
          \"inline\": true
        },
        {
          \"name\": \"💻 Server OS\",
          \"value\": \"\`${OS_INFO}\`\",
          \"inline\": false
        },
        {
          \"name\": \"⏱️ Uptime\",
          \"value\": \"\`${UPTIME_INFO}\`\",
          \"inline\": true
        },
        {
          \"name\": \"📊 Load Average\",
          \"value\": \"\`${LOAD_AVG}\`\",
          \"inline\": true
        },
        {
          \"name\": \"🕒 Login Time\",
          \"value\": \"\`${LOGIN_TIME} Uhr\`\",
          \"inline\": false
        },
        {
          \"name\": \"🗺️ Geolocation\",
          \"value\": \"\`${GEOLOCATION}\`\",
          \"inline\": true
        },
        {
          \"name\": \"🏢 ISP/Organisation\",
          \"value\": \"\`${ISP}\`\",
          \"inline\": true
        }
      ],
      \"footer\": {
        \"text\": \"${SERVER_DISPLAY_NAME} • SSH Logger V2 • ${LOGIN_TIME} Uhr\"
      },
      \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\"
    }
  ]
}" \
     "$DISCORD_WEBHOOK_URL" 2>/dev/null
