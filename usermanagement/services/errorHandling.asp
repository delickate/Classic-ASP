<%
On Error Resume Next ' Enable error handling

' Display the last error
If Err.Number <> 0 Then
    Response.Write("Error Number: " & Err.Number & "<br>")
    Response.Write("Error Description: " & Err.Description & "<br>")
    Response.Write("Error Source: " & Err.Source & "<br>")
    Response.End() ' End processing
End If
%>
