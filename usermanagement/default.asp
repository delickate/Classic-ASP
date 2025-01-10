<!--#include file="common/dbconnections.asp"-->
<!--#include file="common/middleware.asp"-->
<!--#include file="common/helpers.asp"-->

<%
' Ensure the user is logged in
If Session("loggedIn") <> True Then
    Response.Redirect("login.asp")
End If
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
</head>
<body>
    <h1>Welcome to the Dashboard</h1>
    <!-- Include the navigation menu -->
    <!--#include file="common/navigations.asp"-->

    <p>Body</p>
</body>
</html>
