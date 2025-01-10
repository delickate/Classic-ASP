<%
If Session("loggedIn") = True Then
    Dim navHtml
    navHtml = GetUserNavigation(Session("userId"))
    Response.Write(navHtml)
End If
%>
