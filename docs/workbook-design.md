# Workbook Design

## Overview
This document explains the workbook component used in the Azure Cloud Security Monitoring and Threat Visibility project.

Microsoft Sentinel workbooks provide a visual layer for monitoring security data, trends, and operational visibility across the environment.

## Workbook Information
**Workbook Name:** `Microsoft Entra ID Sign-in logs`

<img width="1920" height="1032" alt="workbook-list" src="https://github.com/user-attachments/assets/b120332b-ac48-41be-9c22-b881e2c9aa12" />

This screenshot shows the workbook configured in Microsoft Sentinel, including its saved status, source, required data type, and association with Microsoft Entra ID sign-in log data.

## Objective
Use a workbook to improve visibility into ingested security data and demonstrate how dashboards can support investigation and monitoring workflows.

## Workbook Purpose
The workbook was included to provide a centralized visual view of:
- security telemetry
- sign-in activity trends
- authentication outcomes
- operational monitoring data

<img width="1920" height="1032" alt="Workbook trend chart" src="https://github.com/user-attachments/assets/184069d4-4b18-4344-9126-b61c324c8e51" />

This screenshot shows the workbook’s sign-in analysis view, including trend data, success and failure counts, pending user actions, and location-based sign-in details.

## Design Goals
The workbook was designed to:
- present data in a more readable form than raw log queries alone
- support operational visibility
- complement Sentinel incidents and analytics rules
- demonstrate how dashboards fit into security monitoring workflows

## Data Sources
The workbook draws from data ingested through connected Microsoft services, including:
- Microsoft Entra ID logs
- Defender-related telemetry from Microsoft Defender XDR
- Microsoft Sentinel incident-related data

## Troubleshooting and Investigation Support
The workbook also helped surface authentication failures, sign-in error codes, and user action requirements in a more readable format. This made it useful not only for monitoring trends, but also for identifying problem areas during investigation and review.

<img width="1920" height="1032" alt="Workbook troubleshooting panel" src="https://github.com/user-attachments/assets/673171b7-e832-459c-8cb3-55e6e6b8e924" />

This screenshot shows the workbook’s troubleshooting view, including sign-in failures, top error summaries, pending user actions, and detailed sign-in records that support investigation and analysis.

## Value of the Workbook
While analytics rules and incidents help detect and investigate specific events, workbooks help provide:
- at-a-glance visibility
- trend awareness
- reporting support
- a more operational dashboard experience

## Validation Steps
The workbook was validated by:
1. confirming that data sources were connected and ingesting logs
2. opening the workbook inside Sentinel
3. verifying that visual elements populated with project data
4. confirming that the workbook reflected relevant environment activity

## Operational Considerations
In a production environment, workbooks can help security and IT teams monitor:
- authentication trends
- endpoint activity
- alert volumes
- incident trends
- operational health indicators

This project used a Microsoft Entra ID sign-in workbook to demonstrate how visual monitoring can complement analytics rules and incident-driven investigations through a more readable operational dashboard.

## Related Documents
- [Analytics Rules](analytics-rules.md)
- [Data Connector Configuration](data-connector-configuration.md)
- [Incident Investigation Workflow](incident-investigation-workflow.md)
