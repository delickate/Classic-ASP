<!--#include file="../common/dbconnections.asp"-->
<!--#include file="../common/middleware.asp"-->
<!--#include file="../common/helpers.asp"-->

<%
Dim limit, page, offset, sql, rs, totalRs, roles, totalRoles, totalPages
limit = 10
page = 1
If Len(Request.QueryString("page")) > 0 Then
    page = CInt(Request.QueryString("page"))
End If
offset = (page - 1) * limit

' Fetch roles with pagination
sql = "SELECT * FROM roles LIMIT " & limit & " OFFSET " & offset
Set rs = conn.Execute(sql)
Set roles = rs.GetRows()

' Fetch total roles count
sql = "SELECT COUNT(*) AS total FROM roles"
Set totalRs = conn.Execute(sql)
totalRoles = totalRs("total")
totalPages = Int(totalRoles / limit)
If totalRoles Mod limit > 0 Then
    totalPages = totalPages + 1
End If

' Cleanup
totalRs.Close
Set totalRs = Nothing
rs.Close
Set rs = Nothing
%>

<!DOCTYPE html>
<html>
<head>
    <title>Role Listings</title>
</head>
<body>
    <h1>Role Listings</h1>
    <!-- Include navigation -->
    <!--#include file="../common/navigations.asp"-->

    <% If HasAddRight(currentUserId, 4, conn) Then %>
    <p align="right"><a href="<%= BaseUrl() %>/roles/roles_add.asp">Add</a></p>
    <% End If %>

    <table border="1" width="100%">
        <thead>
            <tr>
                <th>Name</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% 
            If Not IsEmpty(roles) Then
                Dim i
                For i = LBound(roles, 2) To UBound(roles, 2)
            %>
                <tr>
                    <td><%= roles(1, i) %></td>
                    <td>
                        <a href="<%= BaseUrl() %>/roles/roles_detail.asp?id=<%= roles(0, i) %>">View</a>
                        <% If roles(2, i) = 0 Then ' Assuming 'is_default' is at index 2 in the recordset %>
                            <% If HasEditRight(currentUserId, 4, conn) Then %>
                            <a href="<%= BaseUrl() %>/roles/roles_edit.asp?id=<%= roles(0, i) %>">Edit</a>
                            <% End If %>
                            <% If HasDeleteRight(currentUserId, 4, conn) Then %>
                            <a href="<%= BaseUrl() %>/roles/roles_delete.asp?id=<%= roles(0, i) %>" onclick="return confirm('Are you sure you want to delete this role?');">Delete</a>
                            <% End If %>
                        <% End If %>
                    </td>
                </tr>
            <% 
                Next
            End If
            %>
        </tbody>
    </table>

    <div>
        <% 
        Dim j
        For j = 1 To totalPages
        %>
            <a href="?page=<%= j %>"><%= j %></a>
        <% 
        Next
        %>
    </div>
</body>
</html>
