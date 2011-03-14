<!--#include file="globalvars.asp"-->

<%

	' Define and assign values to relevant variables
	' Comment out (or delete) these lines if you are using included method, and define these variables in your conatining ASP page
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Dim absRecordID, absRecordType, abView, absChosenCategory, absDisplayType, absFullQuery
	absFullQuery = Request.QueryString
	absRecordType = Request.QueryString("recordType")
	absRecordID = Request.QueryString("recordID")
	
	' R08 tab view tool start
	absView = Request.QueryString("view")
	' R08 tab view tool end
	
    ' F10 See Also tool start
	absChosenCategory = Request.QueryString("category")
    ' F10 See Also tool end

	absDisplayType = Request.QueryString("displayType")
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	' End section
	
	
	' Define two arrays of XSL files (one for ECD records, one for FSD records) and one for the resulting output
	' Each section will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	' You may find it easier to completely remove these and define them in the containing server-side script (as with the section above)
	' (only if you are integrating templates in various places in a page - ignore these lines if you are using the templates as-is)
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Dim xslECDArray(), xslFSDArray(), xslOutputArray(), numberOfParts
	numberOfParts = 2
	ReDim xslECDArray(numberOfParts-1)
	ReDim xslFSDArray(numberOfParts-1)
	ReDim xslOutputArray(numberOfParts-1)
	xslECDArray(0) = "details-ecd_head.xsl"
	xslFSDArray(0) = "details-fsd_head.xsl"
	xslECDArray(1) = "details-ecd_body.xsl"
	xslFSDArray(1) = "details-fsd_body.xsl"
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	' End section



If "ECD" = absRecordType Then
	query = "/dpp/resource/" & absRecordID & "/stream/ECD?apikey=" & Application.Value("apikey")
Else If "FSD" = absRecordType Then
	query = "/dpp/resource/" & absRecordID & "/stream/FSD?apikey=" & Application.Value("apikey")
Else
	Response.Redirect Server.MapPath(Application.Value("xslRootPath") & Application.Value("four0fourPage"))
End If
End If


' Create xml doc object
Set xmlDoc = makeDoc(xmlDoc)
xmlDoc.async = false
xmlDoc.preserveWhiteSpace = True
xmlDoc.setProperty "ServerHTTPRequest", true

fetchRecord = Application.Value("root") & query

xmlDoc.load(fetchRecord)



