<!--#include file="globalvars.asp"-->

<%
	
	' Define an array of XSL files and one for the resulting output
	' Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	' You may find it easier to completely remove these and define them in the containing server-side script (as with the section above)
	' (For if you are integrating templates in various places in a page - ignore these lines if you are using the templates as-is
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Dim xslArray(), xslOutputArray(), numberOfParts
	numberOfParts = 2
	ReDim xslArray(numberOfParts-1)
	ReDim xslOutputArray(numberOfParts-1)
	xslArray(0) = "search_head.xsl"
	xslArray(1) = "search_body.xsl"
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	' End section
	
' Create xml doc object
Set xmlDoc = makeDoc(xmlDoc)

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

	adoOutput.position = 0
	' Write the output to the page buffer
	xslOutputArray(i) = adoOutput.Read
	' Close up
	adoOutput.Close()
Next
%>