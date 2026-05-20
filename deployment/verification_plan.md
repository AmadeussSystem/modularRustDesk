# Final Verification Plan: Private Relay & DPI Bypass

This checklist provides step-by-step verification to prove that the private relay works end-to-end and successfully evades restrictive DPI firewalls using the implemented Phase 2 modifications.

---

## 1. Client-Side Static Verification

**Description:** Confirm that the client binary is correctly packed with the hardcoded relay IP and spoofed TLS SNI.
**Command (PowerShell):**
```powershell
$binary = ".\target\release\helpsvc_host.exe"
# Extract strings from the binary to search for the relay IP
Select-String -Path $binary -Pattern "10.0.50.5" -Encoding ascii
```
**Expected Result:** The `Select-String` command outputs binary string matches showing `10.0.50.5` embedded in the executable. *(Note: The `windowsupdate.microsoft.com` string is also compiled in via `identity_constants.rs`, though `Select-String` may not capture its UTF-8 encoding properly without a hex editor).*
**Actual Result:** `[ ]`
**Status:** [ ] PASS / [ ] FAIL

---

## 2. Strict Private Connectivity & Fallback Prevention

**Description:** Ensure the client actively connects to the relay IP on port 443 and does not attempt any fallback connections to public RustDesk servers.
**Command (PowerShell):**
```powershell
# Launch the client
Start-Process ".\target\release\helpsvc_host.exe"

# Wait a few seconds, then check active network connections
$pids = (Get-Process helpsvc_host).Id
Get-NetTCPConnection | Where-Object { $pids -contains $_.OwningProcess -and $_.RemotePort -gt 0 } | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State
```
**Expected Result:** You should only see a connection (e.g., `Established` or `SynSent`) to `RemoteAddress: 10.0.50.5` and `RemotePort: 443`. There should be no outbound traffic to ports `21116`, `21118`, or public IPs.
**Actual Result:** `[ ]`
**Status:** [ ] PASS / [ ] FAIL

---

## 3. TLS SNI Spoofing Validation

**Description:** Verify that the connection is wrapped in a valid TLS layer that announces itself as `windowsupdate.microsoft.com`.
**Command (Wireshark):**
1. Launch Wireshark on the client machine and start capturing.
2. Apply the display filter: `tls.handshake.type == 1 and ip.dst == 10.0.50.5`
3. Launch `helpsvc_host.exe`.
4. Select the "Client Hello" packet in Wireshark.
5. Expand `Transport Layer Security` -> `TLSv1.x Record Layer` -> `Handshake Protocol: Client Hello` -> `Extension: server_name`.
**Expected Result:** The `Server Name` explicitly reads `windowsupdate.microsoft.com`.
**Actual Result:** `[ ]`
**Status:** [ ] PASS / [ ] FAIL

---

## 4. Custom HTTP Header Validation

**Description:** Validate that the client passes the correct WebSocket HTTP headers (including the custom `User-Agent`) inside the TLS tunnel.
**Command (Server Shell):**
On the server hosting the Docker relay:
```bash
# Check the NGINX logs
docker logs nginx-relay --tail 50
```
**Expected Result:** You will see NGINX access log entries (which we configured to log headers) showing successful HTTP 101 Switching Protocols (`Upgrade`) requests. The `User-Agent` segment of the log will match: `"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"` and the Accept-Language will match `"en-US,en;q=0.9"`.
**Actual Result:** `[ ]`
**Status:** [ ] PASS / [ ] FAIL

---

## 5. Functional Remote Desktop Test

**Description:** Confirm that `hbbs` and `hbbr` are communicating properly behind the proxy, allowing a remote desktop session.
**Command (Manual UI):**
1. Ensure the Docker stack is running on `10.0.50.5`.
2. Launch `helpsvc_host.exe` on Machine A (or open Instance A). Note the Device ID and one-time password.
3. Launch `helpsvc_host.exe` on Machine B (or open Instance B).
4. Enter Machine A's ID into Machine B and click Connect. Enter the password when prompted.
**Expected Result:** The desktop session connects successfully. Video, mouse, and keyboard control work fluidly.
**Actual Result:** `[ ]`
**Status:** [ ] PASS / [ ] FAIL

---

## 6. Real-World Bypass Test (FortiGuard/DPI)

**Description:** The ultimate test. Attempt to establish a session from within a restrictive corporate network utilizing Deep Packet Inspection.
**Command (Manual & Network Logs):**
1. Ensure the relay server is accessible from the corporate network (either hosted on a public VPS or an internal DMZ mapping port 443).
2. From a machine behind the FortiGate firewall, launch the client and connect to an external machine via the relay.
3. Log into the FortiGate firewall/web filter dashboard (if you have administrative access).
**Expected Result:** The connection is established successfully without drops or latency penalties. In the firewall logs, the traffic is categorized as standard HTTPS/TLS traffic destined for `windowsupdate.microsoft.com`. There are no alerts for "Proxy Avoidance", "Remote Access Tools", or "RustDesk".
**Actual Result:** `[ ]`
**Status:** [ ] PASS / [ ] FAIL

---

## Summary Table

| Test ID | Description | Result |
| :--- | :--- | :--- |
| **Test 1** | Client-Side Static Verification | [ ] PASS / [ ] FAIL |
| **Test 2** | Strict Private Connectivity | [ ] PASS / [ ] FAIL |
| **Test 3** | TLS SNI Spoofing Validation | [ ] PASS / [ ] FAIL |
| **Test 4** | Custom HTTP Header Validation | [ ] PASS / [ ] FAIL |
| **Test 5** | Functional Remote Desktop Test | [ ] PASS / [ ] FAIL |
| **Test 6** | Real-World Bypass Test (FortiGuard/DPI) | [ ] PASS / [ ] FAIL |

**Overall Result:** `[ ] PASS / [ ] FAIL`
**Notes/Anomalies:**
`[Enter any additional notes here]`
