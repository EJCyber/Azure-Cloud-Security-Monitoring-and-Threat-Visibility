# Analytics Rules

## Overview
This document outlines the analytics rules configured in Microsoft Sentinel for the Azure Cloud Security Monitoring and Threat Visibility project.

The goal of the analytics layer is to convert incoming security telemetry into meaningful alerts and incidents that can be investigated by an administrator or analyst.

## Objective
The analytics rules in this environment were designed to detect suspicious identity activity while demonstrating how Microsoft Sentinel can convert raw sign-in telemetry into actionable security signals.

## Detection Approach
The project used a small set of analytics rules to simulate realistic detection coverage in a Microsoft-centric cloud environment.

### Focus Areas
- suspicious sign-in activity
- repeated authentication failures
- anomalous sign-in patterns
- sign-ins from unexpected geographic locations
- alert-to-incident generation
- validation of incident creation workflow

## Rule Design Principles
The analytics rules were selected and configured with the following goals in mind:
- use native Microsoft telemetry where possible
- generate incidents that can be investigated in Sentinel
- prioritize understandable and testable rules
- support identity-focused monitoring in a Microsoft cloud environment

## Configured Analytics Layer
The Sentinel deployment includes:
- **5 analytics rules**
- incident generation through rule matches
- investigation support through linked entities and evidence

### Active Rules
- Sign-In from Non-US Location Detected
- Brute force attack against Azure Portal
- Password spray attack against Microsoft Entra ID account
- Anomalous sign-in location by user account and authenticating application
- Attempts to sign in to disabled accounts

<img width="1511" height="812" alt="Active rules page " src="https://github.com/user-attachments/assets/f1b25996-87da-42bc-8e3c-562f4c0f7423" />


This screenshot shows the active Microsoft Sentinel analytics rules configured for the project, including a mix of high- and medium-severity detections tied primarily to Microsoft Entra ID telemetry.

## Example Rule Configuration
One example rule used in this project was **Sign-In from Non-US Location Detected**, a high-severity scheduled rule designed to detect successful sign-ins originating outside the United States.

The rule included:
- MITRE ATT&CK mapping to **Initial Access (T1078 - Valid Accounts)**
- hourly query execution
- 1-hour lookback period
- alert generation when the query returns more than 0 results
- entity mapping for **Account**, **IP**, and **Cloud Application**

<img width="1920" height="1032" alt="Custom KQL rule Review + Create page" src="https://github.com/user-attachments/assets/cb947fc8-2214-4196-8768-b3220bdd284d" />

This rule demonstrates how Microsoft Sentinel can convert Entra sign-in log activity into a prioritized incident signal with useful investigation context.

## Validation Method
Analytics rule validation was performed by:
1. confirming that relevant telemetry was ingested into the Log Analytics Workspace
2. enabling or configuring analytics rules inside Microsoft Sentinel
3. triggering or observing matching activity
4. confirming alert and incident creation
5. reviewing incident details, entities, and evidence in Sentinel

## Expected Outputs
A successful analytics rule implementation should produce:
- alerts tied to relevant log activity
- incidents visible in the Sentinel queue
- entities associated with the incident
- investigation context for triage and analysis

## Operational Considerations
When building analytics rules, it is important to consider:
- alert noise
- rule scope
- false positives
- incident grouping behavior
- investigation usefulness

In a production environment, rules would likely require further tuning based on normal user behavior, device activity, and business context.

## Related Documents
- [Data Connector Configuration](data-connector-configuration.md)
- [Incident Investigation Workflow](incident-investigation-workflow.md)
- [Workbook Design](workbook-design.md)
