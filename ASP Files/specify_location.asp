<!--#include file="specify_location-processer.asp"-->

<%

	' The following creates a basic web page to display the result of the XSL transformations done in the "specify_location-processer.asp" file
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Response.Write "<!DOCTYPE html PUBLIC ""-//W3C//DTD HTML 4.01//EN"" ""http://www.w3.org/TR/html4/strict.dtd"">" & VbCrLf
	Response.Write "<html>" & VbCrLf
	Response.Write "    <head>" & VbCrLf
	
	Response.Write "<META http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />"

	    ' write head
	    Response.BinaryWrite xslOutputArray(0)
	    
	Response.Write "    <title>findit Directory</title>" & VbCrLf & VbCrLf
	
	Response.Write "    </head>" & VbCrLf & VbCrLf
	
	Response.Write "    <body>" & VbCrLf
	
	    ' write body
	    Response.BinaryWrite xslOutputArray(1)
	    
	Response.Write "    </body>" & VbCrLf
	
	Response.Write "</html>"
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	' End Section

%>