#!/bin/bash

#Check IP type: mobile, hosting, proxy, residential using ip-api.com API

# Use xargs with parallelism to speed up IP processing, with curl error handling.
xargs -P 5 -I {} bash -c '
  ip={}
  result=$(curl -s --fail "http://ip-api.com/json/$ip?fields=status,message,country,regionName,city,isp,org,as,mobile,proxy,hosting,query")

  if [ $? -ne 0 ] || [ -z "$result" ]; then
    echo "$ip - Error: Failed to fetch data"
    exit 1
  fi

  isp=$(echo $result | jq -r ".isp")
  org=$(echo $result | jq -r ".org")
  mobile=$(echo $result | jq -r ".mobile")
  proxy=$(echo $result | jq -r ".proxy")
  hosting=$(echo $result | jq -r ".hosting")

  # Classification logic using case for efficiency
  combined="$org $isp"
  case "$combined" in
    *AWS*|*Google*Cloud*|*OVH*|*Hetzner*|*DigitalOcean*|*Linode*|*Vultr*|*Choopa*)
      type="Hosting"
      ;;
    *VPN*|*ExpressVPN*|*NordVPN*|*Private*Internet*Access*)
      type="VPN/Proxy"
      ;;
    *)
      if [ "$mobile" = "true" ]; then
        type="Mobile"
      elif [ "$proxy" = "true" ]; then
        type="Proxy"
      elif [ "$hosting" = "true" ]; then
        type="Hosting"
      else
        type="Residential/Other"
      fi
      ;;
  esac

  echo "$ip - ISP: $isp, ORG: $org, MOB: $mobile, PROXY: $proxy, HOSTING: $hosting, TYPE: $type"
' < iplist.txt

# Removed -n 1 to avoid xargs conflict with -I {}
# Adjust -P based on API rate limits or system capabilities.
