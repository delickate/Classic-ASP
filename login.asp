<%
    On Error Resume Next ' Enable error handling
    Response.Buffer = True ' Optional: buffers response output

    ' Capture the last error and display it
    If Err.Number <> 0 Then
        Response.Write("Error Number: " & Err.Number & "<br>")
        Response.Write("Error Description: " & Err.Description & "<br>")
        Response.Write("Error Source: " & Err.Source & "<br>")
        Response.End() ' End processing
    End If
%>

<%
' Function to create a SHA-256 hash of a string
Function GetSHA256Hash(str)
    Dim objXML, objNode, hexStr, i
    Set objXML = Server.CreateObject("MSXML2.DOMDocument.6.0")
    Set objNode = objXML.createElement("temp")
    
    ' Create SHA-256 object and compute the hash
    objNode.dataType = "bin.hex"
    objNode.nodeTypedValue = CreateObject("System.Security.Cryptography.SHA256Managed").ComputeHash_2(StrConv(str, vbFromUnicode))
    
    ' Convert byte array to hex string
    hexStr = ""
    For i = 1 To LenB(objNode.nodeTypedValue)
        hexStr = hexStr & LCase(Right("00" & Hex(AscB(MidB(objNode.nodeTypedValue, i, 1))), 2))
    Next

    GetSHA256Hash = hexStr
    Set objNode = Nothing
    Set objXML = Nothing
End Function

' Initialize session variables
Session("loggedIn") = False
Dim conn, rs, email, password, query, hashedPassword

' Check if form is submitted
If Request.Form("submit") <> "" Then
    email = Request.Form("email")
    password = Request.Form("password")

    ' Hash the input password using SHA-256
    hashedPassword = GetSHA256Hash(password)

    ' Connect to MySQL Database
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "DRIVER={MySQL ODBC 8.0 ANSI Driver};SERVER=localhost;DATABASE=userdb;USER=root;PASSWORD=your_password;"

    ' Query the database for the user with this email
    query = "SELECT * FROM users WHERE email = '" & email & "'"
    Set rs = conn.Execute(query)

    ' Check if user exists and compare the hashed password
    If Not rs.EOF Then
        ' Compare the hashed passwords
        If rs("password") = hashedPassword Then
            Session("loggedIn") = True
            Session("userId") = rs("id")
            Session("userName") = rs("name")
            Response.Redirect("default.asp")
        Else
            Response.Write("Invalid credentials!")
        End If
    Else
        Response.Write("User not found!")
    End If

    ' Clean up
    rs.Close
    Set rs = Nothing
    conn.Close
    Set conn = Nothing
End If
%>

<html>
<head>
    <title>Login</title>
</head>
<body>
    <h2>Login</h2>
    <form method="post" action="login.asp">
        Email: <input type="text" name="email" /><br />
        Password: <input type="password" name="password" /><br />
        <input type="submit" name="submit" value="Login" />
    </form>
</body>
</html>