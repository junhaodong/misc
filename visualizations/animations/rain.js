var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");

var paused = false;

var makeRain = function(x,y,ctx){
    return{
	    x : x,
	    y : y,
	    ctx : ctx,
	    dy : 2,
	    color : "#33A1DE",
	    draw : function(){
	        // Bezier curve raindrops: http://hernan.amiune.com/labs/particle-system/hello-world.html
	        ctx.fillStyle=this.color;
	        ctx.beginPath();
	        ctx.save(); // save canvas state before translation to restore later
	        ctx.translate(this.x,this.y); // translates canvas by remapping (0,0) to (this.x, this.y)
	        ctx.bezierCurveTo(0,2.5, 0,5, 2.5,7.5);
	        ctx.bezierCurveTo(5,10, 6,13, 5,15);
	        ctx.bezierCurveTo(3,20, -3,20, -5,15);
	        ctx.bezierCurveTo(-6,13, -5,10, -2.5,7.5);
	        ctx.bezierCurveTo(0,5, 0,2.5, 0,0);
	        ctx.fill();
	        ctx.restore();
	    },
	    move : function(){
	        this.y+= + this.dy;
	    }
    };
};

var autoRain = function(){
    var x = canvas.width*Math.random();
    var y = 10*Math.random();
    rain.push(makeRain(x,y,ctx));
};

var start = function(){
    if (paused)
	    paused = false;
    rainEvent = window.setInterval(autoRain, 50);
};

var stop = function(){
    window.clearInterval(rainEvent);
};

var pause = function(){
    paused = !paused;
    stop();
};

var update = function(){
    if (paused){
 	    window.requestAnimationFrame(update);
	    return;
    }
    ctx.fillStyle="#ffffff";
    ctx.fillRect(0,0,canvas.width,canvas.height);
    for (var i = 0; i < rain.length; i++){
	    rain[i].move();
	    if (rain[i].y+5 >= canvas.height)
	        rain.splice(i,1);
	    else
	        rain[i].draw();
    }
    window.requestAnimationFrame(update);
};

var clicked = function(e){
    var x = e.offsetX;
    var y = e.offsetY;
    var raindrop = makeRain(x,y,ctx);
    rain.push(raindrop);
};

var rain = [];
var rainEvent;
var startB = document.getElementById("start");
var stopB = document.getElementById("stop");
var pauseB = document.getElementById("pause");


startB.addEventListener("click", start);
stopB.addEventListener("click", stop);
pauseB.addEventListener("click", pause);
canvas.addEventListener("click", clicked);

window.requestAnimationFrame(update);
