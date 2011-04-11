 # The CSS dropdown from the last post works in all browsers except IE6! I've made a few minor changes to ensure it displays correctly in IE7 however. 

.Navigation li ul { 
	  	background:#FFFFFF none repeat scroll 0 0;
		border:1px solid #000000;
		padding:4px;
		position:absolute;
		width:720px;
		top:30px;
		overflow:visible;
		height:42px;
		left:-135px;
		z-index:10;
	}

# A z-index was applied to keep it above any content that might be below, and a left position was added to move the dropdown over slightly. 

# Now as for IE6, we can get it to work with some simple javascript. Not the most accessible solution but really, if you're using IE6 and you have javascript disabled, you deserve it. 

# Using jQuery we can add the hover event to our list with a few lines */
$(function() {
	$(".Navigation ul li").hover(
	function () {
		$(this).css("overflow", "visible");
	},
	function () {
		$(this).css("overflow", "hidden");
	});
});

# and voila! Simply setting the overflow property when each list element is hovered is enough to make the dropdown work. 

# Now if you don't want the extra overhead of the jquery library you can use conditional comments to only grab it if they're using IE. 
<!--[if IE 6]>
<script src='http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js' type='text/javascript'></script>
<script type='text/javascript'>
$(function() {
	$('.Navigation ul li').hover(
	function () {
		$(this).css('overflow', 'visible');
	},
	function () {
		$(this).css('overflow', 'hidden');
	});
});
</script>
<![endif]-->

