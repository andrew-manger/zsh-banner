#!/bin/zsh
clear

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BOLD_GREEN='\033[1;32m'
BOLD_BLUE='\033[1;35m'
BOLD_RED='\033[1;31m'

# ASCII Art based on the hostname (requires figlet installation)
hostname_art=$(echo "Q-amanger" | figlet)

# OS Details
os_name=$(uname)
os_version=$(sw_vers -productVersion)

# System-specific details
# Time and Date
datetime=$(date "+%H:%M - %a %m/%d/%y")

# WAN
## Fetch WAN IP and geolocation using ipinfo.io
wan_info=$(curl -s https://ipinfo.io)

## Extract data using jq (requires jq installation)
wan_ip=$(echo $wan_info | jq -r '.ip')
wan_city=$(echo $wan_info | jq -r '.city')
wan_region=$(echo $wan_info | jq -r '.region')
wan_country=$(echo $wan_info | jq -r '.country')

wan_loc="$wan_city, $wan_region $wan_country"

# VPN Connection (This part of the script may not work for you. I customized it based on my network interface devices to determine if and which VPN service I'm connected to)
## Function to check VPN connections
function check_vpn {
    local qualtrics_count=$(netstat -nr | grep -c 'utun8')
    local wireguard_count=$(netstat -nr | grep -c 'utun9')

    if [[ "$qualtrics_count" -ne 0 ]]; then
        echo ${BOLD_GREEN}"Connected${BOLD_BLUE} (Qualtrics)"${NC}
    elif [[ "$wireguard_count" -ne 0 ]]; then
        echo ${BOLD_GREEN}"Connected${BOLD_RED} (Wireguard)"${NC}
    else
        echo "Not Connected"
    fi
}

## Get the VPN status using the check_vpn function
vpn_status=$(check_vpn)

# Uptime
function format_uptime {
    local up=$(uptime)
    local days=$(echo "$up" | grep -o '[0-9]\+ day' | awk 'END {print $1}')
    local hrs=$(echo "$up" | grep -o '[0-9]\+:[0-9]\+' | awk 'END {print $1}' | cut -d: -f1)
    local mins=$(echo "$up" | grep -o '[0-9]\+:[0-9]\+' | awk 'END {print $1}' | cut -d: -f1)

    local formatted_uptime=""
    
    if [[ -n $days ]]; then
        formatted_uptime+="$days days, "
    fi

    formatted_uptime+="$hrs hrs, $mins mins"
    echo $formatted_uptime
}
uptime=$(format_uptime)

# IP Address Finding
lan_ip=$(ipconfig getifaddr en0) # Assumes en0 is your primary interface, adjust if necessary

# Memory and CPU Usage Details
# Using `top` command to fetch CPU usage (simplified)
cpu_usage=$(top -l 1 | awk '/CPU usage/ {print $3, $5, $7}')

# Disk usage from root
disk_usage=$(df -H / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

# Print banner
echo -e "${GREEN}─────────────────────────────────────────────────────${NC}"
echo " macOS $os_version : $datetime"
echo -e "${GREEN}─────────────────────────────────────────────────────${NC}"
echo "$hostname_art"
#echo -e "${GREEN} -${NC} OS ${GREEN}:${NC} $os_name $os_version"
echo -e "${GREEN} -${NC} Uptime ${GREEN}:${NC} $uptime"
echo -e "${GREEN} -${NC} LAN IP ${GREEN}:${NC} $lan_ip"
echo -e "${GREEN} -${NC} WAN IP ${GREEN}:${NC} $wan_ip ($wan_loc)"
echo -e "${GREEN} -${NC} VPN Status ${GREEN}:${NC} $vpn_status"

echo -e "${GREEN}─────────────────────────────────────────────────────${NC}"
