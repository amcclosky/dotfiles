#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jump Desktop: Connect
# @raycast.mode silent
# @raycast.packageName Jump Desktop
# @raycast.icon 🖥️

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "host (name or IP)" }
# @raycast.argument2 { "type": "dropdown", "placeholder": "protocol", "optional": true, "data": [{ "title": "VNC", "value": "vnc" }, { "title": "RDP", "value": "rdp" }, { "title": "Fluid", "value": "fluid" }] }
# @raycast.argument3 { "type": "text", "placeholder": "username", "optional": true }
# @raycast.argument4 { "type": "text", "placeholder": "port", "optional": true }

# Docs: https://support.jumpdesktop.com/hc/en-us/articles/216423723
# No password argument on purpose: it would end up in the process list and Raycast history.
# Jump prompts for it (or uses the saved one for known hosts).

urlencode() {
  local s="$1" i c out=""
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      *) out+=$(printf '%%%02X' "'$c") ;;
    esac
  done
  printf '%s' "$out"
}

host="$1"
protocol="${2:-vnc}"
username="$3"
port="$4"

url="jump://?host=$(urlencode "$host")&protocol=$protocol"
[ -n "$username" ] && url+="&username=$(urlencode "$username")"
[ -n "$port" ] && url+="&port=$(urlencode "$port")"

if [ -n "$JUMP_DRY_RUN" ]; then
  echo "$url"
  exit 0
fi

open "$url"
echo "Connecting to $host"
