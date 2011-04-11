# As <a href="http://www.oneofthesedaysblog.com/backbone-js/" title="Backbone.js | One Of These Days">stated previously</a>, <a href="http://documentcloud.github.com/backbone/" title="Backbone.js">Backbone.js</a> is buckets of fun to work with. In the spirit of this praise, I thought I'd have a play with it, and see how it could work with HTML5 animation development.

# The end result is a cannon that shoots a small cannon ball, <a href="http://www.oneofthesedaysblog.com/serve/backbone-canvas/index.html" title="Backbone.js">viewable here</a>. While the example is entirely contrived, it demonstrates a number of aspects of Backbone.js, and well, is kind of fun. This first post will look at the Backbone.js portion of the app, and a second post will follow to briefly go over the canvas animation.

# ![Keeping the backbone views and models in separate files and folders is a good way of helping you navigate your app. For larger scale projects, this is essential.](/uploads/2011/02/Screen-shot-2011-02-12-at-4.20.35-PM.png)

# The first file we need is our main html page, which will include all of the necessary javascript files, a bit of styling, and the 2 HTML elements we need for our cannon. The cannon image is what we click to fire the cannon, and the firingRange canvas is where the cannon ball will be animated.

# Next, we'll look at the main.js file, as this is what kicks off the app. 
$(function() {                
    myCannon = new CannonView();
});

# That's it. This will be executed when the DOM is ready, and will ensure our cannon is fully functioning. This file is a clear example of how backbone can help organise and DRY up your code. There's no doubt as to where the execution flow of the app starts, and from here, it is easy to follow through. This makes testing easier, debugging easier, and allows other people to get up to speed with the code in a far shorter period of time (including yourself!).

window.CannonView = Backbone.View.extend({

    el : $('a.do'),

    model : new Cannon,

    events : {            
        'click' : 'lightFuse'            
    },

    initialize : function() {
        _.bindAll(this, 'fire');
        this.ball = new BallView;

        loadingView = new LoadingView;
        Backbone.beforeSync = loadingView.render;
        Backbone.afterSync = loadingView.remove;
    },

    lightFuse : function() {
        this.model.fire(this.fire);
    },

    fire : function() {
        this.ball.animate();
    }

});

# One of three, the cannon view takes care of our event handling as well as setting up the other 2 views. It's given the anchor tag as its element, allowing us to easily bind a click event. The model it's given is Cannon, a simple model that will store the amount of ammo available, and persist this to a server.

# When the cannon is clicked, lightFuse is called, which subsequently calls fire on the Cannon model. We're passing in the fire function, which the model will treat as a callback and call it once firing has completed at the model level. This call will cause animate to be called on the ball, resulting in fancy animation. Note that in the initialize method we are using the underscore.js bindAll method to ensure that when the callback is passed into the model, it is <a href="http://stackoverflow.com/questions/183214/javascript-callback-scope" title="events - JavaScript Callback Scope - Stack Overflow">still scoped to CannonView</a> and not Cannon. 

# The last area of interest in this view is the 3 lines regarding the loadingView. The loading view is essentially our fuse animation. It seems appropriate to illustrate the loading of the cannon ball with such a depiction, and so we need a way of showing this when we click the cannon, and hiding it after it's fired. While we could use the success callback in the Backbone.sync object, doing so would require us to put code related to the loading down in the cannon model. In keeping with a strict-as-possible separation of concerns view, it would be more appropriate to have this logic higher up, in the view class itself. As the fire method on the model is asynchronous, we cannot simply show the fuse before calling fire, and hide it afterwards. To achieve the functionality we want, I thought it would be an interesting exercise to edit the Backbone.sync object itself, in the backbone source. While this may not be the most appropriate way of doing this, it should at least be educational.

# Two lines are added to the top of backbone.js to allow us to set before and after callbacks.
Backbone.beforeSync = function(){};
Backbone.afterSync = function(){};

