<!--#include file="../common/dbconnections.asp"-->
<!--#include file="../common/middleware.asp"-->
<!--#include file="../common/helpers.asp"-->

<%
' Initialize variables
Dim errors, name, email, phone, status, picture, selectedRoles, userId, roles, user
errors = Array()
name = ""
email = ""
phone = ""
status = 0
picture = ""
selectedRoles = Array()

' Ensure the uploads folder exists
CreateFolderIfNotExists(Server.MapPath("../uploads/images/profile/"))

' Fetch roles from the `roles` table
Set rsRoles = conn.Execute("SELECT id, name FROM roles WHERE is_default = 0")
roles = GetRecordSetArray(rsRoles)

' Fetch user details
If Not IsNumeric(Request.QueryString("id")) Then
    Response.Write("Invalid user ID.")
    Response.End()
End If

userId = CInt(Request.QueryString("id"))
sql = "SELECT u.* FROM users as u " & _
      "INNER JOIN users_roles as ur ON (u.id = ur.user_id) " & _
      "INNER JOIN roles r ON (ur.role_id = r.id) WHERE u.id = ?"
Set cmd = Server.CreateObject("ADODB.Command")
cmd.ActiveConnection = conn
cmd.CommandText = sql
cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , userId)
Set rsUser = cmd.Execute()
If rsUser.EOF Then
    Response.Write("User not found.")
    Response.End()
End If

user = rsUser.Fields
name = Server.HTMLEncode(user("name"))
email = Server.HTMLEncode(user("email"))
phone = Server.HTMLEncode(user("phone"))
picture = Server.HTMLEncode(user("picture"))
status = user("status")

' Fetch user's roles
sql = "SELECT role_id FROM users_roles WHERE user_id = ?"
cmd.CommandText = sql
Set rsUserRoles = cmd.Execute()
selectedRoles = GetRecordSetColumn(rsUserRoles, "role_id")

' Handle form submission
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    name = Server.HTMLEncode(Request.Form("name"))
    email = Server.HTMLEncode(Request.Form("email"))
    password = Request.Form("password")
    phone = Server.HTMLEncode(Request.Form("phone"))
    status = IIf(Request.Form("status") = "1", 1, 0)
    selectedRoles = Split(Request.Form("roles"), ",")
    picture = user("picture")

    ' Validation
    If Not name Like "*[a-zA-Z0-9 .\-]*" Then
        AppendToArray errors, "Name can only contain alphanumeric characters, spaces, hyphens, and dots."
    End If
    If Not IsValidEmail(email) Then
        AppendToArray errors, "Invalid email format."
    End If
    If Len(password) > 0 And Len(password) < 6 Then
        AppendToArray errors, "Password must be at least 6 characters long."
    End If
    If Not phone Like "0092*" Then
        AppendToArray errors, "Phone number must start with '0092' and contain only digits."
    End If
    If UBound(selectedRoles) < 0 Then
        AppendToArray errors, "At least one role must be selected."
    End If

    ' Handle file upload
    If Request.Form("picture") <> "" Then
        Dim file, filePath, fileType, allowedTypes
        file = Request.Form("picture")
        filePath = "../uploads/images/profile/" & file
        fileType = LCase(Mid(file, InStrRev(file, ".") + 1))
        allowedTypes = Array("jpg", "jpeg", "png", "gif")
        If Not IsInArray(fileType, allowedTypes) Then
            AppendToArray errors, "Profile picture must be an image (jpg, jpeg, png, gif)."
        ElseIf Not SaveUploadedFile("picture", Server.MapPath(filePath)) Then
            AppendToArray errors, "Failed to upload profile picture."
        Else
            picture = file
        End If
    End If

    ' Update user if no errors
    If UBound(errors) = -1 Then
        sql = "UPDATE users SET name = ?, email = ?, phone = ?, picture = ?, status = ? WHERE id = ?"
        cmd.CommandText = sql
        cmd.Parameters.Append cmd.CreateParameter("@name", 200, 1, 255, name)
        cmd.Parameters.Append cmd.CreateParameter("@email", 200, 1, 255, email)
        cmd.Parameters.Append cmd.CreateParameter("@phone", 200, 1, 255, phone)
        cmd.Parameters.Append cmd.CreateParameter("@picture", 200, 1, 255, picture)
        cmd.Parameters.Append cmd.CreateParameter("@status", 3, 1, , status)
        cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , userId)
        cmd.Execute()

        If Len(password) > 0 Then
            sql = "UPDATE users SET password = ? WHERE id = ?"
            cmd.CommandText = sql
            cmd.Parameters.Append cmd.CreateParameter("@password", 200, 1, 255, MD5Hash(password))
            cmd.Execute()
        End If

        sql = "DELETE FROM users_roles WHERE user_id = ?"
        cmd.CommandText = sql
        cmd.Execute()

        sql = "INSERT INTO users_roles (user_id, role_id) VALUES (?, ?)"
        cmd.CommandText = sql
        For Each roleId In selectedRoles
            cmd.Parameters.Append cmd.CreateParameter("@role_id", 3, 1, , roleId)
            cmd.Execute()
        Next

        Response.Redirect("users_listing.asp")
    End If
