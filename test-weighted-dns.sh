#!/bin/bash

# Test script for weighted DNS routing verification
# This script helps test Route53 weighted routing by using different DNS servers

DOMAIN="app.jasonfaas.xyz"
DNS_SERVERS=("8.8.8.8" "1.1.1.1" "208.67.222.222" "9.9.9.9")
NUM_REQUESTS=20

echo "=== Testing Weighted DNS Routing for $DOMAIN ==="
echo "Expected distribution: Blue (66%) / Green (33%)"
echo ""

# Function to get IP from specific DNS server
get_ip_from_dns() {
    local dns_server=$1
    dig @$dns_server +short $DOMAIN | head -1
}

# Function to test HTTP response
test_http_response() {
    local ip=$1
    curl -s --connect-timeout 5 --max-time 10 http://$ip | head -1
}

# Test 1: Check DNS resolution from different servers
echo "=== DNS Resolution Test ==="
declare -A dns_results
for dns_server in "${DNS_SERVERS[@]}"; do
    echo "Testing with DNS server: $dns_server"
    ip=$(get_ip_from_dns $dns_server)
    echo "  Resolved IP: $ip"
    dns_results[$dns_server]=$ip
    echo ""
done

# Test 2: Multiple requests with different DNS servers
echo "=== HTTP Response Test ==="
declare -A response_counts
response_counts["blue"]=0
response_counts["green"]=0
response_counts["unknown"]=0

for i in $(seq 1 $NUM_REQUESTS); do
    # Rotate through DNS servers
    dns_server=${DNS_SERVERS[$((i % ${#DNS_SERVERS[@]}))]}
    
    echo -n "Request $i (DNS: $dns_server): "
    
    # Get IP from DNS server
    ip=$(get_ip_from_dns $dns_server)
    
    if [ -n "$ip" ]; then
        # Test HTTP response
        response=$(test_http_response $ip)
        
        # Try to determine which cluster this is based on response
        if echo "$response" | grep -q "1.33\|blue\|Blue"; then
            echo "BLUE cluster (IP: $ip)"
            ((response_counts["blue"]++))
        elif echo "$response" | grep -q "1.32\|green\|Green"; then
            echo "GREEN cluster (IP: $ip)"
            ((response_counts["green"]++))
        else
            echo "UNKNOWN cluster (IP: $ip) - Response: $response"
            ((response_counts["unknown"]++))
        fi
    else
        echo "Failed to resolve IP"
        ((response_counts["unknown"]++))
    fi
    
    # Small delay to avoid overwhelming the servers
    sleep 0.5
done

# Test 3: Summary
echo ""
echo "=== Results Summary ==="
total_requests=$NUM_REQUESTS
echo "Total requests: $total_requests"
echo "Blue cluster responses: ${response_counts[blue]} ($(( response_counts[blue] * 100 / total_requests ))%)"
echo "Green cluster responses: ${response_counts[green]} ($(( response_counts[green] * 100 / total_requests ))%)"
echo "Unknown responses: ${response_counts[unknown]} ($(( response_counts[unknown] * 100 / total_requests ))%)"

# Test 4: Direct IP testing
echo ""
echo "=== Direct IP Testing ==="
unique_ips=$(printf '%s\n' "${dns_results[@]}" | sort -u)
for ip in $unique_ips; do
    echo "Testing IP: $ip"
    response=$(test_http_response $ip)
    echo "  Response: $response"
    echo ""
done

echo "=== Tips ==="
echo "1. If you're only seeing one cluster, try:"
echo "   - Wait for DNS TTL to expire (check with: dig $DOMAIN)"
echo "   - Use different DNS servers as shown above"
echo "   - Test from different networks/locations"
echo ""
echo "2. Check Route53 records directly:"
echo "   dig ns jasonfaas.xyz  # Get Route53 nameservers"
echo "   dig @[nameserver] $DOMAIN  # Query Route53 directly"
