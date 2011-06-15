# There's a lot of hype about mobile web apps being the future of mobile application development, but with my time spent developing for iOS, and seeing how enjoyable/powerful it was, I wasn't convinced. So I took the plunge into PhoneGap, using jQuery Mobile and Backbone.js as my weapons of choice.

# The app will be a fairly simple one, showing off the basic naviagtion features of jQuermy mobile, and some of the audio capabilities of PhoneGap. The content of the app will be driven by a single JSON file that we can easily update.

# The post will go through each file, and the complete phonegap project can be found [here on github](https://github.com/samdalton/mobile-content).

### script.js

# Here's our usual backbone namespace, with models, views and collections. We've got pages inside views to contain the different page types we will encounter.
var backbone = {
    models : {},
    views : {
        pages : {}
    },
    collections : {}
# base is a global reference to our main DOM object. This was required to make jQuery mobile work a bit nicer, and we'll get to it soon.
}, base;

# _Note: I would normally extend the backbone namespace with the name of the app I'm buidling, to ensure that multiple backbone apps in a page won't interfere with each other._

$(function() {
    
    base = $("#base");
    # Launch the app, setting our view, and passing in page_data which contains our parsed JSON file.
    mainApp = new backbone.views.Application( {el : base, pages : page_data } );
    
});

### views/Application.js
# This is the first view that kicks off everything. If you're coming from the iPhone world, consider this to be the (Home|Root)ViewController

$(function() {
    backbone.views.Application = Backbone.View.extend({
        
        initialize : function(args) {                
# Remember the pages variable we passed in during instantiation? We're grabbing it here, and using one of underscore.js' enumerator methods to iterate over each page object. _.map is going to return an array with values equal to what we return in the closure, for each value in args.pages. 
            this.pages = _.map(args.pages, function(page) {
# We're creating a new Page view, and passing in the page data that _.map has given us. 
            return new backbone.views.Page({
                page : page
            });
        });
# Now we have a backbone view for each page to be navigated, so we can call render to kick things off.
            this.render();
        },
        
        render : function() {
# Just as iPhone apps have screen titles when you traverse content hierarchies, we want to be able to give each page a unique title. We need these titles to display on the main screen, so we can show the user what pages are available for them to navigate to. That's why we're collecting them here.
            page_titles = []; 

# \_.each functions much the same as _.map, except it doesn't return anything.
            _.each(this.pages, function(page) {
# Remember that each page is a backbone view, so we're calling render to get the HTML content that makes up the view, and appending it to our view element. As we set our el to be equal to base, we're appending everything to the $("#base") element.
                this.el.append(page.render()); 
# Grab the title and put it in the array, along with a unique id. The id is required for jQuery Mobile, which we will get to shortly.
               page_titles.push({ id : page.page_id(), title : page.page.title });
            }, this);
# Using [icanhazjs](http://icanhazjs.com/), we render the home template, passing in the array of page titles
            this.el.prepend(ich.home({page_titles : page_titles}));
        }
    });
});
