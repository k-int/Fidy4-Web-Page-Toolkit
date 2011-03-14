<% Response.ContentType="text/html"

Response.Charset="UTF-8"

Session.CodePage=65001 %>

<!--#include file="globalvars.asp"-->

<%
	' Define and assign values to relevant variables
	' Comment out (or delete) these lines if you are using included method, and define these variables in your containing ASP page
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	Dim absFreetext, absCat, absTitle, absEligibility, absLocation, absDistance, absFilters, absNational, absXNational
	Dim absView, absStartPoint, absPerPage
	
	' S01: Code required for freetext search tool start
	    ' Freetext - a simple string query, like you would put in Google (e.g. "Schools Basingstoke")
	    absFreetext = RemoveAccentedCharacters(Request.QueryString("freetext"))
	' S01: Code required for freetext search tool start

	' S02: Code required for category search tool start
	    ' Category - the code for the category a service is in (e.g. "001-8")
	    absCat = Request.QueryString("category")
	    ' Category - the code for the sub-category a service is in (e.g. "001-8d")
	    absSubCat = Request.QueryString("subcategory")
	    ' Category - the code for the sub-subcategory a service is in (e.g. "001-8d5")
	    absSubSubCat = Request.QueryString("subsubcategory")
	' S02: Code required for category search tool start

	' S04: Code required for eligibility criteria tool start
	    ' Eligibility - freetext detailing who is eligible for this service (e.g. "JSA only")
	    absEligibility = Request.QueryString("eligibilityCriteria")
	' S04: Code required for eligibility criteria tool end

	' S09: Code required for record title search tool start
	    ' Title - the specific title of a service (e.g. "Little Tots Nursery")
	    absTitle = Request.QueryString("title")
	' S09: Code required for record title search tool end

	' L01: Code required for location filter tool start
	    ' Location - a town, city, area or postcode (either full or just the first part)
	    ' location may also be a lat/long in the format of nn.nnn,nn.nnn
	    ' Valid examples include "London", "Norwich", "Shoreditch", "N11" and "B23 5RS"
	    absLocation = Request.QueryString("location")

	    ' Distance - radial limit (in miles) from the centre of the above location.
	    ' This option must be used in conjunction with Location, as without that it has no point of reference.
	    If IsNumeric(Request.QueryString("filterDist")) Then absDistance = Request.QueryString("filterDist") Else absDistance = 5
	    
	    ' National - boolean option to exclude Nationwide services from the results.
	    ' If this is set to anything other than 'off', Nationwide services will be included in the results
	    absNational = Request.QueryString("national")

	    ' XNational - Modifies above. If set 'off' it excludes Nationwide services unless National is also set to 'on'
	    absXNational = Request.QueryString("xnational")
	' L01: Code required for location filter search tool end

	' F02, F03, F04, F05, F06, F07, F08, F09: Code required for filters tool start
	    ' Filters - comma-separated list of codes (see the fullFilterNames list below) of filters to apply.
	    ' The list must only use codes defined below, and have no spaces. For example, "wAcc,vacs,yrs1-4"
	    absFilters = Request.QueryString("filters")
	' F02, F03, F04, F05, F06, F07, F08, F09: Code required for filters tool start

	' R01: Results sorting tool start
	' sortBy - Valid values "name", "updated" or (if map enabled) "distance", defaults to "relevance".
	    absSortBy = Request.QueryString("sortBy")
	' R01: Results sorting tool end

	' R02: Code required for results pagination tool start
	    ' StartPoint - First record on page, defaults to "1".  Used to page through results
	    If IsNumeric(Request.QueryString("startPoint")) Then absStartPoint =  Request.QueryString("startPoint") Else absStartPoint =  1
	' R02: Code required for results pagination tool end

	' R02, R03: Code required for results pagination/set sizing tool start
	    ' PerPage - Results per page, default "10".
	    If IsNumeric(Request.QueryString("perPage")) Then absPerPage = Request.QueryString("perPage") Else absPerPage = 10
	' R02, R03: Code required for results pagination/set sizing tool start

	' R04, R05, R06: Code required for list/table/map tool start
	    ' View - Valid values "list", "table" or "map", defaults to "list".  Sets which tab is active on results page
	    absView = Request.QueryString("view")
	' R04, R05, R06: Code required for list/table/map tool end

	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	' End section
	
	
	' Define an array of XSL files and one for the resulting output
	' Each section on your page will be assigned to an element in the xslOutputArray, at the same index as its corresponging xsl file
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
	Dim xslArray(), xslOutputArray(), numberOfParts
	numberOfParts = 2
	ReDim xslArray(numberOfParts-1)
	ReDim xslOutputArray(numberOfParts-1)
	xslArray(0) = "results_head.xsl"
	xslArray(1) = "results_body.xsl"
	'''''''''''''''''''''''''''''''''''''''''''''''''''''
	' End section
	
' Function to add an item to an array	
Dim queryArray()
Redim queryArray(0)
Function pushQuery(queryContents)
	If 0 < len(queryArray(0)) Then
		Redim Preserve queryArray(uBound(queryArray) + 1)
		queryArray(uBound(queryArray)) = queryContents
	Else
		queryArray(0) = queryContents
	End If
End Function

' fullFilterNames - this array simply holds the names of the filters as they should be displayed on the page
' NOTE - these names should really match the names in the results.xsl file in the Available Filters sidebar div
Set fullFilterNames=Server.CreateObject("Scripting.Dictionary")

' F06: Code for wheelchair access filter tool start
fullFilterNames.Add "wAcc", "Wheelchair Access"
' F06: Code for wheelchair access filter tool end

' F07: Code for special needs filter tool start
fullFilterNames.Add "sNeeds", "Caters for Special Needs"
' F07: Code for special needs filter tool end

' F08: Code for current vacancies filter tool start
fullFilterNames.Add "vacs", "Current Vacancies"
' F08: Code for current vacancies filter tool end

' F09: school pickup filter tool start
fullFilterNames.Add "pickup", "School Pickups"
' F09: school pickup filter tool end

' F02: Code for age range filter tool start
fullFilterNames.Add "yrs0-1", "0-1 year"
fullFilterNames.Add "yrs1-4", "1-4 years"
fullFilterNames.Add "yrs5-10", "5-10 years"
fullFilterNames.Add "yrs10-18", "10-18 years"
fullFilterNames.Add "yrs18-25", "18-25 years"
fullFilterNames.Add "yrs25", "25+ years"
' F02: Code for age range filter tool end

' array of filters represented as Flags in SRU search
Set filterFlagSearches=Server.CreateObject("Scripting.Dictionary")
' F06: Code required for wheelchair access filter tool start
filterFlagSearches.Add "wAcc", "WheelChairAccess"
' F06: Code required for wheelchair access filter tool end

' F07: Code required for special needs filter tool start
filterFlagSearches.Add "sNeeds", "SpecialNeeds"
' F07: Code required for special needs filter tool end

' F09: Code required for school pickup filter tool start
filterFlagSearches.Add "pickup", "SchoolPickup"
' F09: Code required for school pickup filter tool end

' F02, : Code required for age range filter tool start
' Age search is done by setting age range maxes and mins
Set filterAgeSearches=Server.CreateObject("Scripting.Dictionary")
filterAgeSearches.Add "yrs0-1", age_range(0,1)
filterAgeSearches.Add "yrs1-4", age_range(1,4)
filterAgeSearches.Add "yrs5-10", age_range(5,10)
filterAgeSearches.Add "yrs10-18", age_range(10,18)
filterAgeSearches.Add "yrs18-25", age_range(18,25)
filterAgeSearches.Add "yrs25", "(AgeRangeMin%3E24%20or%20AgeRangeMax%3E24)"

' This function creates an SRU String fragment specifying the criteria needed for an age range search between two given ages (min and max)
Function age_range(min, max)
    age_range = "(" _
                    &"(AgeRangeMin%3E"&(min - 1)&"%20and%20AgeRangeMax%3C"&(max + 1)&")" _
                &"%20or%20" _
                    &"(AgeRangeMin%3C"&(min + 1)&"%20and%20AgeRangeMax%3E"&(max - 1)&")" _
                &"%20or%20" _
                    &"(" _
                        &"(AgeRangeMin%3E"&(min - 1)&"%20or%20AgeRangeMax%3C"&(max + 1)&")" _
                      &"%20and%20" _
                        &"(AgeRangeMin%3C"&(min + 1)&"%20or%20AgeRangeMax%3E"&(max - 1)&")" _
                      &"%20and%20" _
                        &"(AgeRangeMin%3C"&(max + 1)&"%20and%20AgeRangeMax%3E"&(min - 1)&")" _
                    &")" _
               &")"
End Function
' F02: Code required for age range filter tool end

' S01, S09: Code required for freetext, record title search tool start
' This function applied a default "OR" operation to words in the freetext and title queries, unless the words are OR, NOT or AND
' If there is a quoted string, this is added as an exact match for the access point specified when the function is called
Function add_bools(unbooledString, accessPoint)

    Dim textArray, regex, matches, i, regexProblemChars
    Dim matchValue 
    Set regex = New RegExp   
    regex.Global = True
    regex.Pattern = "[^\s""]+|""([^""]*)""|'([^']*)'"
    
    Set regexProblemChars = New RegExp
    regexProblemChars.Global = True
    regexProblemChars.Pattern = "[^A-Za-z0-9]{1}"
    
    Set matches = regex.Execute(unbooledString)
    ReDim textArray(matches.Count-1)
    i=0
    For Each match in matches
        matchValue = match.Value
                
               
        ' Add the match string to the string array.   
        If ("and" = LCase(matchValue) OR "or" = LCase(matchValue) OR "not" = LCase(matchValue)) Then 
            textArray(i) = LCase(matchValue)
        Else If ((1 < Len(matchValue) and "*" = Left(matchValue, 1)) or "?" = Left(matchValue, 1)) Then
            textArray(i) = 	LCase(Replace(matchValue, "*", "\*"))
            textArray(i) = 	LCase(Replace(textArray(i), "?", "\?"))
        Else
            ' Get the initial keyword being searched for, this needs to be single quoted or double quoted where it contains
            ' special characters.
            textArray(i) = """" & LCase(matchValue) & """"
            
             ' If this string isn't already double quoted then double quote it if it contains problem characters
              IF Left(textArray(i), 2) <> """""" OR Right(textArray(i), 2) <> """""" Then
					' Not already double quoted, see if should be
					IF regexProblemChars.Test(textArray(i)) THEN                    
                        ' Double quote as contains special chars
                        textArray(i) = """" + textArray(i) + """"
                    End If
              End if
        End If
        End If
        i=i+1
    Next
    
	Dim newTextArray(), limit
	Redim newTextArray(uBound(textArray))
	limit = uBound(textArray) - 1
	
	If ("and" = LCase(textArray(0)) OR "or" = LCase(textArray(0)) OR "not" = LCase(textArray(0))) Then
	    newTextArray(0) = ""
	Else If (0 < InStr(textArray(0), """""")) Then
	    newTextArray(0) = accessPoint & " adj (" & textArray(0) & ")"
	Else
	    newTextArray(0) = LCase(textArray(0))
	End If
	End If
	
	If (0 < limit) Then
	
	    For i=1 to limit
		    If ("and" = LCase(textArray(i)) OR "or" = LCase(textArray(i)) OR "not" = LCase(textArray(i))) Then
    		    If ("and" = LCase(textArray(i-1)) OR "or" = LCase(textArray(i-1)) OR "not" = LCase(textArray(i-1))) Then
			        newTextArray(i) = ""
			    Else
			        newTextArray(i) = " "&textArray(i)
			    End If
		    Else If ("and" = LCase(textArray(i-1)) OR "or" = LCase(textArray(i-1)) OR "not" = LCase(textArray(i-1))) Then
			    If (0 < InStr(textArray(i), """""")) Then
			        newTextArray(i) = " " & accessPoint & " adj (" & textArray(i) & ")"
			    Else
	                newTextArray(i) = " " & textArray(i)
	            End If
	        Else
			    If (0 < InStr(textArray(i), """""")) Then
			        newTextArray(i) = " or " & accessPoint & " adj (" & textArray(i) & ")"
			    Else
	                newTextArray(i) = " or " & textArray(i)
	            End If
		    End If
	        End If
	    Next ' end for loop
	    
        If ("and" = LCase(textArray(limit)) OR "or" = LCase(textArray(limit)) OR "not" = LCase(textArray(limit))) Then
	        If ("and" = LCase(textArray(limit-1)) OR "or" = LCase(textArray(limit-1)) OR "not" = LCase(textArray(limit-1))) Then
	            newTextArray(limit) = """" & textArray(limit) & """"
	        Else
	            newTextArray(limit) = ""
	        End If
        Else If ("and" = LCase(textArray(limit-1)) OR "or" = LCase(textArray(limit-1)) OR "not" = LCase(textArray(limit-1))) Then
	        If (0 < InStr(textArray(limit), """""")) Then
	            newTextArray(limit) = " " & accessPoint & " adj (" & textArray(limit) & ")"
	        Else
                newTextArray(limit) = " " & textArray(limit)
            End If
        Else
	        If (0 < InStr(textArray(limit), """""")) Then
	            newTextArray(limit) = " or " & accessPoint & " adj (" & textArray(limit) & ")"
	        Else
                newTextArray(limit) = " or " & textArray(limit)
            End If
        End If
        End If
    
	End If
	
	Dim returnString
	returnString = LCase(join(newTextArray, ""))
	returnString = Replace(returnString, LCase(accessPoint), accessPoint)
	add_bools = Server.URLEncode(Replace(returnString, """""", """"))
	
End Function
' S01, S09: Code required for freetext, record title search tool end


Function RemoveAccentedCharacters(strIn) 
    Dim strOut
    Dim strMid
    Dim n 
          
    For n = 1 To Len(strIn)
        strMid = Mid(strIn, n, 1)        
        Select Case AscW(strMid)
        Case 192, 193, 194, 195, 196, 197:
            strMid = "A"
        Case 198:
            strMid = "AE"
        Case 199:
            strMid = "C"
        Case 200, 201, 202, 203:
            strMid = "E"
        Case 204, 205, 206, 207:
            strMid = "I"
        Case 208:
            strMid = "D"
        Case 209:
            strMid = "N"
        Case 210, 211, 212, 213, 214, 216:
            strMid = "O"
        Case 215:
            strMid = "x"
        Case 217, 218, 219, 220:
            strMid = "U"
        Case 221:
            strMid = "Y"
        Case 222, 254:
            strMid = "p"
        Case 223:
            strMid = "B"
        Case 224, 225, 226, 227, 228, 229:
            strMid = "a"
        Case 230:
            strMid = "ae"
        Case 231:
            strMid = "c"
        Case 232, 233, 234, 235:
            strMid = "e"
        Case 236, 237, 238, 239:
            strMid = "i"
        Case 240, 242, 243, 244, 245, 246, 248:
            strMid = "o"
        Case 241:
            strMid = "n"
        Case 249, 250, 251, 252:
            strMid = "u"
        Case 253, 254, 255:
            strMid = "y"       
        End Select
        strOut = strOut + strMid
    Next    
    RemoveAccentedCharacters = strOut
End Function



' Create an SRU query from the url
Dim qLocation, qFilterDist, qNational, filtersArray
	'***********Function ************************
	'Name: make_query
	'Description: Creates an SRU query from the received url
	'Parameters - IN: useLocation - boolean, default = true. Sets whether to include location search information in query
	'Parameters - OUT: sruString - string. Complete SRU string for specified criteria
	'Customisable: MODIFY INDICATED SECTIONS ONLY
	'Notes: 
	'********************************************
Function make_query(useLocation)
    
    Redim queryArray(0)
    If (isNull(useLocation) Or false = useLocation) Then useLocation = false Else useLocation = true

    ' S01: Code required for freetext search tool start
	If ("" <> absFreetext) Then
		pushQuery("("&add_bools(absFreetext, "cql.serverChoice")&")")
	End If
    ' S01: Code required for freetext search tool end
	
    ' S02, F01: Code required for subject search/filter tool start
    Set vocabDoc = makeDoc(vocabDoc)
    vocabDoc.async = false
    vocabDoc.preserveWhiteSpace = True
    vocabDoc.setProperty "ServerHTTPRequest", true
    ' Load the converted text into the xmlDoc
    vocabDoc.loadXML(Application.Value("fullCatsList"))
    If (Not (vocabDoc.selectSingleNode("topTerms/term['" & absCat & "' = identifier]/termChildren/term['" & absSubCat & "' = identifier]/termChildren/term['" & absSubSubCat & "' = identifier]/internalId")) Is Nothing) Then
	    pushQuery("Subject%3D(%22"&absSubSubCat&"%22)")
    Else If (Not (vocabDoc.selectSingleNode("topTerms/term['" & absCat & "' = identifier]/termChildren/term['" & absSubCat & "' = identifier]/internalId")) Is Nothing) Then
		pushQuery("Subject%3D(%22"&absSubCat&"%22)")
		absSubSubCat = ""
	Else If ("" <> absCat) Then
		pushQuery("Subject%3D(%22"&absCat&"%22)")
		absSubCat = ""
		absSubSubCat = ""
	End If
	End If
	End If
    ' S02, F01: Code required for subject search/filter tool end
	
    ' S04: Code required for eligibility criteria tool start
	If ("" <> absEligibility) Then
		pushQuery("EligibilityCriteria%3D(" & add_bools(absEligibility, "EligibilityCriteria") & ")")
	End If
    ' S04: Code required for eligibility criteria tool end
    
    ' S05: Code required for referral criteria tool start
	If ("" <> Request.QueryString("referralCriteria")) Then
	    absFilters = absFilters & "," & Request.QueryString("referralCriteria")
	End If
    ' S05: Code required for referral criteria tool end
    
    ' S06: Code required for access criteria tool start
	If ("" <> Request.QueryString("accessChannel")) Then
	    absFilters = absFilters & "," & Request.QueryString("accessChannel")
	End If
    ' S06: Code required for access criteria tool end
    
    ' S07: Code required for language tool start
	If ("" <> Request.QueryString("language")) Then
	    absFilters = absFilters & "," & Request.QueryString("language")
	End If
    ' S07: Code required for language tool end
    
	' S08: Wheelchair access / Special needs search start
	If ("on" = Request.QueryString("wheelchairAccess")) Then
	    absFilters = absFilters & ",wAcc"
   	End If
	If ("on" = Request.QueryString("specialNeeds")) Then
	    absFilters = absFilters & ",sNeeds"
   	End If
	' S08: Wheelchair access / Special needs search end
   	
    ' S09: Code required for record title search tool start
	If ("" <> absTitle) Then
		pushQuery("dc.title%3D(" & add_bools(absTitle, "dc.title") & ")")
	End If
    ' S09: Code required for record title search tool end
	
    ' L01: Code required for location filter tool start
    ' Check if location is a latitude and longitude or textual location
	If ("" <> absLocation and true = useLocation) Then
		' See if location is a lat/long
		Dim regexLatLong
		Set regexLatLong = New RegExp
		regexLatLong.Global = True
		regexLatLong.Pattern = "^-{0,1}\d+\.\d+,-{0,1}\d+\.\d+$"
		If regexLatLong.Test(absLocation) Then
			pushQuery("geostr%3D%22" & absLocation)		
		Else
			qLocation = Server.URLEncode(Replace(absLocation, """", ""))
			pushQuery("Location%3D%22" & qLocation & "%22")			
		End If
	End If
	
	qFilterDist = "5"
	If ("" <> absDistance) Then
		If (1 > absDistance) Then qFilterDist = 1 Else qFilterDist = Round(absDistance, 2)
	End If
	
	If ("off" = absNational OR ("off" = absXNational AND ("on" <> absNational))) Then
		qNational	= "false"
	Else
		qNational	= "true"
	End If
    ' L01: Code required for location filter tool end
	
	' S03, F02, F03, F04, F05, F06, F07, F08, F09: filter tools start
	If Not ("" = absFilters) Then
		Dim refs, accs, lans, flags, ages, vacs
	
		If ("," = Left(absFilters, 1)) Then absFilters = Right(absFilters, len(absFilters)-1)
		filtersArray = Split(absFilters, ",")
		For Each filterCodename in filtersArray
		    ' F03: referral criteria filter start
            If ("ref" = Mid(filterCodename, 1, 3)) Then
		        If ("" <> refs) Then
		            refs = refs & "%20AND%20" & Mid(filterCodename, 4)
		        Else
		            refs = Mid(filterCodename, 4)
		        End If
            End If
		    ' F03: referral criteria filter end
		    ' F04: access channel filter start
            If ("acc" = Mid(filterCodename, 1, 3)) Then
		        If ("" <> accs) Then
		            accs = accs & "%20AND%20" & Mid(filterCodename, 4)
		        Else
		            accs = Mid(filterCodename, 4)
		        End If
            End If
		    ' F04: access channel filter end
		    ' F05: language filter start
            If ("lan" = Mid(filterCodename, 1, 3)) Then
		        If ("" <> lans) Then
		            lans = lans & "%20AND%20" & Mid(filterCodename, 4)
		        Else
		            lans = Mid(filterCodename, 4)
		        End If
            End If
		    ' F05: language filter end
		    ' F06, F07, F09 filters start
			If "" <> filterFlagSearches.Item(filterCodename) Then
			    If "" <> flags Then
			        flags = flags & "%20AND%20" & filterFlagSearches.Item(filterCodename)
			    Else
			        flags = filterFlagSearches.Item(filterCodename)
			    End If
			End If
		    ' F06, F07, F09 filters end
		    ' F02 age range filter start
			If "" <> filterAgeSearches.Item(filterCodename) Then
			    If "" <> ages Then
			        ages = ages & "%20AND%20" & filterAgeSearches.Item(filterCodename)
			    Else
			        ages = filterAgeSearches.Item(filterCodename)
			    End If
			End If
		    ' F02 age range filter end
		    ' F08 current vacancies filter start
			If "vacs" = filterCodename Then
			    vacs = "Vacancies%3dtrue"
			End If
		    ' F08 current vacancies filter end
		Next
	    ' F03  referral criteria filter start
		If ("" <> refs) Then
		    refs = "ReferralCriteria%3D("&refs&")"
	     	pushQuery(refs)
	    End If
	    ' F03  referral criteria filter end
	    ' F04: access channel filter start
		If ("" <> accs) Then
		    accs = "AccessChannel%3D("&accs&")"
	     	pushQuery(accs)
	    End If
	    ' F04: access channel filter end
	    ' F05: language filter start
		If ("" <> lans) Then
		    lans = "Language%3D("&lans&")"
	     	pushQuery(lans)
	    End If
	    ' F05: language filter end
	    ' F06, F07, F09 filters start
		If ("" <> flags) Then
		    flags = "Flags%3D("&flags&")"
	   	    pushQuery(flags)
	   	End If
	    ' F06, F07, F09 filters end
	    ' F02 age range filter start
		If ("" <> ages) Then
	     	pushQuery(ages)
	    End If
	    ' F02 age range filter end
	    ' F08 current vacancies filter start
		If ("" <> vacs) Then
	      	pushQuery(vacs)
	    End If
	    ' F08 current vacancies filter end
	End If
	' S03, F02, F03, F04, F05, F06, F07, F08, F09: filter tools end

    ' Check if ANY search criteria have come in - if not, redirect to the 'no results' page
    If (0 = len(queryArray(0))) Then
        query = "*"
    Else
        query = Join(queryArray, "%20and%20")
    End If
    
    ' Create a RESTful request
    Dim sruStartRecord, sruString, fetchRecord, sruSortKeys

    sruStartRecord = "1"
    If (50 <= absStartPoint) Then
        sruStartRecord = absStartPoint - 50
    End If

    If ("false" = qNational) Then
        query = query & "%20NOT%20Authority%3D%22NFSDPortal%22"
    End If

	' R01: Results sorting tool start
    Select Case absSortBy
        Case "name":
            sruSortKeys = "title"
        Case "last updated":
            sruSortKeys = "modified,,0%20title"
        Case "distance":
            sruSortKeys = "geo_distance%20title"
        Case Else
            sruSortKeys = "score,,0%20title"
    End Select
	' R01: Results sorting tool start

    sruString = "/sru/xml/default?version=1.2&apikey=" & Application.Value("apikey") & "&operation=searchRetrieve&query=" & query & "&radius=" & qFilterDist & "&sortKeys=" & sruSortKeys & "&maximumRecords=100&startRecord=" & sruStartRecord & _
                "&x-kint-facet=true" & _
                "&x-kint-facet.field=dc.subject" & _
                "&x-kint-facet.field=flags" & _
                "&x-kint-facet.field=immediate_vacancies_s" & _
                "&x-kint-facet.field=referral_criteria_s" & _
                "&x-kint-facet.field=mode_of_access_s" & _
                "&x-kint-facet.field=language_spoken_s" & _
                "&x-kint-facet.mincount=1"

    make_query = sruString
    
End Function

' Create xml object
Set xmlDoc = makeDoc(xmlDoc)
xmlDoc.async = false
xmlDoc.preserveWhiteSpace = True
xmlDoc.setProperty "ServerHTTPRequest", true


'***********Function ************************
'Name: loadXML
'Description: Loads in the received stream of XML data that holds the results information from a query
'Parameters - IN: fetchRecord - XML data stream
'Parameters - OUT: none
'Customisable: DO NOT MODIFY
'Notes: Can change the text of the error message
'********************************************
Function loadXML(fetchRecord)
    
   ' Load xml doc from url
    xmlDoc.load(fetchRecord)
    
    ' Check that the search results have a document element (ie the request completed OK)
	If (0 = xmlDoc.parseError) Then
	    If ("diagnostics" = xmlDoc.documentElement.nodeName) Then
	        queryError = true
	        useLocation = false
	        errorCounter = errorCounter + 1
	    Else If Not ("srw:searchRetrieveResponse" = xmlDoc.documentElement.nodeName) Then
	        queryError = true
	        errorCounter = errorCounter + 1
        End If
        End If
    Else
	    Response.Redirect Server.MapPath(Application.Value("xslRootPath") & Application.Value("four0fourPage"))
    '    response.write "Error parsing XML Doc <br /><br />"
    End If
    
End Function
    

Dim queryError, errorCounter, useLocation
useLocation = true
queryError = false
errorCounter = 0

Do
    queryError = false
    fetchRecord = Application.Value("root") & make_query(useLocation)
     'response.write fetchRecord & "<br />"
   'response.Write(fetchRecord)
    'response.End()
    loadXML(fetchRecord)
Loop While (true = queryError and 5 > errorCounter)

If (5 <= errorCounter) Then 
'	Response.Redirect Server.MapPath(Application.Value("xslRootPath") & Application.Value("four0fourPage"))
    response.write "You would have been redirected by now...<br /><br />"
End If
		
    
	' Add a node for readback of search parameters, ordering etc
	Set echo = xmlDoc.createElement("echoedData")
    If Not (xmlDoc.documentElement Is Nothing) Then
       Set rootElement = xmlDoc.documentElement
	    rootElement.insertBefore echo, null
	    echo.appendChild(xmlDoc.CreateTextNode(vbCrLf))
	End If
	
	' Create the nodes
	Set queryString = xmlDoc.createElement("queryString")
	queryString.text = Request.QueryString
	
    ' S01: Code required for freetext search tool start
	Set freetext = xmlDoc.createAttribute("freetext")
	freetext.text = Replace(absFreetext, "+", " ")
	freetext.text = Replace(freetext.text, " or ", " OR ")
	freetext.text = Replace(freetext.text, " not ", " NOT ")
	freetext.text = Replace(freetext.text, " and ", " AND ")
	queryString.setAttributeNode freetext
    ' S01: Code required for freetext search tool end
	
    ' S02, F01: Code required for subject search/filter tool start
	Set category = xmlDoc.createAttribute("category")
	category.text = absCat
	queryString.setAttributeNode category
	Set subcategory = xmlDoc.createAttribute("subcategory")
	subcategory.text = absSubCat
	queryString.setAttributeNode subcategory
	Set subsubcategory = xmlDoc.createAttribute("subsubcategory")
	subsubcategory.text = absSubSubCat
	queryString.setAttributeNode subsubcategory
    ' S02, F01: Code required for subject search/filter tool start
	
    ' S04: Code required for eligibility criteria tool start
	Set eligibility = xmlDoc.createAttribute("eligibilityCriteria")
	eligibility.text = Replace(absEligibility, "+", " ")
	eligibility.text = Replace(eligibility.text, " or ", " OR ")
	eligibility.text = Replace(eligibility.text, " not ", " NOT ")
	eligibility.text = Replace(eligibility.text, " and ", " AND ")
	queryString.setAttributeNode eligibility
    ' S04: Code required for eligibility criteria tool end
	
    ' S09: Code required for record title search tool start
	Set title = xmlDoc.createAttribute("title")
	title.text = Replace(absTitle, "+", " ")
	title.text = Replace(title.text, " or ", " OR ")
	title.text = Replace(title.text, " not ", " NOT ")
	title.text = Replace(title.text, " and ", " AND ")
	queryString.setAttributeNode title
    ' S09: Code required for record title search tool end
	
    ' L01: Code required for location filter tool start	
	Set location = xmlDoc.createAttribute("location")
	location.text = Replace(absLocation, "+", " ")
	Set locationError = xmlDoc.createAttribute("locationError")
    If (true = useLocation) Then locationError.text = "" Else locationError.text =  "yes"
    
	Set filterDist = xmlDoc.createAttribute("filterDist")
	filterDist.text = "5"
	If("" <> absDistance) Then
    	If (1 > absDistance) Then filterDist.text = 1 Else filterDist.text = Round(absDistance, 2)
	End If
	queryString.setAttributeNode location
	queryString.setAttributeNode locationError
	queryString.setAttributeNode filterDist
	
	Set national = xmlDoc.createAttribute("national")
	If("off" = absNational OR ("off" = absXNational AND ("on" <> absNational))) Then
		national.text	= "off"
	Else
		national.text	= "on"
	End If
	queryString.setAttributeNode national
    ' L01: Code required for location filter tool end	
	
	
	' S03, S04, S05, S06, S07, S08, F02, F03, F04, F05, F06, F07, F08, F09: search/filter tools start

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

	' Logic for processing filters (only kicks in if filters have been selected)
	If (0 < Len(absFilters)) Then
		Set filterList = xmlDoc.createElement("filterList")
		For Each filterCodename in filtersArray
			Set filterName = xmlDoc.createElement("filterName")
			If fullFilterNames.Exists(filterCodename) Then
				filterName.text = fullFilterNames.Item(filterCodename)
				filterList.appendChild(xmlDoc.CreateTextNode(vbCrLf&vbTab))
			End If
			Set filterCode = xmlDoc.createAttribute("filterCode")
			filterCode.text = filterCodename
			filterName.setAttributeNode(filterCode)
			filterList.appendChild(filterName)
		Next
		echo.appendChild(filterList)
	End If
	Set filters = xmlDoc.createAttribute("filters")
	filters.text = absFilters
	queryString.setAttributeNode filters
	' S03, S04, S05, S06, S07, S08, F02, F03, F04, F05, F06, F07, F08, F09: search/filter tools end
	
    ' R01: Code required for results sorting tool start	
	Set sortBy = xmlDoc.createAttribute("sortBy")
	sortBy.text = "relevance"
	If ("" <> absSortBy) Then
		sortBy.text = absSortBy
	End If
	queryString.setAttributeNode sortBy
    ' R01: Code required for results sorting tool start	
	
    ' R02: Code required for results paging tool start	
	Set startPoint = xmlDoc.createAttribute("startPoint")
	Set sruStartRecord = xmlDoc.createAttribute("sruStartRecord")
	startPoint.text = "1"
	If ("" <> absStartPoint) Then
		startPoint.text = absStartPoint
	End If
	sruStartRecord.text = "1"
    If (50 <= absStartPoint) Then
        sruStartRecord.text = absStartPoint - 50
    End If
	queryString.setAttributeNode startPoint
	queryString.setAttributeNode sruStartRecord
    ' R02: Code required for results paging tool end	
	
    ' R03: Code required for results sizing tool start	
	Set perPage = xmlDoc.createAttribute("perPage")
	perPage.text = "10"
	If ("" <> absPerPage) Then
		perPage.text = absPerPage
	End If
	queryString.setAttributeNode perPage
    ' R03: Code required for results sizing tool end	
	
    ' R04, R05, R06: Code required for results view tool start	
	Set view = xmlDoc.createAttribute("view")
	view.text = "list"
	If ("" <> absView) Then
		view.text = absView
	End If
	queryString.setAttributeNode view
    ' R04, R05, R06: Code required for results view tool end	
	
    ' R06: Code required for map view tool start	
	' Geocoding of specified centre point
	    ' Create the nodes
	    Set homebase = xmlDoc.createElement("centrePoint")
	    Set homebaseCoordsLat = xmlDoc.createAttribute("lat")
	    Set homebaseCoordsLng = xmlDoc.createAttribute("lng")
	    Set homebasePostcode = xmlDoc.createAttribute("PostCode")
    	
        ' Add data from srw:searchRetrieveResponse/srw:echoedSearchRetrieveRequest/srw:extraResponseData 
        Dim list
        Set list = xmlDoc.getElementsByTagName("srw:extraProp")
        For Each element in list
	        ' if (the element has the 'lat' attribute then it contains the latitude
	        If ("geo_lat" = element.getAttribute("name")) Then
		        homebaseCoordsLat.text = element.getAttribute("value")
	        End If
	        ' If the element has the 'lng' attribute then it contains the longitude
	        If ("geo_lon" = element.getAttribute("name")) Then
		        homebaseCoordsLng.text = element.getAttribute("value")
	        End If
        Next
        homebasePostcode.text = "No Location"
	    If ("" <> absLocation) Then
		    homebasePostcode.text = Server.HTMLEncode(Replace(absLocation, "+", " "))
	    End If
    	
	    ' and add them to the xml
	    homebase.setAttributeNode homebaseCoordsLat
	    homebase.setAttributeNode homebaseCoordsLng
	    homebase.setAttributeNode homebasePostcode
    	
	    If Not (echo Is Nothing) Then
		   echo.appendChild(homebase)
		   echo.appendChild(xmlDoc.CreateTextNode(vbCrLf))
	    End If
    ' R06: Code required for map view tool end	
	
	echo.appendChild(xmlDoc.CreateTextNode(vbTab))
	echo.appendChild(queryString)
	echo.appendChild(xmlDoc.CreateTextNode(vbCrLf&vbTab))
	
	
		
' Save and reload the xml doc ( FOR BUG TRACKING - MAKES ALL CHANGES VISIBLE )
' xmlDoc.Save("C:\temp\newdoc.xml")
' xmlDoc.load("C:\temp\newdoc.xml")
	

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