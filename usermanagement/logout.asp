<%
' End the session and redirect to the login page

' Clear all session variables
Session.Abandon()

' Redirect to login page
Response.Redirect("login.asp")
%>