' Check that the supposed record has a document element (ie the record exists)
	If Not (xmlDoc.documentElement Is Nothing) Then
	
		' Add nodes for readback of search parameters, ordering etc
		
		    Set echo = xmlDoc.createElement("echoedData")
    		
		    ' Create and populate the nodes
		    Set queryString = xmlDoc.createElement("queryString")
		    queryString.text = absFullQuery
		    
		    Set recordID = xmlDoc.createAttribute("recordID")
			recordID.text = "5"
		    If("" <> absRecordID) Then
			    recordID.text = absRecordID
		    End If
		    queryString.setAttributeNode recordID
		    
		    Set recordType = xmlDoc.createAttribute("recordType")
		    recordType.text = absRecordType
		    queryString.setAttributeNode recordType
		    
		    ' R08 tab view tool start
		    Set view = xmlDoc.createAttribute("view")
			view.text = "1"
		    If("" <> absView) Then
			    view.text = absView
		    End If
		    queryString.setAttributeNode view
		    ' R08 tab view tool end
		    
		    Set displayType = xmlDoc.createElement("displayType")
		    displayType.text = absDisplayType
    		
		    ' add data to the xml
		    xmlDoc.documentElement.insertBefore echo, null
		    echo.appendChild(xmlDoc.CreateTextNode(vbCrLf&vbTab))
		    echo.appendChild(queryString)
		    echo.appendChild(xmlDoc.CreateTextNode(vbCrLf&vbTab))
		    echo.appendChild(displayType)
		    echo.appendChild(xmlDoc.CreateTextNode(vbCrLf&vbTab))
			
		' End node-setting
		
		' Load the attribution XML and attach to the output
		Dim sruAttributionQuery
		sruAttributionQuery = Application.Value("root") + "/sru/xml/default?version=1.2&operation=searchRetrieve&apikey=" + Application.Value("apikey") + "&maximumRecords=1&startRecord=1&query=InternalId=" + absRecordId
	
		' Load the attribution data into a new XML document
        Set attributionDoc = makeDoc(attributionDoc)
        attributionDoc.async = false
        attributionDoc.preserveWhiteSpace = True
        attributionDoc.setProperty "ServerHTTPRequest", true
        ' Load the XML into the xmlDoc
        attributionDoc.load(sruAttributionQuery)
        
	    ' Create a node in the original doc to hold attribution data
        Set attributionData = xmlDoc.createElement("attributionData")
        If Not (attributionDoc.documentElement Is Nothing) Then
            ' Create a node in the original doc to hold data
	        Set attributionDataList = xmlDoc.createElement("attributionDataList")
	        		
	        ' add data
            Set attributionTree = attributionDoc.documentElement
            attributionDataList.appendChild(attributionTree.cloneNode(true))
            attributionData.appendChild(attributionDataList)
        End If
		xmlDoc.documentElement.appendChild(attributionData)
				
		' Load the category list (to calculate parent categories) into a new XML document
        Set vocabDoc = makeDoc(vocabDoc)
        vocabDoc.async = false
        vocabDoc.preserveWhiteSpace = True
        vocabDoc.setProperty "ServerHTTPRequest", true
        ' Load the converted text into the xmlDoc
        vocabDoc.loadXML(Application.Value("fullCatsList"))
        
	    ' Create a node in the original doc to hold list data
        Set vocabData = xmlDoc.createElement("controlledListData")
        If Not (vocabDoc.documentElement Is Nothing) Then
            
	        ' Create a node in the original doc to hold data
	        Set listData = xmlDoc.createElement("catsList")
	        		
	        ' add data
            Set vocabTree = vocabDoc.documentElement
            listData.appendChild(vocabTree.cloneNode(true))
            vocabData.appendChild(listData)
        End If
		xmlDoc.documentElement.appendChild(vocabData)
			
		' Obtain the geocoded location data from the SOLR record
		
		    ' Load the solr result (which contains lant/lng data) into a new XML document
		    Dim solrQuery, lat, lng
		    solrQuery = "/dpp/resource/" + absRecordID + "/stream/solr?apikey=" & Application.Value("apikey")
            Set locDoc = makeDoc(locDoc)
            locDoc.async = false
            locDoc.setProperty "ServerHTTPRequest", true
            locDoc.load(Application.Value("root") + solrQuery)
		    Set list = locDoc.getElementsByTagName("field")
    		
		    ' Create the nodes
		    Set authority = xmlDoc.createElement("authority")
		    Set homebase = xmlDoc.createElement("centrePoint")
		    Set homebaseCoordsLat = xmlDoc.createAttribute("lat")
		    Set homebaseCoordsLng = xmlDoc.createAttribute("lng")
    		
		    ' Add data from solr result (by checking each element in solr result to see if it is lat or lng)
		    Dim recordName, subjectList, postCode, categories, i
		    recordName = ""
		    subjectList = ""
		    categories = ""
		    i = 0
		    For Each element In list
			    ' If the element has the 'lat' attribute then it contains the latitude
			    If ("lat" = element.getAttribute("name")) Then
				    homebaseCoordsLat.text = element.text
			    End If
			    ' If the element has the 'lat' attribute then it contains the latitude
			    If ("lng" = element.getAttribute("name")) Then
				    homebaseCoordsLng.text = element.text
			    End If
			    ' If the element has the 'authority' attribute then it contains the authorioty name (used for checking if this is a Nationwide service)
			    If ("authority" = element.getAttribute("name")) Then
				    authority.text = element.text
			    End If
			    ' If the element has the 'dc.subject.orig_s' attribute then it contains the ORIGINAL subjects the record was tagged with
			    If ("dc.subject.orig_s" = element.getAttribute("name")) Then
				    If (8 > i and absChosenCategory <> element.text) Then categories = categories & "%20or%20" & element.text
				    i = i+1
			    End If
            Next
    		
		    ' and add them to the xml
		    homebase.setAttributeNode homebaseCoordsLat
		    homebase.setAttributeNode homebaseCoordsLng
		    echo.appendChild(homebase)
		    echo.appendChild(authority)
		    echo.appendChild(xmlDoc.CreateTextNode(vbCrLf))
		
		' End geocoding
		
        ' F10 See Also tool start
            ' Create a second SRU query, searching for records which share a category (barring the one used to find this record)
            ' Note - this only operates on the ORIGINAL subjects the record was tagged with, not any higher-level ones or associated ones
            If ("" <> absChosenCategory) Then
                categories = Mid(categories, 9)
                If ("" <> categories) Then
                    Set xmlSeeAlso = makeDoc(xmlSeeAlso)
                    xmlSeeAlso.async = false
                    xmlSeeAlso.preserveWhiteSpace = True
                    xmlSeeAlso.setProperty "ServerHTTPRequest", true
                    ' Load the converted text into the xmlDoc
                    sruSeeAlso = Application.Value("root") & "/sru/xml/default?version=1.2&apikey=" & Application.Value("apikey") & "&operation=searchRetrieve&query=Subject%3D(%22" & categories & "%22)%20not%20InternalId%3D" & absRecordID & "%20and%20Authority%3D%22NFSDPortal%22&sortKeys=score&maximumRecords=5&startRecord=1"
                    xmlSeeAlso.load(sruSeeAlso)
                    If (0 < xmlSeeAlso.documentElement.getElementsByTagName("srw:numberOfRecords").item(0).text) Then
                        Set resultsTree = xmlSeeAlso.getElementsByTagName("srw:records").item(0)
                        echo.appendChild(resultsTree.cloneNode(true))
    		            Set category = xmlDoc.createAttribute("category")
                        category.text = absChosenCategory
		                queryString.setAttributeNode category
                    End If
                End If
            End If
        ' F10 See Also tool end
		
		
	' If the main request (ie for the record itself) fails, redirect the user
	Else
		Response.Redirect Server.MapPath(Application.Value("xslRootPath") & Application.Value("four0fourPage"))
	End If
	
' Save and reload the xml doc ( FOR BUG TRACKING - MAKES ALL CHANGES VISIBLE )
' xmlDoc.Save("C:\temp\newdoc.xml")
' xmlDoc.Load("C:\temp\newdoc.xml")

' For each item in the relevant array, combine it with the xmlDoc to create HTML code
For i=0 to numberOfParts-1
	' Create xsl object
	Set xslDoc = makeDoc(xslDoc)
	xslDoc.resolveExternals = true
	xslDoc.setProperty "AllowDocumentFunction",true
	xslDoc.async = false
	xslDoc.preserveWhiteSpace = True

    ' Select appropriate XSL file from record type
	If "ECD" = absRecordType Then
		xslDoc.load(Server.MapPath(Application.Value("xslRootPath") & xslECDArray(i)))
	End If
	If "FSD" = absRecordType Then
		xslDoc.load(Server.MapPath(Application.Value("xslRootPath") & xslFSDArray(i)))
	End If

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