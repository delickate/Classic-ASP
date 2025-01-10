<%
' Include common files
<!--#include file="../common/dbconnections.asp" -->
<!--#include file="../common/middleware.asp" -->

' Get user ID from query string
Dim userId
userId = Request.QueryString("id")

' Validate user ID
If Not IsNumeric(userId) Then
    Response.Write("Invalid user ID.")
    Response.End
End If

userId = CLng(userId)

' Prevent deleting default users
Dim conn, rs, sql, isDefault
Set conn = Server.CreateObject("ADODB.Connection")
conn.Open "your_connection_string"

' Fetch user to check if it's default
sql = "SELECT is_default FROM users WHERE id = ?"
Set cmd = Server.CreateObject("ADODB.Command")
cmd.ActiveConnection = conn
cmd.CommandText = sql
cmd.CommandType = 1 ' adCmdText
cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , userId) ' adInteger, adParamInput
Set rs = cmd.Execute()

If rs.EOF Then
    Response.Write("User not found.")
    Response.End
End If

isDefault = rs("is_default")
rs.Close
Set rs = Nothing

If isDefault = 1 Then
    Response.Write("Cannot delete this user.")
    Response.End
End If

' Delete user roles
sql = "DELETE FROM users_roles WHERE user_id = ?"
Set cmd = Server.CreateObject("ADODB.Command")
cmd.ActiveConnection = conn
cmd.CommandText = sql
cmd.CommandType = 1 ' adCmdText
cmd.Parameters.Append cmd.CreateParameter("@userId", 3, 1, , userId) ' adInteger, adParamInput
cmd.Execute()

' Delete user
sql = "DELETE FROM users WHERE id = ?"
Set cmd = Server.CreateObject("ADODB.Command")
cmd.ActiveConnection = conn
cmd.CommandText = sql
cmd.CommandType = 1 ' adCmdText
cmd.Parameters.Append cmd.CreateParameter("@userId", 3, 1, , userId) ' adInteger, adParamInput
cmd.Execute()

' Redirect to users listing page
Response.Redirect("users_listing.asp")
Response.End

' Cleanup
conn.Close
Set conn = Nothing
Set cmd = Nothing
%>
