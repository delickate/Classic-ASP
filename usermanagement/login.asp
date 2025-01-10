<%
On Error Resume Next ' Enable error handling

If Err.Number <> 0 Then
    Response.Write("Error Number: " & Err.Number & "<br>")
    Response.Write("Error Description: " & Err.Description & "<br>")
    Response.Write("Error Source: " & Err.Source & "<br>")
    Response.End() ' Stop further execution
End If
%>

<%
' Include necessary files
' Assume dbconnections.asp initializes the database connection and session
' helpers.asp contains utility functions like CSRF token generation
<!--#include file="dbconnections.asp"-->
<!--#include file="helpers.asp"-->


' Initialize variables
Dim email, password, sql, rs, errorMsg

' Debugging output
'Response.Write("Form CSRF Token: " & Request.Form("csrf_token") & "<br>")
'Response.Write("Session CSRF Token: " & Session("csrf_token") & "<br>")


' Check if the request method is POST
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Response.Write("<br>Form:" & Request.Form("csrf_token"))
    Response.Write("<br>Sessions:" & Session("csrf_token"))
    ' Validate CSRF token
    If Request.Form("csrf_token") <> Session("csrf_token") Then
        Response.Write("CSRF token validation failed.")
        Response.End()
    End If

    ' Sanitize inputs
    email = Replace(Request.Form("email"), "'", "''")
    password = Replace(Request.Form("password"), "'", "''")
    password = GetMD5Hash(password) ' Replace with equivalent MD5 hash function

    ' SQL query to verify the user
    sql = "SELECT * FROM users WHERE email = '" & email & "' AND password = '" & password & "' AND status = 1"
    Set rs = conn.Execute(sql)

    ' Check if the user exists
    If Not rs.EOF Then
        ' User authenticated
        Session("user_id") = rs("id")
        Response.Redirect("default.asp")
    Else
        errorMsg = "Invalid credentials."
    End If

    ' Clean up
    rs.Close
    Set rs = Nothing
Else
    'Response.Write("Form not submitted.<br>")
    'Response.Write("REQUEST_METHOD: " & Request.ServerVariables("REQUEST_METHOD") & "<br>")

    ' Generate CSRF token if not already set
    'If IsEmpty(Session("csrf_token")) Then
    '    Session("csrf_token") = Replace(CreateObject("Scripting.FileSystemObject").GetTempName(), ".", "")
    'End If
End If


%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
</head>
<body>
    <form method="POST" action="login.asp">
        <input type="hidden" name="csrf_token" value="<%= Session("csrf_token") %>">
        <label for="email">Email:</label>
        <input type="email" name="email" id="email" required><br>

        <label for="password">Password:</label>
        <input type="password" name="password" id="password" required><br>

        <button type="submit">Login</button>
    </form>
    <% If Len(errorMsg) > 0 Then %>
        <p><%= errorMsg %></p>
    <% End If %>
</body>
</html>