End If

' Helper functions for handling recordsets and arrays
Function GetRecordSetArray(rs)
    Dim arr, i
    arr = Array()
    i = 0
    While Not rs.EOF
        ReDim Preserve arr(i)
        arr(i) = rs.Fields
        i = i + 1
        rs.MoveNext
    Wend
    GetRecordSetArray = arr
End Function

Function GetRecordSetColumn(rs, columnName)
    Dim arr, i
    arr = Array()
    i = 0
    While Not rs.EOF
        ReDim Preserve arr(i)
        arr(i) = rs(columnName)
        i = i + 1
        rs.MoveNext
    Wend
    GetRecordSetColumn = arr
End Function

Function AppendToArray(ByRef arr, value)
    ReDim Preserve arr(UBound(arr) + 1)
    arr(UBound(arr)) = value
End Function

Function IsInArray(value, arr)
    Dim item
    For Each item In arr
        If item = value Then
            IsInArray = True
            Exit Function
        End If
    Next
    IsInArray = False
End Function
%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit User</title>
</head>
<body>
    <!-- Errors -->
    <% If UBound(errors) >= 0 Then %>
    <div style="color: red;">
        <ul>
            <% For Each error In errors %>
                <li><%= error %></li>
            <% Next %>
        </ul>
    </div>
    <% End If %>

    <!-- Form -->
    <form method="POST" enctype="multipart/form-data">
        <label for="name">Name:</label>
        <input type="text" name="name" value="<%= name %>" required><br>

        <label for="email">Email:</label>
        <input type="email" name="email" value="<%= email %>" required><br>

        <label for="password">Password:</label>
        <input type="password" name="password" placeholder="Leave blank to keep unchanged"><br>

        <label for="phone">Phone:</label>
        <input type="text" name="phone" value="<%= phone %>" required><br>

        <label for="picture">Profile Picture:</label>
        <input type="file" name="picture"><br>
        <% If picture <> "" Then %>
            <img src="<%= "../uploads/images/profile/" & picture %>" width="100"><br>
        <% End If %>

        <label for="status">Active:</label>
        <input type="checkbox" name="status" value="1" <% If status Then Response.Write("checked") %>><br>

        <label for="roles">Roles:</label>
        <select name="roles[]" multiple required>
            <% For Each role In roles %>
                <option value="<%= role("id") %>" <% If IsInArray(role("id"), selectedRoles) Then Response.Write("selected") %>>
                    <%= Server.HTMLEncode(role("name")) %>
                </option>
            <% Next %>
        </select><br>

        <button type="submit">Update User</button>
    </form>

    <input type="button" name="btn_back" value="Back" onclick="history.back()">
</body>
</html>
