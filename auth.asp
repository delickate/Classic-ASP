<%
' auth.asp

' Check if user is logged in
Function IsLoggedIn()
    If Session("loggedIn") <> True Then
        Response.Redirect("login.asp")
    End If
End Function

' Log user in
Function LoginUser(email, password)
    Dim conn, rs, query, hashedPassword

    ' Hash the input password using SHA-256
    hashedPassword = GetSHA256Hash(password)

    ' Connect to MySQL Database
    Set conn = GetDBConnection()

    ' Query the database for the user with the provided email
    query = "SELECT * FROM users WHERE email = '" & email & "'"
    Set rs = conn.Execute(query)

    ' Check if user exists and compare the hashed password
    If Not rs.EOF Then
        If rs("password") = hashedPassword Then
            ' Set session variables
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
End Function

' Log user out
Sub LogoutUser()
    ' Destroy session to log out
    Session.Abandon()
    Response.Redirect("login.asp")
End Sub
%>
