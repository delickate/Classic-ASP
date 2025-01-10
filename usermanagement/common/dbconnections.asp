<%
' SANI: Database Connections
Dim conn, host, db, user, pass, connStr

host = "localhost"
db = "sani_usermanagement"
user = "localadmin"
pass = "localadmin"

' Open the database connection
Set conn = Server.CreateObject("ADODB.Connection")
'conn.ConnectionString = "DRIVER={MySQL ODBC 9.1 Driver};SERVER=" & host & ";DATABASE=" & db & ";USER=" & user & ";PASSWORD=" & pass & ";"
'conn.Open
connStr = "Driver={MySQL ODBC 9.1 Unicode Driver};Server=localhost;Database=sani_usermanagement;User=localadmin;Password=localadmin;Option=3;"
Response.Write(connStr)
conn.Open connStr

' Enable session security headers
Response.AddHeader "Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self';"
Response.AddHeader "X-Frame-Options", "SAMEORIGIN"

' Enable session options for security
'Response.Cookies("ASPSESSIONID").HttpOnly = True
'Response.Cookies("ASPSESSIONID").Secure = True

' SANI: CSRF Token Generation
If IsEmpty(Session("csrf_token")) Or Len(Session("csrf_token")) = 0 Then
    Session("csrf_token") = GenerateCSRFToken()
End If

' Function to generate CSRF token
Function GenerateCSRFToken()
    Dim rng, i, token, chars
    Set rng = Server.CreateObject("MSXML2.XMLHTTP")
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    token = ""

    For i = 1 To 32
        token = token & Mid(chars, Int((Len(chars) * Rnd) + 1), 1)
    Next

    GenerateCSRFToken = token
    Set rng = Nothing
End Function

' Error Handling
On Error Resume Next
If Err.Number <> 0 Then
    Response.Write("Error Number: " & Err.Number & "<br>")
    Response.Write("Error Description: " & Err.Description & "<br>")
    Response.Write("Error Source: " & Err.Source & "<br>")
    Response.End()
End If
%>
