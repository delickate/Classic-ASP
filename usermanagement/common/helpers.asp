<%
' SANI: Create folders if not exist
Sub CreateFolderIfNotExists(path)
    Dim fso
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(path) Then
        fso.CreateFolder(path)
    End If
    Set fso = Nothing
End Sub

' SANI: Web portal base URL
Function BaseUrl(path)
    Dim protocol, host, scriptDir
    If IsEmpty(path) Then path = "" ' Handle optional parameter
    path = Trim(path)
    protocol = "http" ' Default to HTTP
    If Request.ServerVariables("HTTPS") = "on" Then
        protocol = "https"
    End If
    host = Request.ServerVariables("HTTP_HOST")
    scriptDir = Replace(Request.ServerVariables("SCRIPT_NAME"), Request.ServerVariables("SCRIPT_NAME"), "/")
    BaseUrl = protocol & "://" & host & scriptDir & path
End Function


' User ID from session
Dim userId, currentUserId
userId = Session("userId")
currentUserId = userId

' Fetch user's roles
Function GetUserRoles(userId, conn)
    Dim sql, rs, roles
    sql = "SELECT role_id FROM users_roles WHERE user_id = " & userId
    Set rs = conn.Execute(sql)
    roles = ""
    Do While Not rs.EOF
        If roles <> "" Then roles = roles & ","
        roles = roles & rs("role_id")
        rs.MoveNext
    Loop
    rs.Close
    Set rs = Nothing
    GetUserRoles = roles
End Function

' Fetch accessible modules
Function GetAccessibleModules(userRoles, conn)
    Dim sql, rs, modules
    sql = "SELECT DISTINCT m.name, m.url " & _
          "FROM modules m " & _
          "JOIN roles_modules_permissions rmp ON m.id = rmp.module_id " & _
          "WHERE rmp.role_id IN (" & userRoles & ") AND m.status = 1"
    Set rs = conn.Execute(sql)
    modules = "<ul>"
    Do While Not rs.EOF
        modules = modules & "<li><a href='" & rs("url") & "'>" & rs("name") & "</a></li>"
        rs.MoveNext
    Loop
    modules = modules & "</ul>"
    rs.Close
    Set rs = Nothing
    GetAccessibleModules = modules
End Function

' Check if a user has the right to Add
Function HasAddRight(userId, moduleId, conn)
    HasAddRight = HasRight(userId, moduleId, "Add", conn)
End Function

' Check if a user has the right to Edit
Function HasEditRight(userId, moduleId, conn)
    HasEditRight = HasRight(userId, moduleId, "Edit", conn)
End Function

' Check if a user has the right to Delete
Function HasDeleteRight(userId, moduleId, conn)
    HasDeleteRight = HasRight(userId, moduleId, "Delete", conn)
End Function

' Generic function to check a specific right
Function HasRight(userId, moduleId, rightName, conn)
    Dim sql, rs, result
    sql = "SELECT COUNT(*) AS cnt " & _
          "FROM roles_modules_permissions_rights pmr " & _
          "INNER JOIN roles_modules_permissions p ON pmr.roles_modules_permissions_id = p.id " & _
          "INNER JOIN rights r ON pmr.rights_id = r.id " & _
          "INNER JOIN users_roles ur ON p.role_id = ur.role_id " & _
          "WHERE ur.user_id = " & userId & " AND p.module_id = " & moduleId & " AND r.name = '" & rightName & "'"
    Set rs = conn.Execute(sql)
    result = rs("cnt") > 0
    rs.Close
    Set rs = Nothing
    HasRight = result
End Function

Function GetUserNavigation(userId)
    Dim sql, rs, navHtml
    navHtml = ""
    
    ' SQL query to fetch the modules
    sql = "SELECT m.name, m.url " & _
          "FROM modules m " & _
          "INNER JOIN roles_modules_permissions rmp ON m.id = rmp.module_id " & _
          "INNER JOIN users_roles ur ON rmp.role_id = ur.role_id " & _
          "WHERE ur.user_id = " & userId & " AND m.status = 1 " & _
          "ORDER BY m.sortid ASC"

    ' Execute the query
    Set rs = conn.Execute(sql)

    ' Build the navigation links
    Do While Not rs.EOF
        navHtml = navHtml & "<li><a href='" & base_url(rs("url")) & "'>" & rs("name") & "</a></li>"
        rs.MoveNext
    Loop

    ' Clean up
    rs.Close
    Set rs = Nothing

    GetUserNavigation = navHtml
End Function

%>
