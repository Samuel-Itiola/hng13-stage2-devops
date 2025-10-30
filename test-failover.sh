#!/bin/bash

echo "=== Blue/Green Deployment Test ==="
echo

echo "1. Testing initial state (should be blue):"
curl -s localhost:8080/version | jq .
echo

echo "2. Triggering chaos on blue service:"
curl -X POST localhost:8081/chaos/start
echo

echo "3. Testing failover (should now be green):"
curl -s localhost:8080/version | jq .
echo

echo "4. Stopping chaos on blue service:"
curl -X POST localhost:8081/chaos/stop
echo

echo "5. Testing recovery (should be back to blue):"
curl -s localhost:8080/version | jq .
echo

echo "6. Checking headers:"
curl -I localhost:8080/version 2>/dev/null | grep -E "(X-App-Pool|X-Release-Id)"
echo

echo "=== Test Complete ==="