<%
' db_connection.asp

Function GetDBConnection()
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "DRIVER={MySQL ODBC 8.0 ANSI Driver};SERVER=localhost;DATABASE=userdb;USER=root;PASSWORD=your_password;"
    Set GetDBConnection = conn
End Function
%>
