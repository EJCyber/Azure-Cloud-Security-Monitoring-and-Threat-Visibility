# Azure Cloud Security Monitoring and Threat Visibility

### Deploying Microsoft Sentinel as a production-minded SIEM across an existing cloud-managed endpoint environment — with custom detection engineering, incident investigation, automated response, and operational endpoint health reporting.

> This project is the third and final entry in a three-part portfolio series focused on identity governance, endpoint management, and security operations in a Microsoft cloud environment.

---

> **Quick read:** See [Key Outcomes](#key-outcomes) for a summary, or jump to [Detection Engineering](#phase-3--detection-engineering) to see the custom KQL rule and layered detection design.

---

## Overview

This project is the third and final entry in a three-project Microsoft cloud portfolio series. Projects 1 and 2 established the identity governance and endpoint management foundations for a cloud-first organization. Project 3 builds the security monitoring and visibility layer on top of that foundation.

The project deploys Microsoft Sentinel connected to Microsoft Entra ID and Microsoft Defender for Endpoint, engineers a layered detection ruleset including a custom KQL analytics rule, validates real incident generation and investigation, automates alert response through a Logic App playbook, and delivers operational endpoint health reporting via Microsoft Graph PowerShell.

The environment is not a standalone lab. It extends the same Azure tenant, Entra ID identity structure, and Intune-managed endpoints built across the first two projects — making this a continuous, production-minded infrastructure story rather than a collection of disconnected exercises.

---

## Key Outcomes

- Deployed Microsoft Sentinel on a Log Analytics Workspace within an existing production-framed Azure environment
- Configured Entra ID and Microsoft Defender XDR data connectors with targeted log table selection
- Engineered five analytics detection rules including one custom KQL rule targeting non-US geographic sign-in activity
- Generated and investigated real Sentinel incidents triggered by simulated brute force activity against tenant accounts
- Built and validated a Logic App playbook that automatically delivers alert notifications with full incident context on new incident creation
- Configured a Sentinel automation rule wiring the playbook to the brute force detection rule
- Deployed a Microsoft Entra ID Sign-in logs workbook providing sign-in trend analysis, failure breakdown, and geographic visibility
- Built `Get-CloudEndpointInventory.ps1` via Microsoft Graph PowerShell delivering automated device compliance, OS version, and stale device reporting across all managed endpoints
- Documented real-world findings including analytics rule scheduler behavior, portal migration friction, and data connector diagnostic setting propagation

---

## Business Scenario

The organization from Projects 1 and 2 has established its identity governance baseline and deployed managed, compliant endpoints across its workforce. Leadership now requires operational visibility and security detection capability. The questions they need answered are:

- Are there unauthorized or suspicious sign-in attempts against our tenant accounts?
- Are our managed devices compliant, current, and actively checking in?
- If a security event occurs, will we know about it — and do we have a documented response process?

This project addresses all three requirements through a layered monitoring architecture covering identity signals, endpoint health, detection engineering, and automated response.

---

## Project Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Microsoft Entra ID Tenant                    │
│         mannylabsacctgmail.onmicrosoft.com                      │
│                                                                  │
│  Sign-in Logs ──────────────────────────────────────────────┐   │
│  Audit Logs  ───────────────────────────────────────────────┤   │
│  Non-Interactive Sign-in Logs ──────────────────────────────┤   │
└─────────────────────────────────────────────────────────────┼───┘
                                                              │
┌─────────────────────────────────────────────────────────────┼───┐
│           Microsoft Defender for Endpoint                    │   │
│                                                              │   │
│  vm-p2-winclient (casey.quinn)  ─────── DeviceInfo ─────────┤   │
│  vm-p2-winclient02 (alex.rivers) ────── DeviceLogonEvents ──┤   │
│                                         AlertInfo ──────────┤   │
│                                         AlertEvidence ──────┤   │
└─────────────────────────────────────────────────────────────┼───┘
                                                              │
                                    ┌─────────────────────────▼──┐
                                    │   Log Analytics Workspace   │
                                    │  law-p3-sentinel-westus2    │
                                    │     West US 2               │
                                    └─────────────────────────┬──┘
                                                              │
                                    ┌─────────────────────────▼──┐
                                    │    Microsoft Sentinel       │
                                    │                             │
                                    │  Analytics Rules (5)        │
                                    │  Workbooks                  │
                                    │  Incidents Queue            │
                                    │  Automation Rules           │
                                    └─────────────────────────┬──┘
                                                              │
                              ┌───────────────────────────────▼──┐
                              │   Azure Logic App Playbook        │
                              │  la-p3-sentinel-brute-force-      │
                              │  response                         │
                              │                                   │
                              │  Trigger: Incident created        │
                              │  Action: Send email notification  │
                              │  Recipient: Admin (Gmail)         │
                              └──────────────────────────────────┘
```

**Resource Group:** rg-p2-infra-endpoint-westus2  
**Region:** West US 2  
**Licensing:** Microsoft 365 Business Premium + Azure Subscription (Sentinel free trial)

---

## Phase 0 — Pre-Production Validation

Before deploying any new resources, the existing Project 2 environment was validated to confirm it remained in a known good state. This mirrors how production change windows are managed — verifying the baseline before introducing new layers.

**Validated:**
- Resource group rg-p2-infra-endpoint-westus2 intact with all 10 resources (VMs, NICs, disks, NSG, VNet)
- vm-p2-winclient01: Running, Azure VM Agent Ready
- vm-p2-winclient02: Running, Azure VM Agent Ready (agent required restart to recover — documented as finding)
- Both devices enrolled in Intune as Corporate, managed, and Compliant
- Primary user assignments intact: casey.quinn and alex.rivers
- M365 Business Premium licensing active

| Device | Compliance | OS Version | Last Check-in | Primary User |
|---|---|---|---|---|
| vm-p2-winclient | Compliant | 10.0.26200.4946 | 04/03/2026 | casey.quinn |
| vm-p2-winclient02 | Compliant | 10.0.26200.8037 | 04/03/2026 | alex.rivers |

---

## Phase 1 — Log Analytics Workspace and Sentinel Deployment

**Log Analytics Workspace**

A dedicated Log Analytics Workspace was deployed as the data backend for all Sentinel ingestion. All log sources, analytics rule evaluations, and workbook queries run against this workspace.

- **Name:** law-p3-sentinel-westus2
- **Resource Group:** rg-p2-infra-endpoint-westus2
- **Region:** West US 2
- **Retention:** 31 days (default)
- **Cost:** Microsoft Sentinel free trial activated — up to 10 GB/day included at no cost

**Microsoft Sentinel**

Microsoft Sentinel was enabled directly on top of the Log Analytics Workspace through the Azure portal. Sentinel operates as an analysis and detection layer over the workspace rather than as a standalone resource.

Upon activation the free trial was confirmed active through May 11, 2026, covering both Sentinel and Log Analytics ingestion costs for the duration of the project.

---

## Phase 2 — Data Connector Configuration

Data connectors establish the pipeline between signal sources and the Sentinel workspace. Two solutions were installed via Content Hub and configured with targeted log table selection to balance visibility against ingestion cost.

### Microsoft Entra ID Connector

**Content Hub Solution:** Microsoft Entra ID (Featured, v3.3.9)  
**Included:** 1 Data Connector, 3 Workbooks, 73 Analytic Rule Templates, 11 Playbooks  
**Status:** Connected

**Log tables enabled:**
- Sign-in Logs — all interactive authentication events including success, failure, and MFA outcomes
- Audit Logs — identity management activity including account changes, group modifications, and role assignments
- Non-Interactive User Sign-in Logs — background and service authentication events

Sign-in Logs require Entra ID P1 or P2 licensing. Microsoft 365 Business Premium includes Entra ID P1, confirming compatibility.

### Microsoft Defender XDR Connector

**Content Hub Solution:** Microsoft Defender XDR (Featured, v3.0.13)  
**Included:** 1 Data Connector, 3 Workbooks, 40 Analytic Rules, 326 Hunting Queries  
**Status:** Connected

**Log tables enabled:**

| Table | Description |
|---|---|
| DeviceInfo | Machine inventory including OS information |
| DeviceNetworkInfo | Network properties of managed machines |
| DeviceLogonEvents | Sign-ins and authentication events on endpoints |
| DeviceProcessEvents | Process creation events for behavioral detection |
| AlertInfo | Alert metadata from all Defender products |
| AlertEvidence | Files, IPs, users, and devices associated with alerts |

**Note:** The Incidents and Alerts configuration section displayed a warning indicating the workspace was onboarded to the Unified Security Operations Platform. This is a known Microsoft mid-migration behavior as Sentinel transitions toward the unified Defender portal at security.microsoft.com. Event table streaming was confirmed functional regardless of this warning.

---

## Phase 3 — Detection Engineering

Five analytics rules were enabled and configured to detect realistic threat scenarios relevant to the environment. Rules were selected based on data sources available, expected signal volume, and alignment with the business scenario.

### Detection Rule Summary

| Rule | Severity | Type | MITRE Technique | Source |
|---|---|---|---|---|
| Attempts to sign in to disabled accounts | Medium | Template | T1078 — Valid Accounts | Entra ID |
| Anomalous sign-in location by user account | Medium | Template | T1078 — Valid Accounts | Entra ID |
| Password spray attack against Microsoft Entra ID | Medium | Template | T1110 — Brute Force | Entra ID |
| Brute force attack against Azure Portal | Medium | Template | T1110 — Brute Force | Entra ID |
| Sign-In from Non-US Location Detected | High | Custom KQL | T1078 — Valid Accounts | Entra ID |

All rules are configured with 1-hour evaluation frequency and 1-hour lookback window. Incident creation is enabled on all rules.

### Custom KQL Rule — Sign-In from Non-US Location Detected

A custom analytics rule was written from scratch to enforce the organization's geographic access baseline. All 75 users in this organization are US-based. Any successful authentication originating from outside the United States is treated as suspicious and warrants immediate investigation.

```kql
SigninLogs
| where TimeGenerated > ago(1h)
| where ResultType == 0
| extend Country = tostring(LocationDetails.countryOrRegion)
| where isnotempty(Country)
| where Country != "US"
| project
    TimeGenerated,
    UserPrincipalName,
    Country,
    City = tostring(LocationDetails.city),
    State = tostring(LocationDetails.state),
    IPAddress,
    AppDisplayName,
    DeviceDetail = tostring(DeviceDetail.operatingSystem),
    ConditionalAccessStatus
```

**Rule configuration:**
- Severity: High
- Event grouping: Trigger an alert for each event (individual visibility per sign-in)
- Alert grouping: Enabled — group by matching entities within 1 hour window
- Entity mapping: Account (UPN), IP Address, CloudApplication

### Layered Geolocation Detection Design

A single geography-based rule is insufficient for a real environment. Blocking non-US sign-ins addresses external threats but does not catch suspicious activity originating from within the country — including impossible travel scenarios, VPN abuse, or legitimate-appearing sign-ins from unexpected US locations.

The detection strategy uses two complementary layers:

1. **Sign-In from Non-US Location Detected** — flags any successful authentication originating outside the United States. Catches foreign-origin access regardless of account state.

2. **Anomalous sign-in location by user account** — uses time-series anomaly detection via `series_decompose_anomalies` to establish a per-user, per-application baseline of normal sign-in locations and flags statistically significant deviations. This catches US-to-US suspicious patterns — a user suddenly signing in from a different state or region — without requiring geographic knowledge of where employees are located.

Together these rules create overlapping coverage that neither rule can provide independently.

### Templates Evaluated but Not Enabled

Two additional templates were evaluated during this phase:

- **Successful logon from IP and failure from a different IP** — requires User and Entity Behavior Analytics (UEBA) tables (IdentityInfo, BehaviorAnalytics) which were not configured in this project scope
- **MFA Rejected by User** — same UEBA table dependency

Both were excluded as they would fail validation without UEBA enablement. UEBA configuration is noted as a future enhancement.

---

## Phase 4 — Incident Investigation

### Simulated Brute Force Attack

To generate realistic incident data for investigation, a controlled brute force simulation was executed against tenant account casey.quinn@mannylabsacctgmail.onmicrosoft.com from a single external IP address.

**Attack sequence:**
- Multiple failed authentication attempts with ResultType 50126 (invalid credentials)
- Account lockout triggered with ResultType 50053 (account locked — too many failures)
- All attempts originated from IP 142.154.214.146
- All attempts targeted Azure Portal as the application

**KQL validation query confirming event capture:**

```kql
SigninLogs
| where TimeGenerated > ago(4h)
| where AppDisplayName has "Azure Portal"
| where ResultType !in ("0", "50140")
| summarize
    FailureCount = count(),
    StartTime = min(TimeGenerated),
    EndTime = max(TimeGenerated),
    IPAddresses = make_set(IPAddress)
    by UserPrincipalName, IPAddress
| where FailureCount >= 5
```

### Incident Triage

The **Brute force attack against Azure Portal** analytics rule generated Incident #2 upon its evaluation cycle. Triage findings:

| Field | Value |
|---|---|
| Incident Title | Brute force attack against Azure Portal |
| Severity | Medium |
| Status | New |
| MITRE Tactic | Credential Access — T1110 Brute Force |
| Detection Source | Microsoft Sentinel |
| Creation Time | 4/14/2026 2:08 PM |
| Entities | IP: 142.154.214.146 / Account: casey.quinn |

**Investigation findings:**
- Single source IP conducting all attack attempts — consistent with automated brute force tooling or scripted credential attack
- No successful authentication from the attacking IP — attack did not result in compromise
- Account lockout confirmed — Entra ID smart lockout engaged after threshold was crossed
- Account was re-enabled and verified clean after investigation

**Investigation graph** confirmed entity relationships: the incident node linked directly to the source IP address and the targeted account, providing immediate visual context for the scope of the attack.

---

## Phase 5 — Endpoint Inventory and Health Reporting

`Get-CloudEndpointInventory.ps1` extends the Graph PowerShell automation from Project 2 into a full operational inventory and health reporting tool. The script is designed to answer the sysadmin's Monday morning question: what is the current health state of every managed device in the environment, without opening the portal.

### Script Capabilities

- Connects to Microsoft Graph with scoped permissions (DeviceManagementManagedDevices.Read.All)
- Retrieves all Intune-managed devices with compliance state, OS version, last check-in time, primary user, enrollment date, manufacturer, model, and serial number
- Calculates days since last check-in with UTC-corrected timestamps
- Flags devices exceeding a configurable stale threshold (default: 14 days)
- Outputs a formatted console summary with color-coded health indicators
- Exports a timestamped CSV report for record-keeping or team distribution

### Sample Output

```
[*] Connecting to Microsoft Graph...
[+] Connected to Microsoft Graph
[*] Retrieving managed devices from Intune...
[+] Retrieved 2 managed device(s)
[*] Building inventory report...

===== ENDPOINT INVENTORY SUMMARY =====
Total Devices       : 2
Compliant           : 2
Non-Compliant       : 0
Stale (>14 days)    : 0
Current Check-In    : 2
=======================================

DeviceName         ComplianceState  DaysSinceCheckIn  StaleStatus  OSVersion
----------         ---------------  ----------------  -----------  ---------
vm-p2-winclient02  Compliant        0.10              Current      10.0.26200.8037
vm-p2-winclient    Compliant        0.10              Current      10.0.26200.4946

DeviceName         PrimaryUser
----------         -----------
vm-p2-winclient02  alex.rivers@mannylabsacctgmail.onmicrosoft.com
vm-p2-winclient    casey.quinn@mannylabsacctgmail.onmicrosoft.com

[+] Report exported to: C:\Users\Emmanuel\Desktop\CloudEndpointInventory_20260413_161211.csv
[+] Disconnected from Microsoft Graph
```

---

## Phase 6 — Security Workbook and Visualization

The **Microsoft Entra ID Sign-in logs** workbook was deployed from Content Hub and saved to the workspace as `WB-P3-SignIn-Analysis`. The workbook provides an operational dashboard for sign-in activity analysis across the tenant.

### Workbook Panels

**Sign-in Analysis — Trend over Time**
Time-series chart tracking sign-in volume per user across the 14-day window. The brute force simulation activity against casey.quinn is clearly visible as a spike deviation from the baseline, demonstrating the workbook's value as a visual detection supplement.

**Summary Metrics**
- Total sign-ins: 498
- Successful: 439
- Failures: 51
- Pending user action: 8

**Sign-ins by Location**
Geographic breakdown of authentication events. Failure counts are highlighted in orange, surfacing the 51 failure events against the US-based sign-in baseline.

**Sign-ins by Device**
Platform and browser breakdown confirming device type distribution across the managed endpoint population.

**Troubleshooting Sign-ins — Error Code Breakdown**

| Error Code | Description | Count |
|---|---|---|
| 50126 | Error validating credentials — invalid username or password | 38 |
| 50053 | Account locked — too many failed attempts | 12 |
| 50089 | Authentication failed — flow token expired | 1 |

This panel directly surfaces the brute force attack sequence — wrong password escalating to account lockout — providing visual forensic evidence within the workbook.

### Geographic Visualization Note

The Sign-ins by Location map visualization requires sign-in activity from multiple geographic locations to plot data points. As all tenant users are US-based and the environment is not exposed to the broader internet, the map panel did not populate during this project. The **Sign-In from Non-US Location Detected** analytics rule is configured to alert when such activity occurs. For reference on geographic threat visualization in practice, see the [Azure Honeypot and Threat Monitoring Lab](https://github.com/EJCyber/Home-SOC-Lab) from the supporting portfolio where inbound attack traffic from global IP ranges is plotted on a world map using Sentinel workbooks.

---

## Phase 7 — Automated Response Playbook

An Azure Logic App playbook was built and wired to Microsoft Sentinel to deliver automated incident notification when a brute force detection fires.

### Playbook Architecture

**Logic App:** la-p3-sentinel-brute-force-response  
**Plan:** Consumption (pay-per-execution)  
**Resource Group:** rg-p2-infra-endpoint-westus2  
**Region:** West US 2

**Workflow:**
1. Trigger: Microsoft Sentinel incident created
2. Action: Send an email (Office 365 Outlook V2) to manny.labs.acct@gmail.com

**Email payload (dynamic fields populated from incident schema):**
- Incident Title
- Severity
- Status
- Created Time (UTC)
- Description
- Incident URL (direct link to Sentinel investigation)

### Automation Rule

An automation rule was configured in Sentinel to wire the playbook to the detection rule:

**Rule Name:** AR-BruteForce-EmailResponse  
**Trigger:** When incident is created  
**Condition:** Analytics rule name contains "Brute force attack against Azure Portal"  
**Action:** Run playbook — la-p3-sentinel-brute-force-response  
**Expiration:** Indefinite  
**Status:** Enabled

### Validation

The automation pipeline was validated end to end. Upon incident creation the Logic App triggered successfully (run duration: 2.01 seconds) and delivered an email notification with full incident context to the administrator's inbox. The email confirmed correct dynamic field population including incident title, severity, status, timestamp, description, and direct Sentinel investigation URL.

---

## Lessons Learned

**Analytics rule scheduler behavior**
Analytics rules do not generate incidents immediately upon creation. Rules require at least one full evaluation cycle to execute, and rule run records have an additional 90-minute reporting delay in the portal. The correct validation approach is to confirm event presence in the Log Analytics workspace via direct KQL queries rather than waiting on incident generation. This prevents false conclusions about connector or rule failures during initial deployment.

**KQL rule validation and tuning**
Initial analytics rule templates that reference UEBA tables (IdentityInfo, BehaviorAnalytics) fail validation when UEBA is not enabled. Template dependencies are not always clearly surfaced in Content Hub descriptions. Testing rule logic against live workspace data before activating is essential — the Logs query interface is the right tool for this validation step.

**Microsoft Sentinel portal migration**
Microsoft is actively migrating Sentinel's primary interface from the Azure portal to the unified Defender portal at security.microsoft.com. During this project, the Sentinel Content Hub experienced intermittent rendering failures in the Azure portal due to redirect behavior from this migration. The Azure portal remains fully functional but requires fresh browser sessions and direct URL navigation in some cases. This is a temporary architectural transition state and should be noted in any deployment documentation targeting this time period.

**Defender XDR connector incidents warning**
The Microsoft Defender XDR connector displayed a warning that "Incidents and alerts configuration is disabled" due to Unified Security Operations Platform onboarding. This does not affect event table streaming. Raw log tables (DeviceInfo, DeviceLogonEvents, AlertInfo, etc.) continue to flow into the workspace regardless of the incidents configuration state.

**Azure VM Agent recovery**
vm-p2-winclient02 presented an agent status of "Not Ready" at the start of Phase 0. A VM restart resolved the issue, with the agent reporting Ready post-restart. This behavior is consistent with agent heartbeat timeouts after extended periods of VM inactivity and does not indicate a persistent configuration issue.

**Data connector diagnostic setting propagation**
After configuring the Entra ID data connector, the status displayed as "Disconnected" for approximately 2 minutes before updating to "Connected." This propagation delay is normal and reflects the time required for the Diagnostic Setting to be created in Entra ID and for the first log batch to arrive in the workspace. Premature troubleshooting before this window elapses produces false negatives.

**Lab environment sign-in data gaps**
In a lab environment with synthetic users and no internet exposure, sign-in log ingestion depends entirely on administrator activity. Overnight inactivity periods produce gaps in SigninLogs that can cause analytics rule evaluations to return no results. This is expected behavior and not a connector failure. Confirm data presence via direct KQL query before investigating connector health.

---

## Technologies Used

| Technology | Role |
|---|---|
| Microsoft Sentinel | SIEM — detection, investigation, automation |
| Azure Log Analytics Workspace | Log ingestion and query backend |
| Microsoft Entra ID | Identity signal source — sign-in and audit logs |
| Microsoft Defender for Endpoint | Endpoint signal source — device and alert telemetry |
| Microsoft Defender XDR | Unified XDR connector for cross-product signal correlation |
| Microsoft Intune | Endpoint compliance and management plane |
| Azure Logic Apps (Consumption) | Automated response playbook execution |
| Microsoft Graph PowerShell (v2.36.1) | Endpoint inventory and health reporting automation |
| KQL (Kusto Query Language) | Detection rule logic, investigation queries, workbook visualizations |
| Azure Virtual Machines (Windows 11 Pro) | Managed endpoints generating telemetry |
| Microsoft 365 Business Premium | Licensing foundation (Entra ID P1, Intune, Defender) |

---

## Project Structure

```
azure-cloud-security-monitoring/
├── README.md
├── scripts/
│   └── Get-CloudEndpointInventory.ps1
├── docs/
│   ├── architecture-diagram.md
│   ├── analytics-rules.md
│   ├── data-connector-configuration.md
│   ├── incident-investigation-workflow.md
│   └── playbook-design.md
└── evidence/
    ├── phase0-environment-validation/
    ├── phase1-sentinel-deployment/
    ├── phase2-data-connectors/
    ├── phase3-analytics-rules/
    ├── phase4-incident-investigation/
    ├── phase5-endpoint-inventory/
    ├── phase6-workbook/
    └── phase7-playbook/
```

---

## Author

**Emmanuel Johnson**

IT professional with hands-on experience in Microsoft 365 administration, identity and access management, endpoint management, and cloud security projects involving Azure, Microsoft Sentinel, Microsoft Entra ID, and Microsoft Intune.

Let's Connect: [LinkedIn](https://www.linkedin.com/in/emmanuel-a-johnson) · Portfolio: [GitHub](https://github.com/EJCyber) · Email: [emmanuel@ejohnsoncyber.com](mailto:emmanuel@ejohnsoncyber.com)

This project is the third in a three-part portfolio series demonstrating production-minded cloud infrastructure, identity governance, endpoint management, and security operations in Microsoft Azure.

[View Project 1 — Azure Identity Governance](https://github.com/EJCyber/azure-identity-governance) · [View Project 2 — Azure Cloud Endpoint Management](https://github.com/EJCyber/azure-cloud-endpoint-management)
