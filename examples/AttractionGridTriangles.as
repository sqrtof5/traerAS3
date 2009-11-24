package {
	
	import flash.display.Sprite;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.TriangleCulling;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.geom.Vector3D;
	import flash.events.Event;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	import traer.physics.Spring;
		
	[ SWF (width=535, height=525, backgroundColor=0xc0c0c0, frameRate=31) ]

	public class AttractionGridTriangles extends Sprite {
		
		[ Embed (source="_assets/papercut.jpg") ]
		public var Img:Class;
	
		private var gridSize		:uint = 16;
		private var subs			:uint;

		private var s				:ParticleSystem;
		private var attractor		:Particle;
		private var particles_fixed	:Vector.<Vector.<Particle>>;
		private var particles_free	:Vector.<Vector.<Particle>>;
		
		private var texture			:BitmapData;
		private var vertices		:Vector.<Number>;
		private var indices			:Vector.<int>;
		private var uv				:Vector.<Number>;
		private var bitmapFill		:GraphicsBitmapFill;
		private var trianglePath	:GraphicsTrianglePath;
		
		public function AttractionGridTriangles() {
			
			subs = gridSize-1;
			
			var tmp_bm:Bitmap = new Img() as Bitmap;
			texture = tmp_bm.bitmapData;
			
			particles_fixed = new Vector.<Vector.<Particle>>;
			particles_free = new Vector.<Vector.<Particle>>;
			s = new ParticleSystem(new Vector3D(0, 0, 0), .2);
			
			var sx:uint = 80;
			var sy:uint = 80;
			var sp:uint = 25;
			
			var i:uint;
			var j:uint;
			
			attractor	= s.makeParticle(1, new Vector3D(300, 300, 0)); attractor.makeFixed();
			
			// create grid of particles				
				for (i=0; i<gridSize; i++) {
					var _row_particles_fixed:Vector.<Particle> = new Vector.<Particle>;
					var _row_particles_free:Vector.<Particle> = new Vector.<Particle>;
					for (j=0; j<gridSize; j++) {
						var a:Particle = s.makeParticle(.8, new Vector3D(sx+j*sp, sy+i*sp, 0));
						a.makeFixed();
						var b:Particle = s.makeParticle(.8, new Vector3D(sx+j*sp, sy+i*sp, 0));
						_row_particles_fixed.push(a);
						_row_particles_free.push(b);
						s.makeSpring(a, b, .1, .01, 0);
						s.makeAttraction(attractor, b, -46800, 100);
					}
					particles_fixed.push(_row_particles_fixed);
					particles_free.push(_row_particles_free);
				}
			
				getVerticesFromParticles();

				// set uv
					uv = new Vector.<Number>([]);
					for (i=0; i<=subs; i++) {
						for (j=0; j<=subs; j++) {
							uv.push(j/subs, i/subs, 1);
						}
					}

				// set indices
					indices = new Vector.<int>([]);
					var _top_left		:uint;
					var _top_right		:uint;
					var _bottom_left	:uint;
					var _bottom_right	:uint;

					for (i=0; i<subs; i++) {

						for (j=0; j<subs; j++) {

							_top_left		= j+i*(subs+1);
							_top_right		= (j+1)+(i*(subs+1));
							_bottom_left	= j+(i*(subs+1))+(subs+1);
							_bottom_right	= (j+1)+(i*(subs+1)+(subs+1));

							indices.push(_top_left, _top_right, _bottom_left, _top_right, _bottom_right, _bottom_left);

						}

					}

				// render
					bitmapFill		= new GraphicsBitmapFill(texture, null, false, true);
					trianglePath	= new GraphicsTrianglePath(vertices, indices, uv, TriangleCulling.NONE);
					addEventListener(Event.ENTER_FRAME, render);
			
		}
		
		private function getVerticesFromParticles():void {
			vertices = Vector.<Number>([]);
			for (var i:uint=0; i<particles_free.length; i++) {
				for (var j:uint=0; j<particles_free[i].length; j++) {
					vertices.push(particles_free[i][j].position.x, particles_free[i][j].position.y);
				}
			}
		}
		
		private function render(evt:Event):void {
			
			s.tick(1);
			
			attractor.position.x = mouseX;
			attractor.position.y = mouseY;
			
			getVerticesFromParticles();
			trianglePath.vertices = vertices;

			graphics.clear();
			//graphics.lineStyle(1, 0xAEAEAE);

			graphics.drawGraphicsData(Vector.<IGraphicsData>([
						bitmapFill,
						trianglePath,
					]));
			
		}
	
	}

}