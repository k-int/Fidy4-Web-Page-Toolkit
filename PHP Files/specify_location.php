<?php
	
include_once("specify_location-processer.php");

	// The following creates a basic web page to display the result of the XSL transformations done in the "details-processer.asp" file
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	echo( "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n" );
	echo( "<html>\n" );
	echo( "    <head>\n" );
	
	echo( "<META http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n" );

	    // head
	    echo( $xslOutputArray[0] );
	    
	echo( "    <title>findit Search</title>\n" );
	
	echo( "    </head>\n" );
	
	echo( "    <body>\n" );
	
	    // body
	    echo( $xslOutputArray[1] );
	    
	echo( "    </body>\n" );
	
	echo( "</html>\n" );
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// End Section

?>
