<!--#include file="../common/dbconnections.asp"-->
<!--#include file="../common/middleware.asp"-->
<!--#include file="../common/helpers.asp"-->

<%
Dim roleId, sql, conn, errMsg

' Check if role ID is provided
If Not IsNumeric(Request.QueryString("id")) Then
    Response.Redirect "roles_listing.asp"
    Response.End
End If

roleId = CInt(Request.QueryString("id"))

' Initialize variables
errMsg = ""

' Begin transaction
conn.BeginTrans

On Error Resume Next
    ' Delete rights associated with this role
    sql = "DELETE FROM roles_modules_permissions_rights " & _
          "WHERE roles_modules_permissions_id IN (" & _
          "SELECT id FROM roles_modules_permissions WHERE role_id = " & roleId & ")"
    conn.Execute sql

    ' Check for errors
    If Err.Number <> 0 Then
        errMsg = "Error deleting rights: " & Err.Description
        conn.RollbackTrans
        On Error Goto 0
        Response.Redirect "roles_listing.asp?error=1"
        Response.End
    End If

    ' Delete permissions associated with this role
    sql = "DELETE FROM roles_modules_permissions WHERE role_id = " & roleId
    conn.Execute sql

    ' Check for errors
    If Err.Number <> 0 Then
        errMsg = "Error deleting permissions: " & Err.Description
        conn.RollbackTrans
        On Error Goto 0
        Response.Redirect "roles_listing.asp?error=1"
        Response.End
    End If

    ' Delete the role itself
    sql = "DELETE FROM roles WHERE id = " & roleId
    conn.Execute sql

    ' Check for errors
    If Err.Number <> 0 Then
        errMsg = "Error deleting role: " & Err.Description
        conn.RollbackTrans
        On Error Goto 0
        Response.Redirect "roles_listing.asp?error=1"
        Response.End
    End If

    ' Commit transaction
    conn.CommitTrans
    On Error Goto 0

    ' Redirect to roles listing with success message
    Response.Redirect "roles_listing.asp?success=1"
    Response.End
%>

<%
' Error logging if needed (optional)
If errMsg <> "" Then
    Call WriteLog("Error deleting role: " & errMsg)
End If

' Utility function for logging errors
Sub WriteLog(message)
    Dim fs, f, logFilePath
    logFilePath = Server.MapPath("../logs/error_log.txt")
    Set fs = Server.CreateObject("Scripting.FileSystemObject")
    If Not fs.FileExists(logFilePath) Then
        Set f = fs.CreateTextFile(logFilePath, True)
    Else
        Set f = fs.OpenTextFile(logFilePath, 8)
    End If
    f.WriteLine Now() & " - " & message
    f.Close
    Set f = Nothing
    Set fs = Nothing
End Sub
%>
