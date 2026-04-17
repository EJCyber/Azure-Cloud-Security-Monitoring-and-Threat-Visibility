# Data Connector Configuration

## Overview
This document explains the data connectors used in the Azure Cloud Security Monitoring and Threat Visibility project.

The purpose of the connector layer is to bring identity and Defender-related security telemetry into the Log Analytics Workspace so Microsoft Sentinel can use that data for detection, investigation, incident generation, and visualization.

## Objective
Enable key Microsoft security data sources to support:
- identity monitoring
- endpoint monitoring
- analytics rule execution
- incident creation
- workbook visibility

## Configured Connectors
The Microsoft Sentinel deployment for this project used Microsoft-native connectors to bring identity and Defender-related security telemetry into the Log Analytics Workspace.

### Configured Connector Set
- Microsoft Entra ID
  - Sign-in Logs
  - Audit Logs
  - Non-Interactive Sign-in Logs
- Microsoft Defender XDR

<img width="1920" height="1032" alt="Entra ID connector showing Connected" src="https://github.com/user-attachments/assets/a94a7601-f753-4e9d-abc0-fac01bed6607" />

This screenshot shows the Microsoft Entra ID connector configured in Sentinel with Sign-in Logs, Audit Logs, and Non-Interactive User Sign-In Logs enabled for ingestion.

<img width="1920" height="1032" alt="Defender XDR connector showing Connected" src="https://github.com/user-attachments/assets/13c789e1-91a8-4149-a9ca-34277488c547" />

This screenshot shows the Microsoft Defender XDR connector connected to Microsoft Sentinel, providing Defender-related security data for investigation and incident support.

## Connected Data Sources

### Microsoft Entra ID
Microsoft Entra ID was connected to provide identity-related logs.

#### Enabled Log Types
- Sign-in Logs
- Audit Logs
- Non-Interactive Sign-in Logs

#### Purpose
These logs provide visibility into:
- user sign-in activity
- administrative changes
- authentication behavior
- background or application-driven authentication events

### Microsoft Defender XDR
Microsoft Defender XDR was connected to provide Defender-related security telemetry, including endpoint-relevant signals used for investigation and incident context.

#### Example Tables / Signals
- `DeviceInfo`
- `DeviceLogonEvents`
- `AlertInfo`
- `AlertEvidence`

#### Purpose
This data supports:
- endpoint visibility
- user-to-device mapping
- endpoint alerting
- evidence collection during investigations

## Log Analytics Workspace
**Workspace:** `law-p3-sentinel-westus2`

All connected telemetry is routed into the Log Analytics Workspace, where it becomes available to Microsoft Sentinel for querying, analytics, and workbook visualization.

This workspace serves as the shared data foundation for Sentinel analytics rules, incident generation, and workbook queries used throughout the project.

## Validation Steps
The connector configuration was validated by:
1. confirming connector enablement in Microsoft Sentinel
2. confirming data ingestion into the Log Analytics Workspace
3. verifying that relevant tables were populated
4. confirming that analytics rules could use ingested data
5. validating that incidents could be generated from connected sources

## Why These Connectors Were Chosen
This project focuses on Microsoft-native visibility across two critical domains:
- **identity**
- **endpoint**

By combining Entra ID and Defender-related telemetry, the environment can support more realistic security monitoring and incident investigation workflows than using either source alone.

## Operational Considerations
A connector may be enabled but still require time before useful data appears. During validation, it is important to confirm:
- connector health
- data arrival timing
- table population
- whether analytics rules have sufficient data to evaluate

## Related Documents
- [Architecture Diagram](architecture-diagram.md)
- [Analytics Rules](analytics-rules.md)
- [Incident Investigation Workflow](incident-investigation-workflow.md)
