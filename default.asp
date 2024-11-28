<%
' Check if user is logged in
If Session("loggedIn") <> True Then
    Response.Redirect("login.asp")
End If

' Retrieve user details from the session
Dim userId, userName
userId = Session("userId")
userName = Session("userName")
%>

<html>
<head>
    <title>Dashboard</title>
</head>
<body>
    <h2>Welcome, <%= userName %></h2>
    <p>Here is your dashboard page. You are logged in!</p>
    <p><a href="logout.asp">Logout</a></p>
</body>
</html>
