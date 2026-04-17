# Playbook Design

## Overview
This document explains the design of the Azure Logic App playbook used in the Azure Cloud Security Monitoring and Threat Visibility project.

The playbook demonstrates how Microsoft Sentinel incidents can trigger a lightweight automated response action through Azure Logic Apps.

## Playbook Information
**Playbook Name:** `la-p3-sentinel-brute-force-response`

<img width="1920" height="1032" alt="03-logic-app-resource-list" src="https://github.com/user-attachments/assets/634b9dbd-91c2-412f-88c9-aff5761cc3e3" />


This screenshot shows the Azure Logic App resource for the playbook, including its name, enabled status, hosting model, resource group, and deployment region.

## Objective
Provide lightweight response automation by sending an email notification when a qualifying Sentinel incident is created.

This demonstrates the value of reducing manual awareness delays and improving operational visibility when new incidents appear.

## Project Automation Scope
This playbook was designed as a lightweight response automation step within the broader Sentinel workflow. Its purpose was not to contain or remediate threats automatically, but to improve administrative awareness by notifying the administrator when a qualifying incident was created.

## Workflow Summary
When Microsoft Sentinel creates a qualifying incident, the playbook triggers automatically and sends an email notification to the administrator’s Gmail account. This provides immediate incident awareness without requiring constant manual monitoring of the Sentinel portal.

## Workflow Design

### Trigger
- **Microsoft Sentinel incident**

### Action
- **Send an email (V2)**

### Recipient
- Admin Gmail account

<img width="1920" height="1032" alt="01-logic-app-designer" src="https://github.com/user-attachments/assets/d9b7f619-b331-46a2-8583-31e6d8f2f79a" />

This screenshot shows the Logic App designer for the playbook, including the Microsoft Sentinel incident trigger and the Send an email (V2) action used for notification.

## Response Goal
The playbook is designed to support:
- faster awareness of incident creation
- reduced reliance on manual portal checking
- a foundation for more advanced SOAR workflows later

## Why Email Notification Was Chosen
For this project, email notification was chosen because it is:
- simple to validate
- easy to demonstrate
- useful as an operational awareness workflow
- a realistic first automation step before more advanced containment actions

## Validation Steps
The playbook was validated by:
1. confirming playbook creation in Azure Logic Apps
2. linking the playbook to Sentinel automation behavior
3. generating or observing an incident
4. verifying that the playbook executed
5. confirming successful workflow execution in Azure Logic Apps run history

<img width="1920" height="1032" alt="02-playbook-run-history" src="https://github.com/user-attachments/assets/3fc20d64-b7f7-4014-885c-6c6e26feb141" />

This screenshot shows successful playbook executions in Azure Logic Apps run history, confirming that the workflow triggered and completed successfully after incident creation.

## Operational Considerations
In a production environment, this playbook design could be expanded to support:
- ticket creation
- Teams or Slack notification
- incident enrichment
- conditional branching
- response approval workflows

This project intentionally keeps the automation simple to demonstrate core integration between Sentinel and Logic Apps.

## Related Documents
- [Incident Investigation Workflow](incident-investigation-workflow.md)
- [Architecture Diagram](architecture-diagram.md)
