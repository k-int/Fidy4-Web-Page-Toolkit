
	addLoadEvent(unobtrude);

	function unobtrude() {
		
		// R04, R05, R06 code start
		var tabs = getElem('resultsTabs').getElementsByTagName('a');
		for (var i=0; i<tabs.length; i++) {
			tabs[i].onclick = function() {
											var tabLink = this.parentNode.parentNode.getAttribute('id');
											var num = tabLink.slice(-1,tabLink.length);
											showItem('resultsArea'+num);
											
											var tabSpans = document.getElementById('resultsTabs').getElementsByTagName('span');
											for (var j=1; j<tabSpans.length; j++) {
												if (/Left/.test(tabSpans[j].className)) {
													tabSpans[j].className = 'tabLeft';
												} else if (/Mid/.test(tabSpans[j].className)) {
													tabSpans[j].className = 'tabMid';
												} else if (/Right/.test(tabSpans[j].className)) {
													tabSpans[j].className = 'tabRight';
												}
											}
											
											this.parentNode.previousSibling.className = 'thisTabLeft';
											this.parentNode.className = 'thisTabMid';
											this.parentNode.nextSibling.className = 'thisTabRight';
											return false;
										};
		}
		// R04, R05, R06 code end
		
	}
	
