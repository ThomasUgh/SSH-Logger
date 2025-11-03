#!/bin/bash

WEBHOOK_URL="https://discord.com/api/webhooks/<ID>/<TOKEN>"

# Server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# User IP
USER_IP=$(echo "${SSH_CONNECTION:-}" | awk '{print $1}')

# User Name
USER_NAME=$(whoami)

# Login Time
LOGIN_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Geolocation & ISP (1 Request)
IPINFO_JSON=$(curl -fsS "https://ipinfo.io/${USER_IP}/json" 2>/dev/null || true)
if command -v jq >/dev/null 2>&1; then
  GEO_INFO=$(echo "$IPINFO_JSON" | jq -r '[.city,.region,.country]|map(select(.!=null))|join(", ")')
  ISP=$(echo "$IPINFO_JSON" | jq -r '.org // "Not Available"')
else
  CITY=$(echo "$IPINFO_JSON"    | sed -n 's/.*"city":"\([^"]*\)".*/\1/p')
  REGION=$(echo "$IPINFO_JSON"  | sed -n 's/.*"region":"\([^"]*\)".*/\1/p')
  COUNTRY=$(echo "$IPINFO_JSON" | sed -n 's/.*"country":"\([^"]*\)".*/\1/p')
  ISP=$(echo "$IPINFO_JSON"     | sed -n 's/.*"org":"\([^"]*\)".*/\1/p')
  GEO_INFO="$(printf "%s, %s, %s" "$CITY" "$REGION" "$COUNTRY" | sed 's/, \{1,\}/, /g;s/^, //;s/, $//')"
  [ -z "$GEO_INFO" ] && GEO_INFO="Not Available"
  [ -z "$ISP" ] && ISP="Not Available"
fi

if [ -r /etc/os-release ]; then
  SERVER_OS=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
else
  SERVER_OS=$(uname -srm)
fi

# User-Agent/Prozesszeile
USER_AGENT=$(ps -o args= -p $$ | tr -d '\0')

PAYLOAD=$(cat <<EOF
{
  "embeds": [{
    "title": "🔐 NEW LOGIN REGISTERED",
    "color": 16711680,
    "fields": [
      {"name": "Server IP", "value": "$SERVER_IP", "inline": true},
      {"name": "User IP", "value": "$USER_IP", "inline": true},
      {"name": "User", "value": "$USER_NAME", "inline": true},
      {"name": "Server OS", "value": "$SERVER_OS", "inline": false},
      {"name": "Login Time", "value": "$LOGIN_TIME", "inline": false},
      {"name": "Geolocation", "value": "$GEO_INFO", "inline": false},
      {"name": "ISP/Organisation", "value": "$ISP", "inline": false},
    ]
  }]
}
EOF
)

# Senden
curl -fsS -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$WEBHOOK_URL" >/dev/null || true
