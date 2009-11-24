package {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.events.Event;

	import flash.geom.Vector3D;
	import flash.geom.Point;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	import traer.physics.Attraction;
	import traer.physics.Spring;
		
	[ SWF (width=350, height=280, backgroundColor=0xeaeaea, frameRate=31) ]
	
	public class FreeFloatingTest extends MovieClip {
		
		[ Embed (source="_assets/small_particle.png") ]
		public var SmPgfx:Class;
		
		public static const SWF_WIDTH:uint	= 350;		
		public static const SWF_HEIGHT:uint	= 280;
		
		private var s			:ParticleSystem;
		private var particles	:Vector.<Particle>;
		private var p_gfx		:Vector.<Sprite>;
		private var attractions	:Vector.<Attraction>;
		private var prev_x		:Number;
		private var prev_y		:Number;
		
		private var attractor	:Particle;
		
		function FreeFloatingTest() {
			
			particles = new Vector.<Particle>;
			p_gfx = new Vector.<Sprite>;
			attractions = new Vector.<Attraction>;
			
			s = new ParticleSystem(new Vector3D(0, 0, 0), .02);
			
			generateParticles();
			addEventListener(Event.ENTER_FRAME, render);
			
		}
		
		private function generateParticles():void {
			
			var numP:uint = 700;
			
			attractor = s.makeParticle(.8, new Vector3D(0,0,0));

			for (var i:uint = 0; i<numP; i++) {

				var randx:Number = Math.random()*SWF_WIDTH;
				var randy:Number = Math.random()*SWF_HEIGHT;
				
				var _p:Particle = s.makeParticle(.8, new Vector3D(randx, randy, 0));
				particles.push(_p);

				var _p_gfx:Sprite = new Sprite();
				var _bm:Bitmap = new SmPgfx() as Bitmap;
				_bm.x = -11;
				_bm.y = -11;
				addChild(_p_gfx);
				_p_gfx.addChild(_bm);
				p_gfx.push(_p_gfx);
				

				attractions.push(s.makeAttraction(_p, attractor, 100, 30));

			}
			
			
		}
		
		private function render(evt:Event):void {

			s.tick(1);
			
			attractor.position.x = mouseX;
			attractor.position.y = mouseY;

			for (var i:uint=0; i < particles.length; i++) {
				
				particles[i].position.x = (SWF_WIDTH + particles[i].position.x) % SWF_WIDTH;
				particles[i].position.y = (SWF_HEIGHT + particles[i].position.y) % SWF_HEIGHT;				

				p_gfx[i].x = particles[i].position.x;
				p_gfx[i].y = particles[i].position.y;
				
				if (prev_x) {
					
					var mouse_d:Number = Point.distance(new Point(mouseX, mouseY), new Point(prev_x, prev_y));
					attractions[i].setMinimumDistance(mouse_d*1.2);
					attractions[i].setStrength(-(10 + (60 * (mouse_d*mouse_d))));
					
				}
				
			}
			
			prev_x = mouseX;
			prev_y = mouseY;
			
		}
		
		
	}

}