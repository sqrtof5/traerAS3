package {
	
	import flash.display.Sprite;

	import flash.display.Bitmap;
	import flash.geom.Vector3D;
	import flash.events.Event;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	import traer.physics.Spring;
		
	[ SWF (width=535, height=525, backgroundColor=0xd6d6d6, frameRate=31) ]

	public class AttractionGrid extends Sprite {
	
		private var s				:ParticleSystem;
		private var attractor		:Particle;
		private var particles_fixed	:Array;
		private var particles_free	:Array;

		private var gridSize		:uint = 16;
		private var particles		:Array;
		
		public function AttractionGrid() {
			
			particles_fixed = [];
			particles_free = [];
			s = new ParticleSystem(new Vector3D(0, 0, 0), .2);
			
			var sx:uint = 80;
			var sy:uint = 80;
			var sp:uint = 25;
			
			var i:uint;
			var j:uint;
			
			attractor	= s.makeParticle(1, new Vector3D(300, 300, 0)); attractor.makeFixed();
			
			// create grid of particles
				for (i=0; i<gridSize; i++) {
					
					for (j=0; j<gridSize; j++) {
						
						var a:Particle = s.makeParticle(.8, new Vector3D(sx+j*sp, sy+i*sp, 0));
						a.makeFixed();
						var b:Particle = s.makeParticle(.8, new Vector3D(sx+j*sp, sy+i*sp, 0));
						
						particles_fixed.push(a);
						particles_free.push(b);
						
						s.makeSpring(a, b, .1, .01, 0);
						s.makeAttraction(attractor, b, -46800, 100);
						
					}
					
				}
			
			// render
			addEventListener(Event.ENTER_FRAME, render);
			
		}
		
		private function render(evt:Event):void {
			
			s.tick(1);
			
			attractor.position.x = mouseX;
			attractor.position.y = mouseY;
			
			graphics.clear();
			graphics.lineStyle(1, 0xFF0000);
			
			for (var i:uint = 0; i<particles_fixed.length; i++) {
				
				graphics.moveTo(particles_fixed[i].position.x, particles_fixed[i].position.y);
				graphics.lineTo(particles_free[i].position.x, particles_free[i].position.y)
				
			}
			
			graphics.lineStyle(1, 0x333333);
			var count:uint = 0;
			
			for (i=0; i<gridSize; i++) {
				for (var j:uint=0; j<gridSize; j++) {
					if (j <gridSize-1) {
						graphics.moveTo(particles_free[count].position.x, particles_free[count].position.y);
						graphics.lineTo(particles_free[count+1].position.x, particles_free[count+1].position.y);
						//graphics.moveTo(particles_fixed[count].position.x, particles_fixed[count].position.y);
						//graphics.lineTo(particles_fixed[count+1].position.x, particles_fixed[count+1].position.y);
					}
					count ++;
				}
			}
			
			count = 0;
			
			for (i=0; i<gridSize-1; i++) {
				for (j=0; j<gridSize; j++) {
					graphics.moveTo(particles_free[count].position.x, particles_free[count].position.y);
					graphics.lineTo(particles_free[count+gridSize].position.x, particles_free[count+gridSize].position.y);
					//graphics.moveTo(particles_fixed[count].position.x, particles_fixed[count].position.y);
					//graphics.lineTo(particles_fixed[count+gridSize].position.x, particles_fixed[count+gridSize].position.y);
					count ++;
				}
			}
			
		}
	
	}

}