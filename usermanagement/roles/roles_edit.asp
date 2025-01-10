<!--#include file="../common/dbconnections.asp"-->
<!--#include file="../common/middleware.asp"-->
<!--#include file="../common/helpers.asp"-->

<%
Dim errors, name, status, rolePermissions, roleId, sections, rights, permissions
Dim sql, rs, rsPermissions, rsSections, rsRights, rsRole, moduleId, rightId

Set errors = Server.CreateObject("Scripting.Dictionary")
Set rolePermissions = Server.CreateObject("Scripting.Dictionary")
name = ""
status = 1
roleId = 0

If Len(Request.QueryString("id")) > 0 Then
    roleId = CInt(Request.QueryString("id"))
End If

' Fetch sections and rights
sql = "SELECT id, name FROM modules"
Set rsSections = conn.Execute(sql)

sections = GetRowsFromRecordset(rsSections)
rsSections.Close
Set rsSections = Nothing

sql = "SELECT id, name FROM rights"
Set rsRights = conn.Execute(sql)

rights = GetRowsFromRecordset(rsRights)
rsRights.Close
Set rsRights = Nothing

' Fetch role details and permissions if editing
If roleId > 0 Then
    sql = "SELECT * FROM roles WHERE id = " & roleId
    Set rsRole = conn.Execute(sql)
    
    If Not rsRole.EOF Then
        name = rsRole("name")
        status = rsRole("status")
        
        ' Fetch role permissions
        sql = "SELECT rmp.module_id, rmp_r.rights_id " & _
              "FROM roles_modules_permissions rmp " & _
              "INNER JOIN roles_modules_permissions_rights rmp_r ON rmp.id = rmp_r.roles_modules_permissions_id " & _
              "WHERE rmp.role_id = " & roleId
        Set rsPermissions = conn.Execute(sql)
        
        While Not rsPermissions.EOF
            moduleId = rsPermissions("module_id")
            rightId = rsPermissions("rights_id")
            
            If Not rolePermissions.Exists(moduleId) Then
                rolePermissions(moduleId) = Array()
            End If
            
            rolePermissions(moduleId) = AppendToArray(rolePermissions(moduleId), rightId)
            rsPermissions.MoveNext
        Wend
        
        rsPermissions.Close
        Set rsPermissions = Nothing
    Else
        errors.Add "role_not_found", "Role not found."
    End If
End If

' Handle form submission
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    name = Trim(Request.Form("name"))
    If Len(Request.Form("status")) > 0 Then
        status = 1
    Else
        status = 0
    End If

    ' Fetch permissions
    For Each moduleId In Request.Form
        If Left(moduleId, 11) = "permissions" Then
            Dim rightValues, tempId
            tempId = Mid(moduleId, 13, Len(moduleId) - 12) ' Extract module_id
            rightValues = Request.Form(moduleId)
            If IsArray(rightValues) Then
                rolePermissions(tempId) = rightValues
            Else
                rolePermissions(tempId) = Array(rightValues)
            End If
        End If
    Next

    ' Validate name
    If Len(name) = 0 Then
        errors.Add "name_required", "Role name is required."
    End If

    ' Update role if no errors
    If errors.Count = 0 Then
        sql = "UPDATE roles SET name = '" & Replace(name, "'", "''") & "', status = " & status & " WHERE id = " & roleId
        conn.Execute(sql)

        ' Delete old permissions
        sql = "DELETE FROM roles_modules_permissions_rights WHERE roles_modules_permissions_id IN " & _
              "(SELECT id FROM roles_modules_permissions WHERE role_id = " & roleId & ")"
        conn.Execute(sql)

        sql = "DELETE FROM roles_modules_permissions WHERE role_id = " & roleId
        conn.Execute(sql)

        ' Insert new permissions
        For Each moduleId In rolePermissions.Keys
            sql = "INSERT INTO roles_modules_permissions (role_id, module_id) VALUES (" & roleId & ", " & moduleId & ")"
            conn.Execute(sql)

            Dim roleModulePermissionId, rightArray
            roleModulePermissionId = conn.Execute("SELECT LAST_INSERT_ID()").Fields(0).Value
            rightArray = rolePermissions(moduleId)

            For Each rightId In rightArray
                sql = "INSERT INTO roles_modules_permissions_rights (roles_modules_permissions_id, rights_id) VALUES (" & roleModulePermissionId & ", " & rightId & ")"
                conn.Execute(sql)
            Next
        Next

        Response.Redirect "roles_listing.asp"
        Response.End
    End If
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
    <title>Edit Role</title>
</head>
<body>
    <h1>Edit Role</h1>
    <!-- Include navigation -->
    <!--#include file="../common/navigations.asp"-->

    <% If errors.Count > 0 Then %>
        <div style="color: red;">
            <ul>
                <% For Each key In errors.Keys %>
                    <li><%= errors(key) %></li>
                <% Next %>
            </ul>
        </div>
    <% End If %>

    <form method="POST">
        <label for="name">Role Name:</label>
        <input type="text" name="name" value="<%= Server.HTMLEncode(name) %>" required><br>

        <label for="status">Active:</label>
        <input type="checkbox" name="status" value="1" <% If status = 1 Then Response.Write("checked") %>><br>

        <h3>Permissions</h3>
        <% 
        Dim section, rightItem
        For Each section In sections
            moduleId = section(0)
        %>
            <div>
                <strong><%= section(1) %></strong>
                <% For Each rightItem In rights
                    rightId = rightItem(0)
                %>
                    <label>
                        <input type="checkbox" name="permissions[<%= moduleId %>][]" value="<%= rightId %>" 
                        <% If rolePermissions.Exists(moduleId) And IsInArray(rightId, rolePermissions(moduleId)) Then Response.Write("checked") %>>
                        <%= rightItem(1) %>
                    </label>
                <% Next %>
            </div>
        <% Next %>

        <button type="submit">Update Role</button>
    </form>
</body>
</html>
