<%
' Include common files
<!--#include file="../common/dbconnections.asp" -->
<!--#include file="../common/middleware.asp" -->
<!--#include file="../common/helpers.asp" -->

' Dynamic folder creation
Call createFolderIfNotExists("../uploads/images/profile/")

' Declaring variables
Dim errors, name, email, phone, status, picture, selectedRoles
Set errors = Server.CreateObject("Scripting.Dictionary")
name = ""
email = ""
phone = ""
status = 0
picture = ""
Set selectedRoles = Server.CreateObject("Scripting.Dictionary")

' Fetch roles from the `roles` table
Dim conn, rs, sql
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "your_connection_string"

sql = "SELECT id, name FROM roles WHERE is_default = 0"
Set rs = conn.Execute(sql)
Dim roles()
Dim i
i = 0
Do While Not rs.EOF
    ReDim Preserve roles(i)
    roles(i) = rs("id") & "," & rs("name")
    i = i + 1
    rs.MoveNext
Loop

rs.Close
Set rs = Nothing

' If form submitted
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then

    name = Request.Form("name")
    email = Request.Form("email")
    password = Request.Form("password")
    phone = Request.Form("phone")
    status = IIf(Request.Form("status") <> "", 1, 0)
    Set selectedRoles = Request.Form("roles")

    ' Validate name: alphanumeric, space, hyphen, dot
    If Not name Like "[A-Za-z0-9 .-]*" Then
        errors.Add "name", "Name can only contain alphanumeric characters, spaces, hyphens, and dots."
    End If

    ' Validate email
    If Not IsEmailValid(email) Then
        errors.Add "email", "Invalid email format."
    End If

    ' Validate password: required and at least 6 characters
    If Len(password) < 6 Then
        errors.Add "password", "Password must be at least 6 characters long."
    End If

    ' Validate phone: must start with '0092' and contain only digits
    If Not phone Like "0092*" Then
        errors.Add "phone", "Phone number must start with '0092' and contain only digits."
    End If

    ' Validate roles
    If selectedRoles.Count = 0 Then
        errors.Add "roles", "At least one role must be selected."
    End If

    ' Handle file upload
    If Request.Files("picture").ContentType <> "" Then
        targetDir = "../uploads/images/profile/"
        fileName = Now() & "_" & Request.Files("picture").FileName
        targetFile = targetDir & fileName
        fileType = LCase(Right(fileName, 3))

        If fileType <> "jpg" And fileType <> "png" And fileType <> "gif" Then
            errors.Add "picture", "Profile picture must be an image (jpg, jpeg, png, gif)."
        Else
            Request.Files("picture").SaveAs(targetFile)
            picture = fileName
        End If
    End If

    ' If no errors, insert user and assign roles
    If errors.Count = 0 Then
        hashedPassword = MD5(password)

        ' Insert user into `users` table
        sql = "INSERT INTO users (name, email, password, phone, picture, status, is_default) VALUES (?, ?, ?, ?, ?, ?, 0)"
        Set cmd = Server.CreateObject("ADODB.Command")
        cmd.ActiveConnection = conn
        cmd.CommandText = sql
        cmd.Parameters.Append cmd.CreateParameter("@name", 200, 1, 255, name)
        cmd.Parameters.Append cmd.CreateParameter("@email", 200, 1, 255, email)
        cmd.Parameters.Append cmd.CreateParameter("@password", 200, 1, 255, hashedPassword)
        cmd.Parameters.Append cmd.CreateParameter("@phone", 200, 1, 255, phone)
        cmd.Parameters.Append cmd.CreateParameter("@picture", 200, 1, 255, picture)
        cmd.Parameters.Append cmd.CreateParameter("@status", 3, 1, , status)
        cmd.Execute

        userId = conn.Execute("SELECT @@IDENTITY")(0)

        ' Insert roles into `users_roles` table
        sql = "INSERT INTO users_roles (user_id, role_id) VALUES (?, ?)"
        Set cmd = Server.CreateObject("ADODB.Command")
        cmd.ActiveConnection = conn
        cmd.CommandText = sql

        For Each role In selectedRoles
            cmd.Parameters.Append cmd.CreateParameter("@user_id", 3, 1, , userId)
            cmd.Parameters.Append cmd.CreateParameter("@role_id", 3, 1, , role)
            cmd.Execute
        Next

        Response.Redirect "users_listing.asp"
    End If
End If

' Helper function to validate email format
Function IsEmailValid(email)
    Dim regEx
    Set regEx = New RegExp
    regEx.IgnoreCase = True
    regEx.Global = True
    regEx.Pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    IsEmailValid = regEx.Test(email)
    Set regEx = Nothing
End Function
%>

<!DOCTYPE html>
<html>
<head>
    <title>Add User</title>
</head>
<body>
    <form method="POST" enctype="multipart/form-data">
        <% If errors.Count > 0 Then %>
            <div style="color: red;">
                <ul>
                    <% 
                    For Each key In errors.Keys
                        Response.Write("<li>" & errors(key) & "</li>")
                    Next
                    %>
                </ul>
            </div>
        <% End If %>

        <label for="name">Name:</label>
        <input type="text" name="name" value="<%= name %>" required><br>

        <label for="email">Email:</label>
        <input type="email" name="email" value="<%= email %>" required><br>

        <label for="password">Password:</label>
        <input type="password" name="password" required><br>

        <label for="phone">Phone:</label>
        <input type="text" name="phone" value="<%= phone %>" required><br>

        <label for="picture">Profile Picture:</label>
        <input type="file" name="picture"><br>

        <label for="status">Active:</label>
        <input type="checkbox" name="status" value="1" <%= IIf(status = 1, "checked", "") %>><br>

        <label for="roles">Roles:</label>
        <select name="roles[]" multiple required>
            <% 
            For Each role In roles
                roleId = Split(role, ",")(0)
                roleName = Split(role, ",")(1)
            %>
                <option value="<%= roleId %>" <%= IIf(IsInArray(roleId, selectedRoles), "selected", "") %>><%= roleName %></option>
            <% Next %>
        </select><br>

        <button type="submit">Add User</button>
    </form>

    <input type="button" name="btn_back" value="Back" onclick="history.back()" />
</body>
</html>

<%
' Helper function to check if value is in an array
Function IsInArray(value, arr)
    Dim i
    For i = 0 To UBound(arr)
        If arr(i) = value Then
            IsInArray = True
            Exit Function
        End If
    Next
    IsInArray = False
End Function
%>
