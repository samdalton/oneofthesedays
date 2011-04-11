$(function() {
window.Cannon = Backbone.Model.extend({
       
   url : 'http://oneofthesedaysblog.com/server/backbone-canvas/sleep.php',
   
   defaults : {
       // a new cannon has 100 cannon balls 
       ammo : 100
   },
   
   fire : function(callback) {
       // only fire if we have positive ammo
       if (this.get('ammo')) {
           originalAmmo = this.get('ammo');
           this.save({ ammo : (originalAmmo - 1) }, {success : callback, error : callback });
       }
   }
   
});
});