<%
' password_utils.asp

Function GetSHA256Hash(str)
    Dim objXML, objNode, hexStr, i
    Set objXML = Server.CreateObject("MSXML2.DOMDocument.6.0")
    Set objNode = objXML.createElement("temp")
    
    ' Create SHA-256 object and compute the hash
    objNode.dataType = "bin.hex"
    objNode.nodeTypedValue = CreateObject("System.Security.Cryptography.SHA256Managed").ComputeHash_2(StrConv(str, vbFromUnicode))
    
    ' Convert byte array to hex string
    hexStr = ""
    For i = 1 To LenB(objNode.nodeTypedValue)
        hexStr = hexStr & LCase(Right("00" & Hex(AscB(MidB(objNode.nodeTypedValue, i, 1))), 2))
    Next

    GetSHA256Hash = hexStr
    Set objNode = Nothing
    Set objXML = Nothing
End Function
%>
