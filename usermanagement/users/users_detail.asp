<%
' Include common files
<!--#include file="../common/dbconnections.asp" -->
<!--#include file="../common/middleware.asp" -->
<!--#include file="../common/helpers.asp" -->

' Get user ID from query string
Dim id
id = Request.QueryString("id")

If IsNumeric(id) Then
    id = CLng(id)
Else
    Response.Write("Invalid user ID.")
    Response.End
End If

' Fetch user from database
Dim conn, rs, sql
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "your_connection_string"

sql = "SELECT * FROM users WHERE id = ?"
Set rs = Server.CreateObject("ADODB.Recordset")
Set cmd = Server.CreateObject("ADODB.Command")

cmd.ActiveConnection = conn
cmd.CommandText = sql
cmd.CommandType = 1 ' adCmdText
cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , id) ' adInteger, adParamInput
Set rs = cmd.Execute()

If rs.EOF Then
    Response.Write("User not found.")
    Response.End
End If

Dim name, email, phone, status, picture
name = rs("name")
email = rs("email")
phone = rs("phone")
status = rs("status")
picture = rs("picture")

rs.Close
Set rs = Nothing
conn.Close
Set conn = Nothing
%>

<!DOCTYPE html>
<html>
<head>
    <title>User Details</title>
</head>
<body>
    <!--#include file="../common/navigations.asp" -->

    <h1>User Details</h1>
    <p><strong>Name:</strong> <%= Server.HTMLEncode(name) %></p>
    <p><strong>Email:</strong> <%= Server.HTMLEncode(email) %></p>
    <p><strong>Phone:</strong> <%= Server.HTMLEncode(phone) %></p>
    <p><strong>Status:</strong> <%= IIf(status, "Active", "Inactive") %></p>
    <p><strong>Profile Picture:</strong><br>
        <% If Not IsNull(picture) And picture <> "" Then %>
            <img src="<%= IMAGE_URL & Server.HTMLEncode(picture) %>" alt="Profile Picture" width="100">
        <% Else %>
            No profile picture available.
        <% End If %>
    </p>

    <input type="button" name="btn_back" value="Back" onclick="history.back()" />
</body>
</html>
