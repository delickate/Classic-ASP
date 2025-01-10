<%
' Assume `GetUserNavigation` returns an HTML string with navigation links
' and `base_url` is a function defined in helpers.asp to generate the base URL.

Dim modulesHtml, logoutUrl

' Get the modules HTML for the logged-in user
modulesHtml = GetUserNavigation(Session("user_id"))

' Generate the logout URL
logoutUrl = base_url("logout.asp")
%>

<ul>
    <%= modulesHtml %>
</ul>
<a href="<%= logoutUrl %>">Logout</a>
<br /><br />
