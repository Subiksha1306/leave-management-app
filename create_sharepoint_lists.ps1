# PowerShell Script to Automatically Create SharePoint Lists and Columns

$siteUrl = "https://techxle.sharepoint.com/sites/LeaveManagement"

# 1. Ensure PnP.PowerShell is installed
Write-Host "Checking if PnP.PowerShell is installed..." -ForegroundColor Cyan
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "PnP.PowerShell not found. Installing now (this might take a minute)..." -ForegroundColor Yellow
    Install-Module PnP.PowerShell -Scope CurrentUser -Force -AllowClobber
} else {
    Write-Host "PnP.PowerShell is already installed." -ForegroundColor Green
}

# 2. Connect to SharePoint
Write-Host "Connecting to SharePoint at $siteUrl..." -ForegroundColor Cyan

$connected = $false

# Try Interactive (modern PnP.PowerShell)
try {
    Write-Host "Attempting modern connection (-Interactive)..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $siteUrl -Interactive -ErrorAction Stop
    $connected = $true
    Write-Host "Connected successfully using -Interactive!" -ForegroundColor Green
} catch {
    Write-Host "Modern interactive connection failed: $_. Falling back..." -ForegroundColor Yellow
}

# If not connected, try UseWebLogin (legacy SharePointPnPPowerShellOnline)
if (-not $connected) {
    try {
        Write-Host "Attempting legacy web connection (-UseWebLogin)..." -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -UseWebLogin -ErrorAction Stop
        $connected = $true
        Write-Host "Connected successfully using -UseWebLogin!" -ForegroundColor Green
    } catch {
        Write-Host "Legacy web connection failed: $_. Falling back..." -ForegroundColor Yellow
    }
}

# If still not connected, try default Connect-PnPOnline (which will prompt if needed/possible)
if (-not $connected) {
    try {
        Write-Host "Attempting standard connection (Connect-PnPOnline)..." -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -ErrorAction Stop
        $connected = $true
        Write-Host "Connected successfully!" -ForegroundColor Green
    } catch {
        Write-Error "Failed to connect to SharePoint: $_"
        exit 1
    }
}

# Helper function to create a list if it doesn't exist
function Create-ListIfNotExist($listTitle) {
    $list = Get-PnPList -Identity $listTitle -ErrorAction SilentlyContinue
    if ($null -eq $list) {
        Write-Host "Creating list '$listTitle'..." -ForegroundColor Yellow
        New-PnPList -Title $listTitle -Template GenericList -EnableVersioning
        return $true
    } else {
        Write-Host "List '$listTitle' already exists." -ForegroundColor Green
        return $false
    }
}

# Helper function to add a column if it doesn't exist
function Add-ColumnIfNotExist($listTitle, $displayName, $internalName, $type) {
    Write-Host "Adding column '$displayName' ($type) to list '$listTitle'..." -ForegroundColor Cyan
    Add-PnPField -List $listTitle -DisplayName $displayName -InternalName $internalName -Type $type -AddToDefaultView -ErrorAction SilentlyContinue
}

# 3. Create Lists and Columns

# --- 1. LeaveRequests ---
Create-ListIfNotExist "LeaveRequests"
Add-ColumnIfNotExist "LeaveRequests" "EmployeeId" "EmployeeId" "Number"
Add-ColumnIfNotExist "LeaveRequests" "LeaveTypeKey" "LeaveTypeKey" "Text"
Add-ColumnIfNotExist "LeaveRequests" "FromDate" "FromDate" "DateTime"
Add-ColumnIfNotExist "LeaveRequests" "ToDate" "ToDate" "DateTime"
Add-ColumnIfNotExist "LeaveRequests" "Days" "Days" "Number"
Add-ColumnIfNotExist "LeaveRequests" "Status" "Status" "Text"
Add-ColumnIfNotExist "LeaveRequests" "ManagerId" "ManagerId" "Number"
Add-ColumnIfNotExist "LeaveRequests" "SubmittedOn" "SubmittedOn" "DateTime"
Add-ColumnIfNotExist "LeaveRequests" "Reason" "Reason" "Note"
Add-ColumnIfNotExist "LeaveRequests" "RejectionReason" "RejectionReason" "Note"

# --- 2. LeaveBalances ---
Create-ListIfNotExist "LeaveBalances"
Add-ColumnIfNotExist "LeaveBalances" "EmployeeId" "EmployeeId" "Number"
Add-ColumnIfNotExist "LeaveBalances" "LeaveTypeKey" "LeaveTypeKey" "Text"
Add-ColumnIfNotExist "LeaveBalances" "BalanceDays" "BalanceDays" "Number"

# --- 3. Employees ---
Create-ListIfNotExist "Employees"
Add-ColumnIfNotExist "Employees" "EmployeeId" "EmployeeId" "Number"
Add-ColumnIfNotExist "Employees" "Email" "Email" "Text"
Add-ColumnIfNotExist "Employees" "ManagerId" "ManagerId" "Number"

# --- 4. LeaveTypes ---
Create-ListIfNotExist "LeaveTypes"
Add-ColumnIfNotExist "LeaveTypes" "Key" "Key" "Text"

Write-Host "`nSharePoint Lists Setup Complete! You can now connect them inside Power Apps." -ForegroundColor Green
