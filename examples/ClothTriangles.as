package {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.TriangleCulling;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import flash.geom.Vector3D;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	
	[ SWF (width=600, height=600, backgroundColor=0xd6d6d6, frameRate=31) ]
	
	public class ClothTriangles extends Sprite {
		
		[ Embed (source="_assets/handle.png") ]
		public var Handle:Class;
		
		[ Embed (source="_assets/chiyogami.jpg") ]
		public var Img:Class;
		
		private var s				:ParticleSystem;

		private var gridSize		:uint = 8;
		private var subs			:uint;
		private var particles		:Vector.<Vector.<Particle>>;
		
		private var handle1			:MovieClip;
		private var handle2			:MovieClip;
		
		private var texture			:BitmapData;
		private var vertices		:Vector.<Number>;
		private var indices			:Vector.<int>;
		private var uv				:Vector.<Number>;
		private var bitmapFill		:GraphicsBitmapFill;
		private var trianglePath	:GraphicsTrianglePath;
		
		function ClothTriangles() {
			
			subs = gridSize-1;
			
			particles = new Vector.<Vector.<Particle>>();
			s = new ParticleSystem(new Vector3D(0, 3.2, 0), .06);
			
			var tmp_bm:Bitmap = new Img() as Bitmap;
			texture = tmp_bm.bitmapData;
			
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
			
			// prepare triangle fill
			
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
			for (var i:uint=0; i<particles.length; i++) {
				for (var j:uint=0; j<particles[i].length; j++) {
					vertices.push(particles[i][j].position.x, particles[i][j].position.y);
				}
			}
		}
		
		private function handleMouseEvents(evt:MouseEvent):void {
			
			switch (evt.type) {
				
				case MouseEvent.MOUSE_DOWN:
					evt.currentTarget.startDrag();
					swapChildren(evt.currentTarget as MovieClip, (evt.currentTarget == handle1)? handle2 : handle1);
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
			
			s.tick(1);
						
			particles[0][0].position.x = handle1.x +16;
			particles[0][0].position.y = handle1.y +16;
		
			particles[0][gridSize-1].position.x = handle2.x +16;
			particles[0][gridSize-1].position.y = handle2.y +16;
			
			getVerticesFromParticles();
			
			trianglePath.vertices = vertices;
			graphics.clear();
			graphics.drawGraphicsData(Vector.<IGraphicsData>([
						bitmapFill,
						trianglePath,
					]));
			
		}
		
	}
	
	
}