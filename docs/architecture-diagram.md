# Architecture Diagram

## Overview

This document explains the high-level architecture for the Azure Cloud Security Monitoring and Threat Visibility project. The environment was designed to simulate a production-minded Microsoft security monitoring workflow using Microsoft Entra ID, Microsoft Defender for Endpoint, Azure Log Analytics, Microsoft Sentinel, and an Azure Logic App playbook for centralized visibility, detection, investigation, and notification.

The environment was designed to simulate a production-minded Microsoft security monitoring workflow for a hybrid cloud environment. The project uses Microsoft Entra ID, Microsoft Defender for Endpoint, Azure Log Analytics, Microsoft Sentinel, and an Azure Logic App playbook to provide centralized visibility, alerting, incident investigation, and response automation.

## High-Level Architecture

The diagram below shows how identity and endpoint telemetry flow into Log Analytics and Microsoft Sentinel, with a Logic App playbook providing automated incident notification.

```text
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
## Core Components

### Microsoft Entra ID Tenant
**Tenant:** `mannylabsacctgmail.onmicrosoft.com`

Microsoft Entra ID serves as the identity layer for the environment. It provides identity-related telemetry that supports visibility into user activity and authentication behavior.

#### Log Sources
- Sign-in Logs
- Audit Logs
- Non-Interactive Sign-in Logs

These logs help detect authentication-related activity and provide visibility into identity events that may indicate suspicious sign-in behavior, risky application access, or administrative changes.

### Microsoft Defender for Endpoint
Microsoft Defender for Endpoint provides endpoint telemetry from Azure-hosted Windows client systems.

#### Monitored Devices
- `vm-p2-winclient` (`casey.quinn`)
- `vm-p2-winclient02` (`alex.rivers`)

#### Example Tables / Data Sources
- `DeviceInfo`
- `DeviceLogonEvents`
- `AlertInfo`
- `AlertEvidence`

This telemetry supports endpoint visibility, user logon tracking, alert generation, and investigation workflows.

### Log Analytics Workspace
**Workspace:** `law-p3-sentinel-westus2`  
**Region:** `West US 2`

The Log Analytics Workspace acts as the central data store for security telemetry collected from connected Microsoft services.

It aggregates logs from:
- Microsoft Entra ID
- Microsoft Defender for Endpoint
- Microsoft Sentinel-connected sources

### Microsoft Sentinel
Microsoft Sentinel serves as the central SIEM and security operations layer for this project.

#### Configured Components
- Analytics Rules
- Workbooks
- Incidents Queue
- Automation Rules

Sentinel is used to detect suspicious activity, generate incidents, support investigation, and visualize security data through dashboards and workbooks.

### Azure Logic App Playbook
**Playbook:** `la-p3-sentinel-brute-force-response`

The Azure Logic App playbook provides basic security automation for incident response.

#### Workflow
- **Trigger:** Incident created
- **Action:** Send email notification
- **Recipient:** Admin (Gmail)

This playbook demonstrates how Sentinel incidents can trigger a response workflow to improve operational awareness and reduce manual triage delays.

## Data Flow Summary
1. Microsoft Entra ID generates identity-related logs.
2. Microsoft Defender for Endpoint generates endpoint telemetry and alerts from monitored devices.
3. Relevant security data is stored in the Log Analytics Workspace.
4. Microsoft Sentinel consumes this data to power analytics rules, incident generation, and security investigations.
5. When specified incidents are created, the Logic App playbook triggers an email notification to the administrator.

## Security Operations Goal
The goal of this architecture is to simulate a realistic Microsoft-native cloud security monitoring workflow that supports:
- centralized visibility
- detection engineering
- incident triage
- investigation
- lightweight response automation

## Related Documents
- [Data Connector Configuration](data-connector-configuration.md)
- [Analytics Rules](analytics-rules.md)
- [Incident Investigation Workflow](incident-investigation-workflow.md)
- [Workbook Design](workbook-design.md)
- [Playbook Design](playbook-design.md)
