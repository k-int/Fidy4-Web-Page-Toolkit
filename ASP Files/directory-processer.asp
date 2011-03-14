<% Response.ContentType="text/html"

Response.Charset="UTF-8"

Session.CodePage=65001 %>

<!--#include file="globalvars.asp"-->

<%
	
' Define an array of XSL files and one for the resulting output
' Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    Dim xslArray(), xslOutputArray(), numberOfParts
    numberOfParts = 2
    ReDim xslArray(numberOfParts-1)
    ReDim xslOutputArray(numberOfParts-1)
    xslArray(0) = "directory_head.xsl"
    xslArray(1) = "directory_body.xsl"
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' End section

' Create xml doc object
    Set xmlDoc = makeDoc(xmlDoc)
    xmlDoc.async = false
    xmlDoc.preserveWhiteSpace = True
    xmlDoc.setProperty "ServerHTTPRequest", true

' Load the converted text into the xmlDoc
    xmlDoc.loadXML(Application.Value("fullCatsList"))
    
' Check that the supposed record has a document element (ie the record exists)
	If (xmlDoc.documentElement Is Nothing) Then
		Response.Redirect Server.MapPath(Application.Value("xslRootPath") & Application.Value("four0fourPage"))
	End If


' Save and reload the xml doc ( FOR BUG TRACKING - MAKES ALL CHANGES VISIBLE )
' xmlDoc.Save("C:\temp\newdoc.xml")
' xmlDoc.Load("C:\temp\newdoc.xml")

' For each item in the xslArray, perform a transform on the XML doc using that item
    For i=0 to numberOfParts-1
	    ' Create xsl transform from xsl file
	    Set xslDoc = makeDoc(xslDoc)
	    xslDoc.resolveExternals = true
	    xslDoc.setProperty "AllowDocumentFunction",true
	    xslDoc.async = false
	    xslDoc.preserveWhiteSpace = True
	    xslDoc.load(Server.MapPath(Application.Value("xslRootPath") & xslArray(i)))

	    ' Create and open an ADO text stream
	    Set adoOutput = Server.CreateObject("ADODB.Stream")
	    adoOutput.Open()
	    adoOutput.Type = 1

	    ' Combine the docs and the ADO stream to create output
	    xmlDoc.TransformNodeToObject xslDoc, adoOutput

	    adoOutput.Position = 0
	    ' Write the output to relevant array element
	    xslOutputArray(i) = adoOutput.Read
	    ' Close up
	    adoOutput.Close()
    Next
%>