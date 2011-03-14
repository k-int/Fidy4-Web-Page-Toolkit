
	addLoadEvent(unobtrude);

	function unobtrude() {
		
		var cancel = getElem('cancelLocation').getElementsByTagName('a');
		cancel[0].onclick = function() {hideBox('location_screen', 'location_dialog'); return false; };
		getElem('location_dialog').onkeyup = function(evt) {
            var btn = (window.event) ? event.keyCode : evt.keyCode;
            if (btn == 27) {
                hideBox('location_screen', 'location_dialog');
            }
		};
		var cats = getElem('directoryList').getElementsByTagName('a');
		for (var i=0; i<cats.length; i++) {
		    cats[i].onclick = function() {
		        var catCode = this.href.substr(this.href.indexOf('=')+1);
	            if (50 < catCounts[catCode]) {
		            blackBox('location_screen', 'location_dialog', this.innerHTML, catCounts[catCode]);
		            var catInput = getElem('category');
		            catInput.setAttribute("value", catCode);
		            var allResults = getElem('showAllButton');
		            var stem = allResults.getAttribute("href").split('?')[0];
		            allResults.setAttribute("href", stem + "?category="+this.href.substr(this.href.indexOf('=')+1));
		            return false;
		        } else {
		            this.href = resultsPage + "?category=" + catCode;
		        }
		    };
		}
		
	}
	
	function blackBox(item1, item2, selectedCat, catCount) {
		
		var screen = getElem(item1);
		var dialog = getElem(item2);
		var selectedCatName = getElem('selectedCatName');
		var catResultCount = getElem('catResultCount');
		
		var size = getSize('mainContent')
		
		var width = size[0];
		var height = size[1];
		
		screen.style.width = size[0]+30+"px";
		screen.style.height = size[1]+30+"px";
		var margin = (size[0]/2)+15;
		screen.style.marginLeft = -+margin+"px";
		screen.style.visibility = 'visible';
		screen.style.display = 'block';
		
		selectedCatName.innerHTML = selectedCat;
		catResultCount.innerHTML = (null == catCount) ? 0 : catCount;
		
		dialog.style.visibility = 'visible';
		dialog.style.display = 'block';
		
		document.forms['locationForm'].elements['locationInput'].focus();
	}
	