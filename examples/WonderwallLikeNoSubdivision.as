package {
	
	import flash.display.Sprite;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.TriangleCulling;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.IGraphicsData;
	import flash.geom.Vector3D;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.Event;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	import traer.physics.Spring;
		
	[ SWF (width=485, height=808, backgroundColor=0xd6d6d6, frameRate=31) ]

	public class WonderwallLikeNoSubdivision extends Sprite {
		
		[ Embed (source="_assets/ww_img1.jpg") ]
		public var Img1:Class;
		[ Embed (source="_assets/ww_img2.jpg") ]
		public var Img2:Class;
		[ Embed (source="_assets/ww_img3.jpg") ]
		public var Img3:Class;
		[ Embed (source="_assets/ww_img4.jpg") ]
		public var Img4:Class;
		[ Embed (source="_assets/ww_img5.jpg") ]
		public var Img5:Class;
		[ Embed (source="_assets/ww_img6.jpg") ]
		public var Img6:Class;
		[ Embed (source="_assets/ww_img7.jpg") ]
		public var Img7:Class;
		[ Embed (source="_assets/ww_img8.jpg") ]
		public var Img8:Class;
		
		private var s					:ParticleSystem;
		private var attractor			:Particle;
		private var particles_fixed		:Vector.<Vector.<Particle>>;
		private var particles_free		:Vector.<Vector.<Particle>>;
		private var texture				:BitmapData;
		private var vertices			:Vector.<Number>;
		private var indices				:Vector.<int>;
		private var uv					:Vector.<Number>;
		private var bitmapFill			:GraphicsBitmapFill;
		private var trianglePath		:GraphicsTrianglePath;
		
		private var num_cols			:uint = 5;
		private var num_rows			:uint = 7;
		private var subs				:uint;
		private var cell_width			:Number = 102;
		private var cell_height			:Number = 134;
		
		private var sx					:Number = 66;
		private var sy					:Number = 76;
		
		function WonderwallLikeNoSubdivision() {

			subs = num_cols*num_rows;
			generateTexture();
			
			particles_fixed	= new Vector.<Vector.<Particle>>;
			particles_free	= new Vector.<Vector.<Particle>>;
			s				= new ParticleSystem(new Vector3D(0, 0, 0), .1);
			
			generateParticles();
			getVerticesFromParticles();
			setIndicesAndUvs();
			
			bitmapFill		= new GraphicsBitmapFill(texture, null, false, true);
			trianglePath	= new GraphicsTrianglePath(vertices, indices, uv, TriangleCulling.NONE);
			addEventListener(Event.ENTER_FRAME, render);
			
		}
		
		private function setIndicesAndUvs():void {

			// set uvs
				uv = new Vector.<Number>([]);
				for (var i:uint=0; i<=num_rows; i++) {
					for (var j:uint=0; j<=num_cols; j++) {
						uv.push(j/num_cols, i/num_rows, 1);
					}
				}
			
			// set indices
				indices = new Vector.<int>([]);
				var _top_left		:uint;
				var _top_right		:uint;
				var _bottom_left	:uint;
				var _bottom_right	:uint;

				for (i=0; i<num_rows; i++) {

					for (j=0; j<num_cols; j++) {

						_top_left		= j+i*(num_cols+1);
						_top_right		= (j+1)+(i*(num_cols+1));
						_bottom_left 	= (i+1)*(num_cols+1) + j;
						_bottom_right 	= (i+1)*(num_cols+1) + (j+1);

						indices.push(_top_left, _top_right, _bottom_left, _top_right, _bottom_right, _bottom_left);

					}
					
				}
			
		}
		
		private function getVerticesFromParticles():void {
			vertices = Vector.<Number>([]);
			for (var i:uint=0; i<particles_free.length; i++) {
				for (var j:uint=0; j<particles_free[i].length; j++) {
					vertices.push(particles_free[i][j].position.x, particles_free[i][j].position.y);
				}
			}
		}
		
		private function generateParticles():void {
			
			attractor = s.makeParticle(1, new Vector3D(300, 300, 0)); attractor.makeFixed();
			
			for (var i:uint=0; i<=num_rows; i++) {
				var _row_particles_fixed:Vector.<Particle> = new Vector.<Particle>;
				var _row_particles_free:Vector.<Particle> = new Vector.<Particle>;
				for (var j:uint=0; j<=num_cols; j++) {
					//let's scale this down a bit (*.7), so when "zoomed in", texture is not too pixelly
					var a:Particle = s.makeParticle(.8, new Vector3D(sx+(j*cell_width*.7), sy+(i*cell_height*.7), 0));
					a.makeFixed();
					var b:Particle = s.makeParticle(.8, new Vector3D(sx+(j*cell_width*.7), sy+(i*cell_height*.7), 0));
					_row_particles_fixed.push(a);
					_row_particles_free.push(b);
					s.makeSpring(a, b, .017, .6, 0);
					s.makeAttraction(attractor, b, -66800, 100);
				}
				particles_fixed.push(_row_particles_fixed);
				particles_free.push(_row_particles_free);
			}

		}
		
		private function generateTexture():void {

			var _assets:Array = [];
			_assets.push(new Img1() as Bitmap);
			_assets.push(new Img2() as Bitmap);
			_assets.push(new Img3() as Bitmap);
			_assets.push(new Img4() as Bitmap);
			_assets.push(new Img5() as Bitmap);
			_assets.push(new Img6() as Bitmap);
			_assets.push(new Img7() as Bitmap);
			_assets.push(new Img8() as Bitmap);
			
			var _width:Number = num_cols*cell_width;
			var _height:Number = num_rows*cell_height;
			var _texture:BitmapData = new BitmapData(_width, _height, false, 0xFFFFFF);
			
			// stitch the images together
			for (var i:uint=0; i<num_rows; i++) {
				for (var j:uint=0; j<num_cols; j++) {
					var _index:uint = uint( (_assets.length + (j + (i*num_cols))) % _assets.length );
					_texture.copyPixels(_assets[_index].bitmapData, new Rectangle(0, 0, cell_width, cell_height), new Point(j*cell_width, i*cell_height));
				}
			}

			texture = _texture;
			_assets = null;
			
		}
		
		private function render(evt:Event):void {
			
			s.tick(2.9);
			
			attractor.position.x = mouseX;
			attractor.position.y = mouseY;
			
			getVerticesFromParticles();
			trianglePath.vertices = vertices;

			graphics.clear();
			//graphics.lineStyle(1, 0xFF00FF);

			graphics.drawGraphicsData(Vector.<IGraphicsData>([
						bitmapFill,
						trianglePath,
					]));
			
		}
		
	}
	
}