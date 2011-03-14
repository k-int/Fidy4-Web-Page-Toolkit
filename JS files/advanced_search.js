/**
 * Throughout, whitespace is defined as one of the characters
 *  "\t" TAB \u0009
 *  "\n" LF  \u000A
 *  "\r" CR  \u000D
 *  " "  SPC \u0020
 *
 * This does not use Javascript's "\s" because that includes non-breaking
 * spaces (and also some other characters).
 */


/**
 * Determine whether a node's text content is entirely whitespace.
 *
 * @param nod  A node implementing the |CharacterData| interface (i.e.,
 *             a |Text|, |Comment|, or |CDATASection| node
 * @return     True if all of the text content of |nod| is whitespace,
 *             otherwise false.
 */
function is_all_ws( nod )
{
  // Use ECMA-262 Edition 3 String and RegExp features
  return !(/[^\t\n\r ]/.test(nod.data));
}


/**
 * Determine if a node should be ignored by the iterator functions.
 *
 * @param nod  An object implementing the DOM1 |Node| interface.
 * @return     true if the node is:
 *                1) A |Text| node that is all whitespace
 *                2) A |Comment| node
 *             and otherwise false.
 */

function is_ignorable( nod )
{
  return ( nod.nodeType == 8) || // A comment node
         ( (nod.nodeType == 3) && is_all_ws(nod) ); // a text node, all ws
}

/**
 * Version of |previousSibling| that skips nodes that are entirely
 * whitespace or comments.  (Normally |previousSibling| is a property
 * of all DOM nodes that gives the sibling node, the node that is
 * a child of the same parent, that occurs immediately before the
 * reference node.)
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The closest previous sibling to |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
function node_before( sib )
{
  while ((sib = sib.previousSibling)) {
    if (!is_ignorable(sib)) return sib;
  }
  return null;
}

/**
 * Version of |nextSibling| that skips nodes that are entirely
 * whitespace or comments.
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The closest next sibling to |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
function node_after( sib )
{
  while ((sib = sib.nextSibling)) {
    if (!is_ignorable(sib)) return sib;
  }
  return null;
}

/**
 * Version of |lastChild| that skips nodes that are entirely
 * whitespace or comments.  (Normally |lastChild| is a property
 * of all DOM nodes that gives the last of the nodes contained
 * directly in the reference node.)
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The last child of |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
function last_child( par )
{
  var res=par.lastChild;
  while (res) {
    if (!is_ignorable(res)) return res;
    res = res.previousSibling;
  }
  return null;
}

/**
 * Version of |firstChild| that skips nodes that are entirely
 * whitespace and comments.
 *
 * @param sib  The reference node.
 * @return     Either:
 *               1) The first child of |sib| that is not
 *                  ignorable according to |is_ignorable|, or
 *               2) null if no such node exists.
 */
function first_child( par )
{
  var res=par.firstChild;
  while (res) {
    if (!is_ignorable(res)) return res;
    res = res.nextSibling;
  }
  return null;
}

/**
 * Version of |data| that doesn't include whitespace at the beginning
 * and end and normalizes all whitespace to a single space.  (Normally
 * |data| is a property of text nodes that gives the text of the node.)
 *
 * @param txt  The text node whose data should be returned
 * @return     A string giving the contents of the text node with
 *             whitespace collapsed.
 */
function data_of( txt )
{
  var data = txt.data;
  // Use ECMA-262 Edition 3 String and RegExp features
  data = data.replace(/[\t\n\r ]+/g, " ");
  if (data.charAt(0) == " ")
    data = data.substring(1, data.length);
  if (data.charAt(data.length - 1) == " ")
    data = data.substring(0, data.length - 1);
  return data;
}


	addLoadEvent(unobtrude);

	function unobtrude() {
        // S09, S03, S08 code start
		document.forms['advSearchForm'].onsubmit = function() { return check_advanced('title', 'category', 'wheelchairAccess', 'specialNeeds', 'filters', 'eligibilityCriteria', 'referralCriteria', 'accessChannel', 'language'); };
		document.forms['advSearchForm'].action = resultsPage;
        // S09, S03, S08 code end
        
	    hideItem('moreOptions1');
	    showItem('moreOptionsLink');
		var link = getElem('moreOptionsLink');
		link.onclick=function(){
								showHide('moreOptions1');
								var arrow = this.firstChild.getAttribute('id');
								swapArrow(arrow, 'circle-trans-down.gif', 'circle-trans-up.gif');
								return false;
								};
		var catBox = getElem("categoryList");
		catBox.onchange = function () {
		                                catCheck(catBox.value);
		                              };
		catCheck(catBox.value);
		getElem('subcat-zero').disabled = false;
		showItem('advSearchSubcat');
		getElem('selectSubcat').parentNode.removeChild(getElem('selectSubcat'));
	}
	
	function check_advanced() {
        // S09, S03, S08 code start
        var errors = 0;
        for (var i=0; i<arguments.length; i++) {
            var item = document.forms['advSearchForm'].elements[arguments[i]];
            if (('checkbox' == item.type && false == item.checked) || 1 > item.value.replace(/^\s+|\s+$/g, '').length) {
                errors++;
            }
        }
        if (errors < arguments.length) {
            return true;
        } else {
            var target = getElem('formErrorHelp');
	        target.className = "input_error";
	        target.style.fontWeight = "bold";
	        if (!getElem('formErrorMessage')) {
	            var additionalText = document.createElement("p");
	            additionalText.id = "formErrorMessage";
	            additionalText.className = "input_error";
	            additionalText.innerHTML = "<b>No search conditions found.  Please enter something to search for.</b>";
	            target.appendChild(additionalText);
	            alert('No search conditions found.  Please enter something to search for.');
	        }
            for (var i=0; i<arguments.length; i++) {
                var item = document.forms['advSearchForm'].elements[arguments[i]];
                if ('checkbox' == item.type) {
                    var errorThing = item.parentNode.getElementsByTagName("span").item(0);
                    errorThing.className = (null === errorThing.className.match("input_error")) ? errorThing.className + " input_error" : errorThing.className;
                } else {
                    item.className = (null === item.className.match("input_error")) ? item.className + " input_error" : item.className;
                }
            }
            return false;
        }
        // S09, S03, S08 code end
    }

	function catCheck(category) {
		
		var subcatDiv = getElem('advSearchSubcat');
	    for (var i=0; i<subcatDiv.childNodes.length; i++) {
	        if ('DIV' == subcatDiv.childNodes[i].nodeName) {
	            var subcatID = subcatDiv.childNodes[i];
	            clearListSelection(subcatID.id)
	            hideItem(subcatID.id);
	        }
	    }
		if ('' != category) {
		    hideItem('subcat-zero');
		    getElem('subcat-zero').disabled = true;
		    showHide('subcat-'+category);
		    first_child2(getElem('subcat-'+category)).disabled = false;
		} else {
		    showHide('subcat-zero');
		    getElem('subcat-zero').disabled = false;
		}
    }
function first_child2( par )
{
  var res=par.firstChild;
  while (res) {
    if (!is_ignorable(res)) return res;
    res = res.nextSibling;
  }
  return null;
}


    function clearListSelection(subcatList) {  
		var list2=getElem(subcatList);
		var list=first_child2(list2);

        for (var i=0; i<list.options.length; i++) {
            list.options[i].selected = false;
		    list.disabled = true;
        }
        list.options[0].selected = true;
}