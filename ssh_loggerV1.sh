#!/bin/bash

WEBHOOK_URL="WEBHOOK_URL"
# Server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# User IP
USER_IP=$(echo $SSH_CONNECTION | awk '{print $1}')

# User Name
USER_NAME=$(whoami)

# Login Time
LOGIN_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Geolocation Information
GEO_INFO=$(curl -s "https://ipinfo.io/$USER_IP/json" | jq -r '.city, .region, .country' 2>/dev/null | tr '\n' ', ' | sed 's/, $//')

# Fallback, falls keine Informationen verfügbar sind
if [ -z "$GEO_INFO" ] || [ "$GEO_INFO" = ", ," ]; then
  GEO_INFO="Not Available"
fi

# ISP/Organisation Information
ISP=$(curl -s "https://ipinfo.io/$USER_IP/json" | jq -r '.org' 2>/dev/null)

# Fallback, falls keine Informationen verfügbar sind
if [ -z "$ISP" ]; then
  ISP="Not Available"
fi

# User Agent
USER_AGENT=$(ps -o args= -p $$ | tr -d '\0')

# Erstelle den Payload für den Webhook
# Erstelle den Payload für den Webhook
read -r -d '' PAYLOAD <<EOF
{
  "embeds": [{
    "title": "🔐 NEW LOGIN REGISTERED",
    "color": 16711680,
    "fields": [
      {"name": "Server IP", "value": "$SERVER_IP", "inline": true},
      {"name": "User IP", "value": "$USER_IP", "inline": true},
      {"name": "User", "value": "$USER_NAME", "inline": true},
      {"name": "Login Time", "value": "$LOGIN_TIME", "inline": false},
      {"name": "Geolocation", "value": "$GEO_INFO", "inline": false},
      {"name": "ISP/Organisation", "value": "$ISP", "inline": false}
    ]
  }]
}
EOF

# Sende die Anfrage an den Discord Webhook
curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$WEBHOOK_URL"
