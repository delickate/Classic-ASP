<%
' Define constants for base URL
Const BASE_URL = "http://localhost:98/ASP/ASP-projects/usermanagement"

' Define a variable for IMAGE_URL (since Const cannot concatenate)
Dim IMAGE_URL
IMAGE_URL = BASE_URL & "/uploads/images/profile/"

' SANI: Check if user session exists
If IsEmpty(Session("userId")) Or Len(Session("userId")) = 0 Then
    Response.Redirect "login.asp"
    Response.End
End If
%>
