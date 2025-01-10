<!--#include file="../common/dbconnections.asp"-->
<!--#include file="../common/middleware.asp"-->
<!--#include file="../common/helpers.asp"-->

<%
Dim limit, page, offset, sql, rs, totalUsers, totalPages, users, currentPage, hasAddRight, hasEditRight, hasDeleteRight
limit = 10
page = IIf(IsNumeric(Request.QueryString("page")), CInt(Request.QueryString("page")), 1)
offset = (page - 1) * limit

' Fetch users with pagination
sql = "SELECT u.*, r.name as role_name FROM users as u " & _
      "INNER JOIN users_roles as ur ON (u.id = ur.user_id) " & _
      "INNER JOIN roles r ON (ur.role_id = r.id) " & _
      "LIMIT " & limit & " OFFSET " & offset
Set rs = conn.Execute(sql)
users = GetRecordSetArray(rs)

' Fetch total users count
sql = "SELECT COUNT(*) as total FROM users as u " & _
      "INNER JOIN users_roles as ur ON (u.id = ur.user_id) " & _
      "INNER JOIN roles r ON (ur.role_id = r.id)"
Set rs = conn.Execute(sql)
totalUsers = rs("total")
totalPages = Ceiling(totalUsers / limit)

' Helper functions
Function Ceiling(value)
    If (value Mod 1) = 0 Then
        Ceiling = value
    Else
        Ceiling = Int(value) + 1
    End If
End Function

Function GetRecordSetArray(rs)
    Dim arr, i
    arr = Array()
    i = 0
    While Not rs.EOF
        ReDim Preserve arr(i)
        arr(i) = rs.Fields
        i = i + 1
        rs.MoveNext
    Wend
    rs.Close
    GetRecordSetArray = arr
End Function

%>

<!DOCTYPE html>
<html>
<head>
    <title>User Listings</title>
</head>
<body>
    <h1>User Listings</h1>
    <!-- Navigation -->
    <!--#include file="../common/navigations.asp"-->

    <% If hasAddRight(currentUserId, 3) Then %>
    <p align="right"><a href="<%= BASE_URL & "/users/users_add.asp" %>">Add</a></p>
    <% End If %>

    <table border="1" width="100%">
        <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Roles</th>
                <th>Image</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% If IsArray(users) Then %>
                <% Dim user, isDefault %>
                <% For Each user In users %>
                    <tr>
                        <td><%= user("name") %></td>
                        <td><%= user("email") %></td>
                        <td><%= user("phone") %></td>
                        <td><%= user("role_name") %></td>
                        <td><img src="<%= IMAGE_URL & user("picture") %>" width="100" /></td>
                        <td>
                            <a href="<%= BASE_URL & "/users/users_detail.asp?id=" & user("id") %>">View</a>
                            <% isDefault = user("is_default") %>
                            <% If isDefault = 0 Then %>
                                <% If hasEditRight(currentUserId, 3) Then %>
                                <a href="<%= BASE_URL & "/users/users_edit.asp?id=" & user("id") %>">Edit</a>
                                <% End If %>

                                <% If hasDeleteRight(currentUserId, 3) Then %>
                                <a href="<%= BASE_URL & "/users/users_delete.asp?id=" & user("id") %>" onclick="return confirm('Are you sure you want to delete this user?');">Delete</a>
                                <% End If %>
                            <% End If %>
                        </td>
                    </tr>
                <% Next %>
            <% Else %>
                <tr>
                    <td colspan="6">No users found.</td>
                </tr>
            <% End If %>
        </tbody>
    </table>

    <div>
        <% For currentPage = 1 To totalPages %>
            <a href="?page=<%= currentPage %>"><%= currentPage %></a>
        <% Next %>
    </div>
</body>
</html>
