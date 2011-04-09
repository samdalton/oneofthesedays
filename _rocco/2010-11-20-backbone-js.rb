[caption id="attachment_395" align="alignright" width="441" caption="Would you like extra spine with that?"]<a href="http://www.oneofthesedaysblog.com/wp-content/uploads/2010/11/Screen-shot-2010-11-20-at-7.13.37-PM.png"><img src="http://www.oneofthesedaysblog.com/wp-content/uploads/2010/11/Screen-shot-2010-11-20-at-7.13.37-PM.png" alt="Backbone JS" title="Backbone JS" width="441" height="154" class="size-full wp-image-395" /></a>[/caption]Since the arrival of <a href="http://jquery.com/" title="jQuery: The Write Less, Do More, JavaScript Library">jQuery</a> some years ago, there hasn't been much else in the Javascript development landscape that has made things <a href="http://www.zurb.com/playground/jquery-raptorize" title="Raptorize: An awesome jQuery plugin that unleahes a Raptor - ZURB Playground - ZURB.com">more fun</a>. <a href="http://documentcloud.github.com/backbone/" title="Backbone.js">Backbone.js</a> is a pleasant break from this period however, making JS work positively thrilling.

Backbone.js is a simple, very lightweight MVC framework built on jQuery and <a href="http://documentcloud.github.com/underscore/" title="Underscore.js">Underscore.js</a>, a "utility belt for Javascript". As with any MVC framework, the core premise of Backbone is to separate an application's representation and storage of data, from the presentation of it. 2 main classes provide this functionality, Backbone.Model and Backbone.View. The neat thing is that when you associate a view with a model, any changes to the model will be reflected in the view without you having to write any linking code. 

This sounds all well and good, but is it really that useful? Yes. Keen to get my teeth into it, I rewrote <a href="http://vitalgiftsapp.com" title="Vital Gifts - Good Gifts for Great People">Vital Gifts</a> app with it. The process took less time than the initial version, and the end result was a marginally larger Javascript file that executed faster while saving a large proportion of my sanity. The reason for this usefulness stems from the modularity it lends to your application; you can easily create self contained visual elements that have all of the data persistence and manipulation they need, and place them onto the page with one line. To illustrate this modularity, let's create a simple friend selector that could be easily fitted out to use the Facebook Graph API.

<pre class='brush:javascript'>
window.User = Backbone.Model.extend({});
</pre>
This creates an empty model that we can use to store information about the selected friend. Note that we're not specifying any attributes such as name or photo. This is because the Backbone model is just a JSON object, and so no schema is necessary - we can add and fetch attributes however we see fit.

In a typical MVC setup, the view would contain a template with rudimentary data manipulations. Any events received by the view are sent to the controller for processing, and then results are sent back to the view. Backbone 'breaks' this model slightly by binding changes to the model directly with the view object. The results are still passable however, with the use of a template framework such as <a href="http://mustache.github.com/" title="&#123;&#123; mustache }}">Mustache</a>. We can use the Backbone view object for controller style logic, and keep the presentation in a template.

<pre class='brush:javascript'>
window.UserView = Backbone.View.extend({

    model : new User, // create a new model to store the selected user

    el : $("#friend-selector"), // the text field we're using for the selector

    // we want to listen for 2 events on the text field
    events : {
        "focus"     : "selectInput",
        "keyup"  : "friendSelected",
    },

</pre>
This first section is all we need to get our view up and running. We tell the view what model it represents, what DOM element it is going to use, and we define a set of event/callback pairs to handle user interaction. To do the actual autocompletion we will use the <a href="http://bassistance.de/jquery-plugins/jquery-plugin-autocomplete/" title="bassistance.de &raquo; jQuery plugin: Autocomplete">jQuery autocomplete library</a>.

<pre class='brush:javascript'>
    initialize : function(friends) {
        // set up autocomplete
        this.el.autocomplete(friends, {
            minChars: 0,
            width: 310,
            matchContains: false,
            autoFill: false,
            formatItem: function (row, i, max) {
               img = "<img src='" + row.picture + "' width='50' height='50' alt='friend-picture' />";
               return img + row.name;
            },
            formatMatch: function (row, i, max) {
               return row.name;
            },
            formatResult: function (row) {
               return row.name;
            }
       });

        // bind this object to the form, so we can access it from the result event
        this.el.data('scope', this);
        this.el.result(function(e, data, formatted) {
            $(e.target).data('scope').autocompleteSelected(data);
        });
    },
</pre>

I won't go into detail about the autocomplete library, as the documentation on it is fairly comprehensive. We are using the initialize method to take in an array of friends that we want to be searchable in the element - this functions exactly as a typical object constructor. The caveat with this however is the last section, which is unfortunately an ugly solution. The callback for the autocomplete plugin is set with the 'result' method. From within this, we need to be able to call a method on the view object so that the model can be updated. The view won't be in the scope of the autocomplete plugin however, so we are using the data property of the text field to store a reference to the view object. Both the autocomplete and the view model are attached to the same element so the data property acts like a form of shared memory.

<pre class='brush:javascript'>
    selectInput : function(e) {
        $(e.target).select();
    },

    autocompleteSelected : function(friend) {
        if (friend != null) {
            this.model.set({
                name : friend.name
            }); 
        }
    },

    friendSelected : function(e) {
        this.model.set({
            name : this.el.val(),
        });
    
        this.el.search(); // see if they typed in a correct name
    }
});
</pre>

selectInput is purely a convenience for the user. It will result in the contents of the text field becoming highlighted when clicked on, making it easy to type in a new friend. It should save the user 1 click on average.

autocompleteSelected is called when the user selects a friend that has been autocompleted. It calls 'set' on the model and sets the name parameter to be the chosen friend's name.

friendSelected is called on the keyUp event. It is required in case the user wants to type in a friend that is not registered in the autocomplete. If this were to happen, the autocomplete plugin would never match it, and so the result callback would never be fired. This would leave the user model empty, even though the user has typed in a name. When the event is triggered, the model is set to be the current value of the text field, and 'search' is called on the text field. Search is a method that comes from the autocomplete plugin, and it simply forces the plugin to see if the current value is in its list. If it can't find it, we have already updated the model, keeping it consistent, and if it does find it, autocompleteSelected will be called and the model will still have the friend's name.

The 2 objects above are all that we need to have a self contained friend selector. To render it on the page, we simply create a new UserView object and pass in a list of friends, assumed for this example to exist as a global variable called 'friends'.

<pre class='brush:javascript'>
user = new UserView(window.friends);
</pre>

That's it!
