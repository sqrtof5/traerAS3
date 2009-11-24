package {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import flash.geom.Vector3D;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	
	[ SWF (width=600, height=600, backgroundColor=0xFFFFFF, frameRate=31) ]
	
	public class ClothTest extends Sprite {
		
		[ Embed (source="_assets/handle.png") ]
		public var Handle:Class;
		
		private var s				:ParticleSystem;

		private var gridSize		:uint = 8;
		private var particles		:Array;
		
		private var handle1			:MovieClip;
		private var handle2			:MovieClip;
		
		function ClothTest() {
			
			particles = [];
			s = new ParticleSystem(new Vector3D(0, 3.2, 0), .06);
			
			var sx:uint = 200;
			var sy:uint = 80;
			var sp:uint = 25;
			var i:uint;
			var j:uint;
			
			// create grid of particles
				for (i=0; i<gridSize; i++) {
					var _row_particles:Vector.<Particle> = new Vector.<Particle>;
					for (j=0; j<gridSize; j++) {
						_row_particles.push( s.makeParticle(.8, new Vector3D(sx+j*sp, sy+i*sp, 0)) );
						
					}
					particles.push(_row_particles);
				}
			
			// create springs
				for (i=0; i<gridSize; i++) { //horizontal
					for (j=0; j<gridSize-1; j++) {
						s.makeSpring(particles[i][j], particles[i][j+1], 1, .6, sp);
					}
				}
				for (i=0; i<gridSize-1; i++) { //vertical
					for (j=0; j<gridSize; j++) {
						s.makeSpring(particles[i][j], particles[i+1][j], 1, .6, sp);
					}
				}
			
			// draggable handles
				handle1 = new MovieClip();
				addChild(handle1);
				handle1.addChild(new Handle() as Bitmap);
				handle1.x = particles[0][0].position.x -16;
				handle1.y = particles[0][0].position.y -16;
				
				handle2 = new MovieClip();
				addChild(handle2);
				handle2.addChild(new Handle() as Bitmap);
				handle2.x = particles[0][gridSize-1].position.x -16;
				handle2.y = particles[0][gridSize-1].position.y -16;
				
				particles[0][0].makeFixed();
				particles[0][gridSize-1].makeFixed();
				
				handle1.buttonMode = handle2.buttonMode = true;
				handle1.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
				handle2.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
			
			// render
				addEventListener(Event.ENTER_FRAME, render);
			
		}
		
		private function handleMouseEvents(evt:MouseEvent):void {
			
			switch (evt.type) {
				
				case MouseEvent.MOUSE_DOWN:
					evt.currentTarget.startDrag();
					stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
					break;
				
				case MouseEvent.MOUSE_UP:
					handle1.stopDrag();
					handle2.stopDrag();
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
					break;
				
			}
			
		}
		
		private function render(evt:Event):void {
			
			var i:uint;
			var j:uint;
			
			particles[0][0].position.x = handle1.x +16;
			particles[0][0].position.y = handle1.y +16;
		
			particles[0][gridSize-1].position.x = handle2.x +16;
			particles[0][gridSize-1].position.y = handle2.y +16;
			
			s.tick(1);
			
			graphics.clear();
			graphics.lineStyle(1, 0x555555);
			
			for (i=0; i<gridSize; i++) {
				for (j=0; j<gridSize-1; j++) {
					graphics.moveTo(particles[i][j].position.x, particles[i][j].position.y);
					graphics.lineTo(particles[i][j+1].position.x, particles[i][j+1].position.y);
				}
			}
			
			for (i=0; i<gridSize-1; i++) {
				for (j=0; j<gridSize; j++) {
					graphics.moveTo(particles[i][j].position.x, particles[i][j].position.y);
					graphics.lineTo(particles[i+1][j].position.x, particles[i+1][j].position.y)
				}
			}
			
		}
		
	}
	
	
}