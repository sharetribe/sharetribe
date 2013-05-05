function start_analytics(api_key, domain) {
	var _gaq = _gaq || [];
	_gaq.push(['_setAccount', api_key]);
	_gaq.push(['_setDomainName', '.' + domain]);
	_gaq.push(['_addIgnoredOrganic', 'sharetribe']);
	_gaq.push(['_addIgnoredOrganic', 'sharetribe.com']);
	_gaq.push(['_addIgnoredOrganic', 'www.sharetribe.com']); 
	_gaq.push(['_addIgnoredOrganic', 'kassi']); 
	_gaq.push(['_addIgnoredOrganic', 'share tribe']); 
	_gaq.push(['_addIgnoredOrganic', 'kassi.eu']); 
	_gaq.push(['_setAllowLinker', true]);
	_gaq.push(['_trackPageview']);
	_gaq.push(['_trackPageLoadTime']);

	(function() {
		var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	})();
}

