<%

    Function readFile(url)
    
    ' Create an XMLHTTP object to read the XML of the list as text
        Dim xmlHTTP : Set xmlHTTP = CreateObject("MSXML2.ServerXMLHTTP")
        xmlHTTP.Open "GET", url, False
        xmlHTTP.Send ' send it (to the web, wait for result)
    ' save the response
        sHTMLPage = xmlHTTP.responseText

    ' Create a Stream object to convert this text to ASCII
        Set TextStream = CreateObject("ADODB.Stream")
        TextStream.Open()
        TextStream.CharSet = "ASCII"
        TextStream.WriteText sHTMLPage
        TextStream.Position = 0
        newText = TextStream.ReadText
        TextStream.Close()
        
    ' Return the text
        readFile = newText
        
    End Function
    
    
    Function makeDoc(docName)
    
        On Error Resume Next
        Set docName = Server.CreateObject("xMSXML2.DOMDocument.6.0")
        If (0 <> Err.number) Then
            Set docName = Server.CreateObject("MSXML2.DOMDocument.3.0")
        End If
    
        Set makeDoc = docName
    
    End Function
    
%>