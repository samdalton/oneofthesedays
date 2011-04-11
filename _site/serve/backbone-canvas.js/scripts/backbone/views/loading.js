$(function() {
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
});