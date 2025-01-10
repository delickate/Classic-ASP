<!--#include file="../common/dbconnections.asp"-->
<!--#include file="../common/middleware.asp"-->
<!--#include file="../common/helpers.asp"-->

<%
Dim errors, name, status, rolePermissions, sections, rights, sql, rs, roleId
Dim conn, sectionId, rightId, moduleId, stmt

Set errors = Server.CreateObject("Scripting.Dictionary")
name = ""
status = 1
Set rolePermissions = Server.CreateObject("Scripting.Dictionary")

' Fetch sections and rights
Set rs = conn.Execute("SELECT id, name FROM modules")
sections = GetRecordSetArray(rs)

Set rs = conn.Execute("SELECT id, name FROM rights")
rights = GetRecordSetArray(rs)

' Handle form submission
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    name = Replace(Request.Form("name"), "'", "''")
    status = IIf(Request.Form("status") <> "", 1, 0)
    
    ' Process role permissions
    Dim permissions
    Set permissions = Request.Form("permissions")
    If IsObject(permissions) Then
        For Each moduleId In permissions
            Set rolePermissions(moduleId) = permissions(moduleId)
        Next
    End If
    
    ' Validate name
    If Trim(name) = "" Then
        errors.Add "name", "Role name is required."
    End If

    ' If no errors, insert/update role
    If errors.Count = 0 Then
        On Error Resume Next
        conn.BeginTrans
        On Error Goto 0
        
        If IsNumeric(Request.Form("id")) Then
            ' Update existing role
            roleId = CInt(Request.Form("id"))
            sql = "UPDATE roles SET name = '" & name & "', status = " & status & " WHERE id = " & roleId
            conn.Execute sql
            
            ' Delete old permissions
            conn.Execute "DELETE FROM roles_modules_permissions WHERE role_id = " & roleId
        Else
            ' Insert new role
            sql = "INSERT INTO roles (name, status, is_default) VALUES ('" & name & "', " & status & ", 0)"
            conn.Execute sql
            Set rs = conn.Execute("SELECT @@IDENTITY AS lastId")
            roleId = rs("lastId")
        End If
        
        ' Insert permissions
        For Each moduleId In rolePermissions.Keys
            sql = "INSERT INTO roles_modules_permissions (role_id, module_id) VALUES (" & roleId & ", " & moduleId & ")"
            conn.Execute sql
            Set rs = conn.Execute("SELECT @@IDENTITY AS lastId")
            Dim roleModulePermissionId
            roleModulePermissionId = rs("lastId")
            
            For Each rightId In rolePermissions(moduleId)
                sql = "INSERT INTO roles_modules_permissions_rights (roles_modules_permissions_id, rights_id) VALUES (" & roleModulePermissionId & ", " & rightId & ")"
                conn.Execute sql
            Next
        Next

        conn.CommitTrans
        Response.Redirect "roles_listing.asp"
        Response.End
    End If
End If

' Utility Function to Convert Recordset to Array
Function GetRecordSetArray(rs)
    Dim arr, i
    arr = Array()
    i = 0
    While Not rs.EOF
        ReDim Preserve arr(i)
        arr(i) = Array(rs("id"), rs("name"))
        i = i + 1
        rs.MoveNext
    Wend
    rs.Close
    GetRecordSetArray = arr
End Function
%>

<!DOCTYPE html>
<html>
<head>
    <title><%= IIf(IsNumeric(Request.QueryString("id")), "Edit Role", "Add Role") %></title>
</head>
<body>
    <h1><%= IIf(IsNumeric(Request.QueryString("id")), "Edit Role", "Add Role") %></h1>
    <!-- Navigation -->
    <!--#include file="../common/navigations.asp"-->

    <!-- Display Errors -->
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
        <input type="text" name="name" value="<%= name %>" required><br>

        <label for="status">Active:</label>
        <input type="checkbox" name="status" value="1" <% If status = 1 Then Response.Write "checked" %>><br>

        <h3>Permissions</h3>
        <% Dim module, right, checked %>
        <% For Each module In sections %>
            <div>
                <strong><%= module(1) %></strong>
                <% For Each right In rights %>
                    <% checked = "" %>
                    <% If rolePermissions.Exists(module(0)) And InStr(rolePermissions(module(0)), right(0)) > 0 Then checked = "checked" %>
                    <label>
                        <input type="checkbox" name="permissions(<%= module(0) %>)[]" value="<%= right(0) %>" <%= checked %>>
                        <%= right(1) %>
                    </label>
                <% Next %>
            </div>
        <% Next %>

        <button type="submit"><%= IIf(IsNumeric(Request.QueryString("id")), "Update Role", "Add Role") %></button>
    </form>
</body>
</html>
