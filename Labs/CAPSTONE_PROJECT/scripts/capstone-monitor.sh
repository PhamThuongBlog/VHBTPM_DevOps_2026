#!/bin/bash
# ============================================================
# capstone-monitor.sh — Health Monitor cho Student Manager
# ============================================================
INTERVAL=${1:-5}
echo "🔍 Monitoring Student Manager API every ${INTERVAL}s..."
echo "Press Ctrl+C to stop"
echo ""

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    STATUS=$(curl -s http://localhost:8080/api/students/health 2>/dev/null)
    if [ $? -eq 0 ]; then
        S=$(echo "$STATUS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','UNKNOWN'))" 2>/dev/null || echo "PARSE_ERROR")
        echo "[$TIMESTAMP] ✅ $S | $(echo "$STATUS" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"v{d['version']}\")" 2>/dev/null || echo "")"
    else
        echo "[$TIMESTAMP] ❌ DOWN — Cannot connect to localhost:8080"
    fi
    sleep "$INTERVAL"
done
