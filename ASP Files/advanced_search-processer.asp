<% Response.ContentType="text/html"

Response.Charset="UTF-8"

Session.CodePage=65001 %>

<!--#include file="globalvars.asp"-->

<%

    'If "subcatSelect" is not present in the query string, it means the main Search button was pressed, and results should be passed to the Results page
    If ("Search" = Request.QueryString("target")) Then
        Response.Redirect "results.asp?" & Request.QueryString
    End If

	' Define an array of XSL files and one for the resulting output
	' Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Dim xslArray(), xslOutputArray(), numberOfParts
	numberOfParts = 2
	ReDim xslArray(numberOfParts-1)
	ReDim xslOutputArray(numberOfParts-1)
	xslArray(0) = "advanced_search_head.xsl"
	xslArray(1) = "advanced_search_body.xsl"
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	' End section

' Create xml doc object
    Set xmlDoc = makeDoc(xmlDoc)
    xmlDoc.async = false
    xmlDoc.preserveWhiteSpace = True
    xmlDoc.setProperty "ServerHTTPRequest", true
    
    vocabPath = Application.Value("root") & "/sru/xml/default?apikey=" & Application.Value("apikey") & "&version=1.1&operation=searchRetrieve&query=*&maximumRecords=1" _
             & "&x-kint-facet=true" _
             & "&x-kint-facet.field=dc.subject" _
             & "&x-kint-facet.field=referral_criteria_s" _
             & "&x-kint-facet.field=mode_of_access_s" _
             & "&x-kint-facet.field=language_spoken_s" _
             & "&x-kint-facet.mincount=1"

    xmlDoc.loadXML(readFile(vocabPath))
    
' Check that the supposed record has a document element (ie the record exists)
	If Not (xmlDoc.documentElement Is Nothing) Then

        Set rootElement = xmlDoc.documentElement
        
        ' Retrieve all query string elements to populate the form
	    Set echo = xmlDoc.createElement("echoedData")
	    Set queryString = xmlDoc.createElement("queryString")
        For Each thing In Request.QueryString
            Set thingAtt = xmlDoc.createAttribute(thing)
            thingAtt.text = Request.QueryString(thing)
            queryString.setAttributeNode thingAtt
        Next
	    xmlDoc.documentElement.insertBefore echo, null
	    echo.appendChild(queryString)
        
    ' Create dictionary for controlled list data
        Dim listItems(3)
        listItems(0) = "fullCatsList"
        listItems(1) = "referralList"
        listItems(2) = "accessChannelsList"
        listItems(3) = "langList"
    ' Load controlled list data to construct lists of filters
    ' Create a node in the original doc to hold list data
        Set vocabData = xmlDoc.createElement("controlledListData")
    ' Load the vocabulary into a new document
        For i=0 to 3
            Set vocabDoc = makeDoc(vocabDoc)
            vocabDoc.async = false
            vocabDoc.preserveWhiteSpace = True
            vocabDoc.setProperty "ServerHTTPRequest", true
            ' Load the converted text into the xmlDoc
            vocabDoc.loadXML(Application.Value(listItems(i)))
            If Not (vocabDoc.documentElement Is Nothing) Then
                Set listData = xmlDoc.createElement(listItems(i))
                Set vocabTree = vocabDoc.documentElement
                listData.appendChild(vocabTree.cloneNode(true))
                vocabData.appendChild(listData)
            End If
        Next
        rootElement.appendChild(vocabData)
	    rootElement.appendChild(xmlDoc.CreateTextNode(vbCrLf))
    Else
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

	adoOutput.position = 0
	' Write the output to the page buffer
	xslOutputArray(i) = adoOutput.Read
	' Close up
	adoOutput.Close()
Next
%>