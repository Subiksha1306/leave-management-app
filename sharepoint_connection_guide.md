# SharePoint List Backend Integration Guide

To connect your Leave Management App to SharePoint, follow these two main steps:
1. **Create the SharePoint Lists** with matching columns.
2. **Connect the lists inside Power Apps** and update the formulas to read/write from SharePoint.

---

## Step 1: Create the 4 SharePoint Lists

Go to your SharePoint Site, click **New** -> **List** -> **Blank list**, and create the following lists with these exact column types:

### 1. `LeaveRequests` List
*   `Title` (Single line of text - *automatically created*) — Used for Request ID or Employee Name.
*   `EmployeeId` (Number)
*   `LeaveTypeKey` (Single line of text) — e.g. "Annual", "Sick", "Unpaid".
*   `FromDate` (Date only)
*   `ToDate` (Date only)
*   `Days` (Number)
*   `Status` (Single line of text) — e.g. "Pending", "Approved", "Rejected".
*   `ManagerId` (Number)
*   `SubmittedOn` (Date and Time)
*   `Reason` (Multiple lines of text)
*   `RejectionReason` (Multiple lines of text)

### 2. `LeaveBalances` List
*   `Title` (Single line of text) — Used for Employee Name.
*   `EmployeeId` (Number)
*   `LeaveTypeKey` (Single line of text) — e.g. "Annual", "Sick".
*   `BalanceDays` (Number)

### 3. `Employees` List
*   `Title` (Single line of text) — Used for Employee Name.
*   `EmployeeId` (Number)
*   `Email` (Single line of text)
*   `ManagerId` (Number)

### 4. `LeaveTypes` List
*   `Title` (Single line of text) — Used for Leave Display Name (e.g. "Annual Leave").
*   `Key` (Single line of text) — e.g. "Annual", "Sick", "Unpaid".

---

## Step 2: Add SharePoint Connections in Power Apps

1. In the Power Apps Studio canvas editor, select the **Data** icon (cylinder database cylinder) on the left-hand navigation pane.
2. Click **Add data** -> search for **SharePoint**.
3. Select your SharePoint connection, enter your SharePoint site URL, select the **4 lists** you created above, and click **Connect**.

---

## Step 3: Update Power Fx Formulas to Sync SharePoint

To connect your existing screens to SharePoint with **minimal code changes**, you can sync your SharePoint lists to the local collections used in the app:

### 1. App.OnStart Property
Replace your mock data inside `App.OnStart` with calls to sync from SharePoint:
```powerapps
// Read initial data from SharePoint lists into local collections
ClearCollect(colLeaveTypes, 
    ShowColumns(LeaveTypes, "ID", "Key", "Title") // Rename Title to DisplayName to match app
);

ClearCollect(colEmployees, Employees);
ClearCollect(colLeaveBalances, LeaveBalances);
ClearCollect(colLeaveRequests, LeaveRequests);

// App state initializations
Set(isLoading, false);
Set(selectedRequest, First(colLeaveRequests));
Set(selectedLeaveType, First(colLeaveTypes));
Set(currentUserId, 1); // Set default active employee ID
Set(currentUserIsManager, LookUp(colEmployees, EmployeeId = currentUserId, ManagerId) = 0);
```

### 2. ApplyLeave Screen (btnSubmit.OnSelect)
Change the submit button to write directly to the SharePoint `LeaveRequests` list, then refresh your local collection:
```powerapps
// Write to SharePoint List
Collect(LeaveRequests, {
    Title: User().FullName & " - Leave Request",
    EmployeeId: currentUserId,
    LeaveTypeKey: varLeaveType.Key,
    FromDate: varFromDate,
    ToDate: varToDate,
    Days: DateDiff(varFromDate, varToDate, TimeUnit.Days) + 1,
    Status: "Pending",
    ManagerId: LookUp(colEmployees, EmployeeId = currentUserId, ManagerId),
    SubmittedOn: Now(),
    Reason: varReason
});

// Refresh local request collection from SharePoint
ClearCollect(colLeaveRequests, LeaveRequests);

Notify("Leave request submitted.", NotificationType.Success);
Set(varLeaveType, Blank()); Set(varFromDate, Today()); Set(varToDate, Today()); Set(varReason, "");
Navigate(Dashboard);
```

### 3. ManagerApproval Screen (ApproveButton.OnSelect)
Update the approval button to update the status in SharePoint:
```powerapps
Patch(LeaveRequests, LookUp(LeaveRequests, ID = selectedRequest.ID), { Status: "Approved" });

// Sync changes back to local collections
ClearCollect(colLeaveRequests, LeaveRequests);
Set(ManagerQueue, Filter(colLeaveRequests, Status = "Pending" && ManagerId = currentUserId));
Notify("Request approved", NotificationType.Success);
```

### 4. ManagerApproval Screen (ConfirmReject.OnSelect)
Update the rejection confirmation button to update the status and rejection reason in SharePoint:
```powerapps
Patch(LeaveRequests, LookUp(LeaveRequests, ID = selectedRequest.ID), { Status: "Rejected", RejectionReason: rejectReason });

// Sync changes back to local collections
ClearCollect(colLeaveRequests, LeaveRequests);
Set(showRejectModal, false);
Set(ManagerQueue, Filter(colLeaveRequests, Status = "Pending" && ManagerId = currentUserId));
Notify("Request rejected", NotificationType.Success);
```
