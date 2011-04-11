$(function() {
    window.BallView = Backbone.View.extend({
        
        el : document.getElementById('firingRange'),
            
        initialize : function() {
            _.bindAll(this, 'render', 'clear', 'animate', 'move');
            
            this.context = this.el.getContext('2d');
            this.w = $(this.el).width();
            this.h = $(this.el).height();
            
            this.reset();
        },
        
        render : function() {
            this.clear();
            this.context.strokeStyle = "#000";
            this.context.fillStyle = "#000";
            this.context.beginPath();
            this.context.arc(this.x, this.y, 12, 0, Math.PI*2, true);
            this.context.closePath();
            this.context.stroke();
            this.context.fill();
        },
        
        clear : function() {
        	this.context.clearRect(0,0,this.w,this.h);
            this.context.beginPath();
        },
        
        reset : function() {
            this.x = 0;
            this.y = this.h;

            this.dx = 1;
            this.dy = 0;
            
            this.vy0 = 1;
            
            this.g = 0.1;
            this.t = 0;
        },
        
        animate : function() {
            if (this.interval) {
                clearInterval(this.interval);
            }
            this.reset();
            this.interval = setInterval(this.move, 10);
        },
        
        move : function() {
            if (this.x >= this.w + 15) {
                clearInterval(this.interval);
            }  
                    
            this.dy = this.vy0 - (this.g * this.t);
                    
            this.x += this.dx;
            this.y -= this.dy;
            
            this.t += 0.1;
            
            this.render();
        }
        
    });
    
});