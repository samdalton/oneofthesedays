# A while ago I wrote about a <a href="http://www.oneofthesedaysblog.com/pure-css-dropdown-for-firefox/" title="Pure CSS Dropdown for Firefox | One Of These Days">bare bones CSS dropdown</a>. Given the widespread adoption of jQuery since then, there's little reason to go for the CSS only approach (although it is perhaps more elegant). <a href="http://twitter.com/#!/tedawebguy" title="">@tedawebguy</a> suggested I write a post about a more modern version, so let's go!

# (Note: This should work in all browsers, although I've only tested it in Firefox and Chrome on OSX. Any problems with it will be simple styling issues.)

# Here's the HTML we require:
     # <ul id="nav">
            # <li>
                # Home
                # <ul>
                    # <li>Link 1</li>
                    # <li>Link 2</li>
                # </ul>
            # </li>
            # <li>About</li>
            # <li>
                # Blog
                # <ul>
                    # <li>Blog 1</li>
                    # <li>Blog 2</li>
                # </ul>
            # </li>
            # <li>Contact</li>
        # </ul>
# This is a simple nested list with 4 top level links : Home, About, Blog and Contact. Home and Blog have 2 sublists that we want hidden normally, but visible when their parent list element is hovered over. We can have an arbitrary number of links, but the current (read: lazy) version only allows nesting 1 level deep.

# The styling we will need is fairly straight forward:
# The first style removes the bullets from our list, gives it a reasonable height and padding to ensure that the hover area is user-friendly enough.
    ul {
        list-style-type:none;
        height:30px;
        padding:10px;
    }

# Next we're styling the list elements, making them display inline and giving them a bit of padding and spacing. The border and cursor is not essential, but it makes it easier to see where to hover. Lastly, we're giving it a relative position so that the child lists will be position relative to where this element is i.e. directly below the element you are hovering over.
    ul li {
        display:inline;
        padding:4px 50px;
        border:1px solid #555555;
        cursor:pointer;
        margin:2px;
        position:relative;
    
    }

# To finish our CSS, we're styling the second level list. It's hidden to start with, and given an absolute position just below the top level list. The negative left position may cause some alignment problems in IE, but it's there to offset the indent that browsers put on list elements. 
    ul li ul {
        display:none;
        position:absolute;
        top: 26px;
        left:-15px;
        width: 600px;
    }

# Now that we've structured and styled our navigation menu, we can sprinkle some javascript over it. 

        $(function() {
            $("#nav li").hover(
                function() {
                    $(this).find("ul").fadeIn(100);
                }, 
                function() {
                    $(this).find("ul").fadeOut(100);
                });
            });

# We're including the Google hosted jQuery library as per best practices, and then kicking off with the usual document.ready shortcut that jQuery gives us. We're then setting up a hover event listener on each list element in the top level list. This takes 2 callbacks, one for mouse over and one for mouse out. On mouse over, we're finding any list that may reside inside of the current element and subsequently showing it. The reverse happens on mouse out. Fading was used to make it a bit easier on the eyes, while also allowing the mouse pointer to leave the list area for a few milliseconds. This increases the usability as the user does not have to be quite as accurate when moving the mouse from top-level to sub-list elements. 

# Plugging these 3 components together gives us the following 2 states:

# ![Sample 1](/uploads/2010/12/Screen-shot-2010-12-20-at-5.27.58-PM.png)
# ![Sample 2](/uploads/2010/12/Screen-shot-2010-12-20-at-5.29.59-PM.png)

# If you want a more flexible solution, there's a <a href="http://www.1stwebdesigner.com/freebies/38-jquery-and-css-drop-down-multi-level-menu-solutions/" title="38 jQuery And CSS Drop Down Multi Level Menu Solutions">silly amount of libraries</a> to be found on the web. Hopefully however, this post shows just how simple they are to construct, and may even be useful if you're looking for a lightweight solution.