# The last edit needs to go in the Backbone.sync object.

    Backbone.sync = function(method, model, success, error) {            
        var params = {
          
          # here is where our after callbacks are run
          success: function() { success(); Backbone.afterSync(); },
          error: function() { error(); Backbone.afterSync(); }
          
        };

 # run our before callback
        Backbone.beforeSync();         $.ajax(params);
      };

# We're modifying the success and error callbacks to also execute the afterSync callback. It's included in both success and error, as even if there is an error we want to stop the fuse from showing. Before we execute the ajax request, we call beforeSync. This will occur synchronously, and so $.ajax will be called afterwards. On completion of the request, afterSync will be called. As we have hooked loadingView.render to before, and loadingView.remove to after, we will now see the fuse light on click, and stop after firing. <em>Note: if this way of doing things has made anyone cringe or question, I'd love to hear from you in the comments or email about an alternative way of achieving this. My justification is that the edits to the source are in no way connected semantically to anything in the app, and the functionality could fit a wide number of use cases.</em>

# While we're on the topic of loading, let's take a quick look at the loading view. It's nothing fancy, just a view that on rendering, puts a span element containing and image into the DOM. We've bound render and remove to itself so that when inside the Backbone.sync callback, they still have  the correct scope. 

window.LoadingView = Backbone.View.extend({

   tagName : 'span',

   className : 'loading',

   initialize : function() {
       _.bindAll(this, "render", "remove");
   },

   render : function() {
       $('body').append($(this.el).html("<img src='images/fuse.gif'/>"));
   }

});

# The final view for this app is the ball view. This is where our HTML5 canvas magic happens, and so for brevity, this will be covered in a separate post. The view has an animate method however, which when called by the cannon view, will show the cannon ball flying out of the cannon. This is a great example of how backbone can hide away implementation details. The main app knows nothing of the canvas animation, and we can easily swap this out for whatever we want. All the cannon view cares about is that there is an animate method it can call, and the rest will follow.

# Finally, we come to the cannon model itself. In order to demonstrate the loading functionality, it was necessary to create some form of delay between calling fire on the model, and having the model state update. A simple php script was used that would randomly sleep for between 0 and 2 seconds.
sleep(rand(0,2));

# and now our model:

window.Cannon = Backbone.Model.extend({

# our delay script
   url : 'http://oneofthesedaysblog.com/server/backbone-canvas/sleep.php', 
   defaults : {
# a new cannon has 100 cannon balls
ammo : 100 
   },

   fire : function(callback) {
       # only fire if we have positive ammo
       if (this.get('ammo') > 0) {
           this.save({ ammo : (this.get('ammo') - 1) }, {success : callback, error : callback });
       }
   }
});

# We're giving the cannon model a single attribute called ammo, which will keep track of how many times the cannon has been fired. This is being set an arbitrary value of 100, such that after 100 firings, it won't fire again until the page is reloaded. The fire method is also here, and we can see that it takes in the callback we pass in from the view. If there is positive ammo, the model will try and save this to the server, with a value of ammo decreased by one. In the case of our simple script, we're not really concerned whether or not the sync is successful, so I've set the callback to run on either success or error.

# If we look back at the Backbone.sync object, we can see that this callback is being executed in the line we modified:
success:      function() { success(); Backbone.afterSync(); }

# It's running the callback we pass in to save(), as well as our afterSync callback.

# That concludes the overview of the cannon app, with the exception of the ball view, which will be covered in another post. Hopefully this has been useful in, once again, highlighting the advantages of using simple MVC framework such as backbone. Our presentation and business logic is clearly separated, and the components are decoupled sufficiently such that we can easily make changes without breaking the rest of the app. The structure of the app is also useful for navigating the various areas of functionality, resulting in <a href="http://www.osnews.com/story/19266/WTFs_m" title="WTFs/m">fewer WTFs per minute</a>.
