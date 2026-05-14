---
name: todesk-remote-fix
description: "Diagnose and fix ToDesk remote connection failures on macOS. Use when ToDesk can't be connected to remotely, shows offline, or was working before but suddenly stopped."
version: 2.0.0
category: productivity
---

# ToDesk Remote Connection Fix

## Quick Diagnostic Flow (run in order)

```bash
# Step 1: SYSTEM-LEVEL connectivity test (MUST come first)
curl -s --max-time 5 https://httpbin.org/ip > /dev/null && echo "Net:OK" || echo "Net:DEAD"

# Step 2: If Net:DEAD, check for rogue VPN routes
netstat -rn -f inet | grep -E 'utun|128\.0/1|0/1'

# Step 3: If Net:OK but ToDesk offline, check ToDesk outbound connections
lsof -iTCP -P -n 2>/dev/null | grep -i todesk | grep -v 127.0.0.1
```

## Root Cause A: VPN Route Residue (MOST COMMON)

A VPN/proxy app was quit but left its routing rules active. Traffic is sent to a dead virtual interface and black-holed.

### Symptom
- `curl https://httpbin.org/ip` fails
- `nslookup` resolves DNS fine (DNS bypasses the VPN route)
- `netstat -rn` shows `128.0/1` (or `0/1`) routing through a `utun*` interface with a `198.19.x.x` or `198.18.x.x` address
- Multiple `utun*` interfaces still UP in `ifconfig`

### Fix

```bash
# Remove the rogue split route
sudo route delete -net 128.0.0.0/1    # or 0.0.0.0/1, whichever is present
```

After removal, verify:
```bash
curl -s --max-time 5 https://httpbin.org/ip
```

Then restart ToDesk (or wait — the service will auto-reconnect):
```bash
sudo killall -9 ToDesk_Service
```

### Prevention

Add to sudoers so the agent can fix without user intervention:
```
bhw	ALL=(ALL) NOPASSWD: /sbin/route delete -net 128.0.0.0/1, /sbin/route delete -net 0.0.0.0/1
```

## Root Cause B: Service Network Stack Death

`ToDesk_Service` runs for 5+ days and its network stack silently dies. Process stays alive but has zero outbound TCP connections.

### Symptom
- `curl https://httpbin.org/ip` WORKS (system network is fine)
- `lsof -iTCP | grep todesk | grep -v 127.0.0.1` returns NOTHING
- `ps aux | grep ToDesk_Service` shows multi-day uptime

### Fix

```bash
sudo killall -9 ToDesk_Service
# KeepAlive=true in LaunchDaemon auto-restarts it in 3-5 seconds
```

### Prevention

Periodic restart via cron (every 3 days) or after long uptime. Add to sudoers:
```
bhw	ALL=(ALL) NOPASSWD: /usr/bin/killall -9 ToDesk_Service
```

## Full System Diagnosis (When Neither Quick Fix Works)

Follow `macos-app-troubleshooting` Phase 1-4:

```bash
# Phase 1: Process health
ps aux | grep -i todesk | grep -v grep

# Phase 2: TCP connections
lsof -iTCP -P -n 2>/dev/null | grep -i todesk

# Phase 3: System log (last 30 min)
log show --predicate 'process CONTAINS "ToDesk"' --last 30m --style compact 2>/dev/null | grep -iE 'error|fail|disconnect'

# Phase 4: Routing & VPN
netstat -rn -f inet | head -20
ifconfig | grep -A2 'utun\|ppp'
```

## Architecture

| Process | Owner | Role |
|---------|-------|------|
| `ToDesk` | user (GUI) | Main window UI |
| `ToDesk_Service` | root | **Networking, screen capture, remote access** |
| `ToDesk_Session` | user | Local video session relay |
| `ToDesk_Session_Proxy` | user | Proxy relay |

Restarting the GUI does NOT fix a dead Service or bad routes.

## What Does NOT Work

| Approach | Why |
|----------|-----|
| Restarting GUI only | Service processes are separate from GUI |
| `launchctl kickstart/bootout` | Requires root, operation not permitted for user |
| `kill -9` on Service PID as user | Service is root-owned |
| AppleScript UI automation | Accessibility permissions block System Events |
| CoreGraphics blind clicking | Can't see UI to locate buttons |
| `security execute-with-privileges` | Requires GUI password dialog |
| DNS flush / WiFi toggle | Doesn't fix routing or process issues |
| Modifying ToDesk config.ini | Service doesn't hot-reload config |

## Recommended Sudoers Setup

```
# Full ToDesk auto-fix permissions
bhw	ALL=(ALL) NOPASSWD: /usr/bin/killall -9 ToDesk_Service
bhw	ALL=(ALL) NOPASSWD: /sbin/route delete -net 128.0.0.0/1
bhw	ALL=(ALL) NOPASSWD: /sbin/route delete -net 0.0.0.0/1
```

## Verification

- [ ] `curl https://httpbin.org/ip` succeeds (system network)
- [ ] `lsof -iTCP \| grep todesk \| grep -v 127.0.0.1` shows outbound connections
- [ ] Remote client can connect

## Related

- `macos-app-troubleshooting` — Phase 4 covers VPN route residue detection
- `references/session-2026-05-14.md` — Full session transcript of the initial discovery
