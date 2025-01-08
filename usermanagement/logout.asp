<%
' Destroy session to log out
Session.Abandon()
Response.Redirect("login.asp")
%>
