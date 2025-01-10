<!--#include file="../common/dbconnections.asp"-->
<!--#include file="../common/middleware.asp"-->
<!--#include file="../common/helpers.asp"-->

<%
Dim roleId, sql, rsRole, rsPermissions, role, permissions, groupedPermissions

' Check if role ID is provided
If Not IsNumeric(Request.QueryString("id")) Then
    Response.Redirect "roles_listing.asp"
    Response.End
End If

roleId = CInt(Request.QueryString("id"))

' Fetch role details
sql = "SELECT id, name, status FROM roles WHERE id = " & roleId
Set rsRole = conn.Execute(sql)

If rsRole.EOF Then
    Response.Redirect "roles_listing.asp?error=RoleNotFound"
    Response.End
End If

role = Array(rsRole("id"), rsRole("name"), rsRole("status"))
rsRole.Close
Set rsRole = Nothing

' Fetch permissions for the role
sql = "SELECT m.name AS module_name, r.name AS right_name " & _
      "FROM roles_modules_permissions p " & _
      "INNER JOIN modules m ON p.module_id = m.id " & _
      "INNER JOIN roles_modules_permissions_rights pmr ON p.id = pmr.roles_modules_permissions_id " & _
      "INNER JOIN rights r ON pmr.rights_id = r.id " & _
      "WHERE p.role_id = " & roleId
Set rsPermissions = conn.Execute(sql)

permissions = GetRowsFromRecordset(rsPermissions)
rsPermissions.Close
Set rsPermissions = Nothing

' Group permissions by module
Set groupedPermissions = Server.CreateObject("Scripting.Dictionary")
Dim moduleName, rightName

If Not IsEmpty(permissions) Then
    Dim i
    For i = LBound(permissions, 2) To UBound(permissions, 2)
        moduleName = permissions(0, i)
        rightName = permissions(1, i)
        
        If Not groupedPermissions.Exists(moduleName) Then
            groupedPermissions(moduleName) = Array()
        End If
        
        groupedPermissions(moduleName) = AppendToArray(groupedPermissions(moduleName), rightName)
    Next
End If

' Utility functions
Function GetRowsFromRecordset(rs)
    If Not rs.EOF Then
        GetRowsFromRecordset = rs.GetRows()
    Else
        GetRowsFromRecordset = Array()
    End If
End Function

Function AppendToArray(arr, value)
    Dim tempArr, i
    ReDim tempArr(UBound(arr) + 1)
    For i = LBound(arr) To UBound(arr)
        tempArr(i) = arr(i)
    Next
    tempArr(UBound(tempArr)) = value
    AppendToArray = tempArr
End Function
%>

<!DOCTYPE html>
<html>
<head>
    <title>Role Details</title>
</head>
<body>
    <h1>Role Details</h1>
    <!-- Include navigation -->
    <!--#include file="../common/navigations.asp"-->

    <h2>Role Information</h2>
    <p><strong>Name:</strong> <%= Server.HTMLEncode(role(1)) %></p>
    <p><strong>Status:</strong> <%= IIf(role(2), "Active", "Inactive") %></p>

    <h2>Permissions</h2>
    <% If groupedPermissions.Count > 0 Then %>
        <table border="1" width="100%">
            <thead>
                <tr>
                    <th>Module</th>
                    <th>Rights</th>
                </tr>
            </thead>
            <tbody>
                <% 
                Dim key, rightsList
                For Each key In groupedPermissions.Keys
                    rightsList = groupedPermissions(key)
                %>
                    <tr>
                        <td><%= Server.HTMLEncode(key) %></td>
                        <td><%= Join(rightsList, ", ") %></td>
                    </tr>
                <% Next %>
            </tbody>
        </table>
    <% Else %>
        <p>No permissions assigned to this role.</p>
    <% End If %>

    <!-- Uncomment below lines if you want Edit/Delete options -->
    <!--
    <p>
        <a href="roles_edit.asp?id=<%= role(0) %>">Edit Role</a> |
        <a href="roles_delete.asp?id=<%= role(0) %>" onclick="return confirm('Are you sure you want to delete this role?')">Delete Role</a>
    </p>
    -->
</body>
</html>
