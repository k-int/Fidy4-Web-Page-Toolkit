	
	var defaultCentre = "52.374968, 1.466846";
	var defaultZoom = "11";
	var markerArray = new Array();
	
	document.write('	<script type="text/javascript" src="'+scriptsFolder+'mapstraction.js"></script>') ;
	
	function appendMap(mapDiv, toReplace) {
	    var shownText = getElem(toReplace);
	    var mapContainer = document.createElement('div');
	    var mapId = document.createAttribute('id');
	    mapId.nodeValue = 'mapDiv';
	    mapContainer.setAttributeNode(mapId);
	    shownText.parentNode.insertBefore(mapContainer, shownText);
	    shownText.parentNode.removeChild(shownText);
	}
	
	function makeMap(mapDiv, mapType, centrePoint, zoom) {
		
		if (!centrePoint) {
			centrePoint = (defaultCentre);
		}
		if (!zoom) {
			zoom = (defaultZoom);
		}
		
		// initialise the map with your choice of API
		mapstraction = new Mapstraction(mapDiv, mapType);
		
		centreMap(centrePoint, zoom);
		
		mapstraction.addControls({
			pan: true, 
			zoom: 'small',
			map_type: true 
		});
	}
	
	function centreMap(mapCentre, zoom) {
		
		if (!mapCentre) {
			mapCentre = (defaultCentre);
		}
		if (!zoom) {
			zoom = (defaultZoom);
		}
		
		var homeCoords = mapCentre.split(", ");
		var centrePoint = new LatLonPoint(homeCoords[0], homeCoords[1]);
		
		// display the map centered on a latitude and longitude (Google zoom levels)
		mapstraction.setCenterAndZoom(centrePoint, zoom);
		
	}
	
	Array.prototype.makeDetail = function() {
	    return "<a href=\"" + this[3] + "\"><b>"+this[1]+"</b></a><br />"+this[2];
	}
	
	function makeLocations(serviceLocations, startRecord, sruStartRecord, perPage, mapType, range) {
	
        var homeCoords = serviceLocations[0][0].split(", ");
		var centrePoint = new LatLonPoint(homeCoords[0], homeCoords[1]);
		var name = ('google' == mapType || "openstreetmap" == mapType) ? serviceLocations[0][1] : "";
		var infoBubbleText = "<b>"+serviceLocations[0][1]+"</b><br />"+serviceLocations[0][2];
        markerArray[0] = makeMarker(centrePoint, imagesFolder+"map_home.gif", imagesFolder+"map_home.gif", name, infoBubbleText)		
		// Create an array to hold 'used' positions on the map (ie points which already have a pin)
		var usedLocs = new Array();
		usedLocs[0] = new Array();
		usedLocs[0][0] = homeCoords[0];
		usedLocs[0][1] = homeCoords[1];

		var radius = new Radius(centrePoint, 10);
		mapstraction.addPolyline(radius.getPolyline((range*8/5), "#000000"));
		
		var j = 1;
		for (var i=1; i<serviceLocations.length; i++) {
			if (undefined !== serviceLocations[i][1]) {
				var coords = serviceLocations[i][0].split(", ");
				var point = new LatLonPoint(coords[0], coords[1]);
				var name = ('google' == mapType || "openstreetmap" == mapType) ? serviceLocations[i][1] : "";
				// Check if this is a result on the page
				var iOnPage = (((startRecord - sruStartRecord + 1) <= i) && ((parseInt(startRecord - sruStartRecord + 1) + parseInt(perPage)) > i)) ? true : false;
				// If this is a result on the page, use full pin, otherwise a counter
				if (true == iOnPage) {
				    var image = imagesFolder+'map_'+j+'.gif';
				} else {
				    var image = imagesFolder+'counter.gif';
				}
                var rollImage = imagesFolder+'maproll_'+j+'.gif';
	            
            // code relating to previous markers
                
				usedLocs[i] = new Array();
	            var leftPaneText = "";
	            var rightPaneText = "";
	            var normalText = "";
				// check through the usedLocs array...
		        for (loc in usedLocs) {
		            // ..if this location has been used, add this marker's info to the previous marker's info bubble
				    if (coords[0] == usedLocs[loc][0] && coords[1] == usedLocs[loc][1]) {
				    var iPos = (true == iOnPage) ? j : "*";
				    var locOnPage = (((startRecord - sruStartRecord + 1) <= loc) && ((parseInt(startRecord - sruStartRecord + 1) + parseInt(perPage)) > loc)) ? true : false;
				    var lPos = (true == locOnPage) ? loc - (startRecord - sruStartRecord) : "*";
				    lPos = (0 == loc) ? "0" : lPos;
				        // if the marker already has a split display, simply add the new item to the end
				        if (true == markerArray[loc].getAttribute("issplit")) {
				            leftPaneText = markerArray[loc].getAttribute("leftText") + " " + makeLeftLink(i, iPos);
				            rightPaneText = markerArray[loc].getAttribute("rightText") + makeRightLink(i, "none", serviceLocations[i].makeDetail());
				        } else {
				        // if the marker doen't have a split display, convert the existing data to split form, and then add the new item
				            markerArray[loc].setAttribute("issplit", true);
				            leftPaneText = makeLeftLink(loc, lPos, "active") + " " + makeLeftLink(i, iPos);
				            rightPaneText = makeRightLink(loc, "block", markerArray[loc].getAttribute("rightText"))+makeRightLink(i, "none", serviceLocations[i].makeDetail());
				        }
				        // remove the marker first (so changes are visible when it's added back)
				        mapstraction.removeMarker(markerArray[loc]);
			            markerArray[loc].setInfoBubble(splitBubble(leftPaneText, rightPaneText));
				        markerArray[loc].setAttribute("leftText", leftPaneText);
				        markerArray[loc].setAttribute("rightText", rightPaneText);
				        // change the counter/pin to show there are multiple results
				        if (false == locOnPage && false == iOnPage) {
		                    markerArray[loc].setIcon(imagesFolder+"counter_mult.gif");
				        } else {
			                markerArray[loc].setIcon(imagesFolder+"map_mult_"+lPos+".gif");
			                markerArray[loc].setAttribute("origIcon", imagesFolder+"map_mult_"+lPos+".gif");
			                markerArray[loc].setAttribute("rollIcon", imagesFolder+"maproll_"+lPos+".gif");
				        }
				        if (0 == loc) {
		                    markerArray[loc].setIcon(imagesFolder+"map_home.gif");
			                markerArray[loc].setAttribute("origIcon", imagesFolder+"map_home.gif");
			                markerArray[loc].setAttribute("rollIcon", imagesFolder+"map_home.gif");
				        }
				        mapstraction.addMarker(markerArray[loc]);
		            // ..if this location hasn't been used, just put the normal info
				    } else {
				        normalText = serviceLocations[i].makeDetail();
				    }
                }
            // end previous marker
            
            // code relating to current marker
                
                // add the point to the usedLocs array
				usedLocs[i][0] = coords[0];
				usedLocs[i][1] = coords[1];
				// make and add marker..
				// if the marker is in the same place as a previous one, rightPaneText will not be empty, so use that as a trigger
		        if (0 < rightPaneText.length) {
		            // to make the relevant result display by default in each marker...
		            // ..left pane - set all classes to bubble_link, and the last to input_error
		            leftPaneText = leftPaneText.replace(" input_error", "");
		            leftPaneText = leftPaneText.replaceLastOf("bubble_link", "bubble_link input_error");
		            // ..right pane - set all displays to none, then the last one to a block
		            rightPaneText = rightPaneText.replace("display: block;", "display: none;");
		            rightPaneText = rightPaneText.replaceLastOf("display: none;", "display: block;");
		            // if the image is a counter, changes it to a 'multiple result' counter
		            if (null != image.match("counter.gif")) {
		                image = imagesFolder+'counter_mult.gif';
		            } else {
		                image = imagesFolder+'map_mult_'+j+'.gif';
		            }
		            // make the marker (sending the leftPaneText overload tells the function to create a split display in the info bubble)
				    markerArray[i] = makeMarker(point, image, rollImage, name, rightPaneText, leftPaneText);
				    markerArray[i].setAttribute("issplit", true);
				// if the marker's place has not been used, create a 'normal' marker, without the split display
				} else {
				    markerArray[i] = makeMarker(point, image, rollImage, name, normalText);
				}
				mapstraction.addMarker(markerArray[i]);
				if (true == iOnPage) {j++;}
            // end current marker
			}
		}
		// finally, add the 'home' marker to the map (adding it last means it's on top of all others)
		mapstraction.addMarker(markerArray[0]);
	}
	
	function makeMarker(point, icon, rollIcon, label, rightText, leftText) {
		// leftText is an overload, and indicates that the display bubble should be split
		
		if ('string' == typeof(point) ) {
			var coords = point.split(", ");
			var mapPoint = new LatLonPoint(coords[0], coords[1]);
		} else {
			var mapPoint = point;
		}
		
		// create a marker positioned at a lat/lon 
		my_marker = new Marker(mapPoint);
		
		// add an icon to the marker
		my_marker.setIcon(icon);
		// remove the shadow if this is a 'counter' marker (ie not one of the main results)
		if (null != icon.match("counter")) {
		    my_marker.setShadowIcon(imagesFolder+'null_icon.gif', 0);
		    var size = Array(10,10);
		    var anchor = Array(0,0)
        } else {
		    var size = Array(22,36);
		    var anchor = Array(7,33)
        }
	    my_marker.setIconSize(size);
	    my_marker.setIconAnchor(anchor);
		my_marker.setAttribute("origIcon", icon);
		my_marker.setAttribute("rollIcon", rollIcon);
		
		// add a label to the marker
		my_marker.setLabel(label);
		
		// add info bubble to the marker
		var bubbleContents = (leftText) ? splitBubble(leftText, rightText) : rightText;
		my_marker.setInfoBubble(bubbleContents);
		my_marker.setAttribute("issplit", false);
		my_marker.setAttribute("leftText", leftText);
		my_marker.setAttribute("rightText", rightText);
		
		// display marker 
		return my_marker;
		
	}
	
	function makeLeftLink(position, text, active) {
	    var activeClass = (!active) ? "" : " input_error";
	    return "<a id=\"bubLink"+position+"\" href=\"javascript: showBubbleItem("+position+");\" class=\"bubble_link"+activeClass+"\">"+text+"</a>";
	}
	
	function makeRightLink(position, display, content) {
	    return "<div id=\"bubble"+position+"\" style=\"display: "+display+";\">"+content+"</div>";
	}
	
	function splitBubble(leftText, rightText) {
	
		var text =  "<div style=\"width: 250px; height: 100px; position: relative; margin: 10px; border: 1px black solid;\">"
                    +   "<div style=\"width: 50px; height: 100px; overflow: auto; position: absolute; left: 0; top: 0; border-right: 1px black solid;\">"
                    +       leftText
                    +   "</div>"
                    +   "<div style=\"width: 200px; height: 100px; position: absolute; right: 0; top: 0;\">"
                    +       rightText
                    +   "</div>";
                    +"</div>";
        return text;
    }
	
	function showBubbleItem(number) {
	
	    showItem('bubble'+number);
	    var thisLink = getElem('bubLink'+number);
	    var allLinks = thisLink.parentNode.getElementsByTagName('a');
	    for (var i=0; i<allLinks.length; i++) {
	        allLinks[i].className = allLinks[i].className.replace(" input_error", "");
	    }
	    thisLink.className = thisLink.className + " input_error";
	}
	
	function changeMarker(marker, over) {
		
		mapstraction.removeMarker(marker);
		var image = (true == over) ? marker.getAttribute("rollIcon") : marker.getAttribute("origIcon");
		marker.setIcon(image);
		mapstraction.addMarker(marker);
	}
	
	function minMaxPoints() {
	    
		var coords = Locations[0][0].split(", ");
        var minLat = maxLat = coords[0];
        var minLng = maxLng = coords[1];
		for (var i=1; i<Locations.length; i++) {
			if (undefined !== Locations[i][1]) {
				var coords = Locations[i][0].split(", ");
                if (minLat >= parseFloat(coords[0])) {
                    minLat = coords[0];
                }
                if (minLng >= parseFloat(coords[1])) {
                    minLng = coords[1];
                }
                if (maxLat <= parseFloat(coords[0])) {
                    maxLat = coords[0];
                }
                if (maxLng <= parseFloat(coords[1])) {
                    maxLng = coords[1];
                }
            }
        }
        var latSpan = Math.abs(maxLat - minLat);
        var lngSpan = Math.abs(maxLng - minLng);
        var midPoint = ((latSpan / 2) + parseFloat(minLat)) + ', ' + ((lngSpan / 2) + parseFloat(minLng));
        var latZoom = 15 - (Math.ceil((Math.log((latSpan+0.0116)/0.0116) / Math.log(2))*1.05));
        var lngZoom = 15 - (Math.ceil((Math.log((lngSpan+0.0218)/0.0218) / Math.log(2))*1.05));
        centreMap(midPoint, Math.min(latZoom, lngZoom));
}