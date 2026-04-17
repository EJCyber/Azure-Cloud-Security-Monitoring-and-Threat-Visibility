# =============================================================================
# Get-CloudEndpointInventory.ps1
# Project 3 - Azure Cloud Security Monitoring and Threat Visibility
# Endpoint Inventory and Health Reporting via Microsoft Graph
# Author: Emmanuel Johnson
# =============================================================================

# --- CONFIGURATION ---
$TenantId         = "mannylabsacctgmail.onmicrosoft.com"
$StaleThresholdDays = 14
$ReportPath       = "$env:USERPROFILE\Desktop\CloudEndpointInventory_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

# --- CONNECT TO GRAPH ---
Write-Host "`n[*] Connecting to Microsoft Graph..." -ForegroundColor Cyan

Connect-MgGraph `
    -TenantId $TenantId `
    -Scopes "DeviceManagementManagedDevices.Read.All", "DeviceManagementConfiguration.Read.All" `
    -ContextScope Process `
    -NoWelcome

Write-Host "[+] Connected to Microsoft Graph" -ForegroundColor Green

# --- PULL ALL MANAGED DEVICES ---
Write-Host "`n[*] Retrieving managed devices from Intune..." -ForegroundColor Cyan

$Devices = Get-MgDeviceManagementManagedDevice -All -Property `
    Id, DeviceName, OperatingSystem, OsVersion, ComplianceState, `
    LastSyncDateTime, EnrolledDateTime, UserPrincipalName, `
    ManagedDeviceOwnerType, ManagementAgent, DeviceEnrollmentType, `
    SerialNumber, Manufacturer, Model

Write-Host "[+] Retrieved $($Devices.Count) managed device(s)" -ForegroundColor Green

# --- BUILD INVENTORY REPORT ---
Write-Host "`n[*] Building inventory report..." -ForegroundColor Cyan

$Report = foreach ($Device in $Devices) {

    $LastSync     = $Device.LastSyncDateTime
    $DaysSinceSync = if ($LastSync) {
        [math]::Round(((Get-Date).ToUniversalTime() - $LastSync.ToUniversalTime()).TotalDays, 1)
    } else { "Unknown" }

    $StaleStatus  = if ($DaysSinceSync -ne "Unknown" -and $DaysSinceSync -gt $StaleThresholdDays) {
        "STALE"
    } elseif ($DaysSinceSync -eq "Unknown") {
        "UNKNOWN"
    } else {
        "Current"
    }

    $ComplianceStatus = switch ($Device.ComplianceState) {
        "compliant"    { "Compliant" }
        "noncompliant" { "NON-COMPLIANT" }
        "inGracePeriod" { "Grace Period" }
        "unknown"      { "Unknown" }
        default        { $Device.ComplianceState }
    }

    [PSCustomObject]@{
        DeviceName        = $Device.DeviceName
        PrimaryUser       = $Device.UserPrincipalName
        OS                = $Device.OperatingSystem
        OSVersion         = $Device.OsVersion
        ComplianceState   = $ComplianceStatus
        LastCheckIn       = if ($LastSync) { $LastSync.ToString("yyyy-MM-dd HH:mm") } else { "Never" }
        DaysSinceCheckIn  = $DaysSinceSync
        StaleStatus       = $StaleStatus
        EnrolledDate      = if ($Device.EnrolledDateTime) { $Device.EnrolledDateTime.ToString("yyyy-MM-dd") } else { "Unknown" }
        Ownership         = $Device.ManagedDeviceOwnerType
        Manufacturer      = $Device.Manufacturer
        Model             = $Device.Model
        SerialNumber      = $Device.SerialNumber
    }
}

# --- CONSOLE SUMMARY ---
Write-Host "`n===== ENDPOINT INVENTORY SUMMARY =====" -ForegroundColor Yellow
Write-Host "Total Devices       : $($Report.Count)" -ForegroundColor White
Write-Host "Compliant           : $(($Report | Where-Object ComplianceState -eq 'Compliant').Count)" -ForegroundColor Green
Write-Host "Non-Compliant       : $(($Report | Where-Object ComplianceState -eq 'NON-COMPLIANT').Count)" -ForegroundColor Red
Write-Host "Stale (>$StaleThresholdDays days)  : $(($Report | Where-Object StaleStatus -eq 'STALE').Count)" -ForegroundColor Red
Write-Host "Current Check-In    : $(($Report | Where-Object StaleStatus -eq 'Current').Count)" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Yellow

# --- DISPLAY TABLE ---
Write-Host "`n[*] Device Details:" -ForegroundColor Cyan
$Report | Select-Object DeviceName, ComplianceState, DaysSinceCheckIn, StaleStatus, OSVersion | 
    Format-Table -AutoSize
Write-Host ""
$Report | Select-Object DeviceName, PrimaryUser | Format-Table -AutoSize

# --- EXPORT CSV ---
Write-Host "`n[*] Exporting report to CSV..." -ForegroundColor Cyan
$Report | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
Write-Host "[+] Report exported to: $ReportPath" -ForegroundColor Green

# --- DISCONNECT ---
Disconnect-MgGraph | Out-Null
Write-Host "[+] Disconnected from Microsoft Graph`n" -ForegroundColor Green
