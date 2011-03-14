
	function getSize(thing) {
		
		var size = new Array(2);
		var target = getElem(thing);
		
		size[0] = target.offsetWidth;
		size[1] = target.offsetHeight;
		
		return size;
		
	}
	
	
	function hideBox(item1, item2) {
		
		var screen = getElem(item1);
		var dialog = getElem(item2);
		
		screen.style.visibility = 'hidden';
		screen.style.display = 'none';
		
		dialog.style.visibility = 'hidden';
		dialog.style.display = 'none';
		
	}

	
	function showItem(item) {
		
		var target = getElem(item);
		var stem = item.replace(/[\d]/g, '');
		hideall(stem);
		
		target.style.visibility = 'visible';
		target.style.display = 'block';
		
	}

	function hideItem(item) {
		
		var target = getElem(item);
		
		target.style.visibility = 'hidden';
		target.style.display = 'none';
		
	}

	function showHide(item) {
		
		var target = getElem(item);
			
		if ('visible' == target.style.visibility) {
			target.style.visibility = 'hidden';
			target.style.display = 'none';
		} else {
			target.style.visibility = 'visible';
			target.style.display = 'block';
		}
	}

	function hideall(stem) {
		var el;
		for (var i = 0; i<101; i++) {
			if (el = getElem(stem+i)) {
				el.style.visibility = 'hidden';
				el.style.display = 'none';
			}
		}
	}
	
	function showall(stem) {
		var el;
		for (var i = 0; i<101; i++) {
			if (el = getElem(stem+i)) {
				el.style.visibility = 'visible';
				el.style.display = 'block';
			}
		}
	}
	
    function compressItem(itemType, numItems) {
        
        getElem(itemType+"Link1").parentNode.innerHTML = getElem(itemType+"Link1").parentNode.innerHTML + "<br /><a id=\"" + itemType + "Control\" href=\"#\">Show " + (numItems - 3) + " more</a>";
		getElem(itemType+"Control").onclick = function() { showItems(itemType, 4, numItems); return false; };
		hideItems(itemType, 4, numItems);
		
    }
    
    function showItems(stem, start, finish) {
		
		var begin = (start) ? start : 0;
		var end = (finish) ? finish+1 : 1001;
		var el;
		
		for (var i=begin; i<end; i++) {
			if (el = getElem(stem+"Link"+i)) {
				el.style.visibility = 'visible';
				el.style.display = 'block';
			}
		}
		
		var controlLink = getElem(stem+'Control');
		controlLink.innerHTML = controlLink.innerHTML.replace('Show', 'Hide');
		controlLink.onclick = function() { hideItems(stem, start, finish); return false; };
	}
	
	function hideItems(stem, start, finish) {
		
		var begin = (start) ? start : 0;
		var end = (finish) ? finish+1 : 1001;
		var el;
		
		for (var i=begin; i<end; i++) {
			if (el = getElem(stem+"Link"+i)) {
				el.style.visibility = 'hidden';
				el.style.display = 'none';
			}
		}
		
		var controlLink = getElem(stem+'Control');
		controlLink.innerHTML = controlLink.innerHTML.replace('Hide', 'Show');
		controlLink.onclick = function() { showItems(stem, start, finish); return false; };
	}
	
	function swapText(id, oldtext, newtext) {
		
		var target = getElem(id);
		
		if (oldtext == target.innerHTML) {
			target.innerHTML = newtext;
		} else {
			target.innerHTML = oldtext;
		}
	}
	
	function swapArrow(id, setState, newState) {
		
		var img = getElem(id);
		img.src = (img.src.match(imagesFolder + newState) ? imagesFolder + setState : imagesFolder + newState) ;
		
	}
	

	function deactivate(formName, item) {
		
		document.forms[formName].elements[item].disabled = true;
		
	}
	
	
	function addLoadEvent(func) {
		var oldonload = window.onload;
		if (typeof window.onload != 'function') {
			window.onload = func;
		} else {
			window.onload = function() {
			if (oldonload) {
				oldonload();
			}
				func();
			}
		}
	}
	
	function getElem(thing) {
		
		if (document.getElementById(thing)) {
			var elem = document.getElementById(thing);
		} else if (document.all){
			var elem = document.all[thing];
		}
		
		return elem; 
		
    }
    
	function check_form(formName) {
		
		var errors = 0;
		for (var i=1; i<arguments.length; i++) {
		    var item = document.forms[formName].elements[arguments[i]];
		    if (1 > item.value.replace(/^\s+|\s+$/g, '').length) {
		        item.className = (null === item.className.match("input_error")) ? item.className + " input_error" : item.className;
		        if ("SPAN" != item.nextSibling.nodeName) {
		            star = document.createElement("span");
		            star.className = "input_error";
		            star.innerHTML="*";
		            item.parentNode.insertBefore(star, item.nextSibling);
		        }
		        errors++;
		    }
		}
		if (0 == errors) {
		    return true;
		} else {
		    var target = getElem('formErrorHelp');
			target.innerHTML = "Some required information is missing from the form (indicated by the * and <span class=\"input_error\">red backgrounds</span> on boxes)";
		    alert('Some required information is missing from the form (indicated by the * and red backgrounds on boxes)');
		    return false;
		}
	}
	
    String.prototype.replaceLastOf = function(search, replacement) {
        if (!search || search.length == 0) return this;
        var i = this.toLowerCase().lastIndexOf(search.toLowerCase());
        return (i >= 0) ? this.substr(0,i) + replacement + this.substr(i+search.length) : this;
    }
	
