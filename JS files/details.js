
	addLoadEvent( unobtrude );
	

	function unobtrude() {
		
		// R08 tab tool start
		var tabs = document.getElementById('detailsTabs').getElementsByTagName('a');
		for (var i=0; i<tabs.length; i++) {
			tabs[i].onclick = function() {
											var tabLink = this.parentNode.getAttribute('id');
											var num = tabLink.slice(-1,tabLink.length);
											showItem('moreDetails'+num);
											
											var divs = document.getElementById('detailsTabs').getElementsByTagName('div');
											for (var j=0; j<tabs.length; j++) {
												divs[j].className = 'tab';
											}
											
											this.parentNode.className='tab current';
											return false;
										};
		}
		// R08 tab tool end
		
	}
	
