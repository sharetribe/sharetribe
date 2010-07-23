/* 
 * Empty value (0.1)
 * by Sagie Maoz (n0nick.net)
 * n0nick@php.net
 *
 * This is a terribly simple plugin (actually, my first), used
 * for the common practice of applying specific content and
 * design (class name) for a form field while it's empty.
 *
 * Copyright (c) 2009 Sagie Maoz <n0nick@php.net>
 * Licensed under the GPL license, see http://www.gnu.org/licenses/gpl-3.0.html 
 *
 *
 * NOTE: This script requires jQuery to work.  Download jQuery at www.jquery.com
 *
 */
 
(function($) {
	$.fn.empty_value = function(empty_value, reset, class_name)
	{
		if (typeof empty_value 	!= 'string')  { empty_value = ''; }
		if (typeof reset 		!= 'boolean') { reset = true; }
		if (typeof class_name 	!= 'string')  { class_name = 'empty'; }
		
		return this.each(function()
		{
			$(this).focus(function()
			{
				if ($(this).hasClass(class_name))
				{
					$(this).removeClass(class_name);
					if (reset) { $(this).val('').attr('title', ''); }
				}
			}).blur(function()
			{
				var val = $(this).val();
				if (!val || val == empty_value)
				{
					$(this).addClass(class_name).val(empty_value).attr('title', $(this).val());
				}
			}).blur();
		});
	};
})(jQuery);