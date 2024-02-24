#!/bin/bash

ZONE_ID=$1
HOSTNAME=$2
API=$3

# Cloudflare API endpoint
ENDPOINT="https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=CNAME&name=${HOSTNAME}"

# Make a request to the Cloudflare API to check for the DNS record
response=$(curl -s -X GET "${ENDPOINT}" -H "Authorization: Bearer ${API}" -H "Content-Type: application/json")

# Check if the record exists in the response
if echo "$response" | grep -q "\"count\":1"; then
  echo '{"exists":"true"}'
else
  echo '{"exists":"false"}'
fi

