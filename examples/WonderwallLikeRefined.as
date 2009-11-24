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
	
	/*
		
		Some kind of tribute to Yugo Nakamura's wonder wall
		See the absolutely gorgeous original:
			http://www.wonder-wall.com
		Such a brilliant idea AND execution, as always... /bow
		
	*/

	public class WonderwallLikeRefined extends Sprite {
		
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
		private var cell_width			:Number = 102;
		private var cell_height			:Number = 134;
		
		private var sx					:Number = 66;
		private var sy					:Number = 76;
		
		private var subdivisions		:uint = 6; // # of subdivisions to minimize distortion (per grid cell)
		
		function WonderwallLikeRefined() {

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
			
			var dbl_cols:uint = num_cols*subdivisions;
			var dbl_rows:uint = num_rows*subdivisions;
			
			// set uvs
				uv = new Vector.<Number>([]);
				for (var i:uint=0; i<=dbl_rows; i++) {
					for (var j:uint=0; j<=dbl_cols; j++) {
						uv.push(j/dbl_cols, i/dbl_rows, 1);
					}
				}
			
			// set indices
				indices = new Vector.<int>([]);
				var _top_left		:uint;
				var _top_right		:uint;
				var _bottom_left	:uint;
				var _bottom_right	:uint;

				for (i=0; i<dbl_rows; i++) {

					for (j=0; j<dbl_cols; j++) {

						_top_left		= j+i*(dbl_cols+1);
						_top_right		= (j+1)+(i*(dbl_cols+1));
						_bottom_left 	= (i+1)*(dbl_cols+1) + j;
						_bottom_right 	= (i+1)*(dbl_cols+1) + (j+1);

						indices.push(_top_left, _top_right, _bottom_left, _top_right, _bottom_right, _bottom_left);

					}
					
				}
			
		}
		
		private function getVerticesFromParticles():void {

			vertices = Vector.<Number>([]);

			for (var i:uint=0; i<particles_free.length; i++) {
				
				for (var j:uint=0; j<particles_free[i].length; j++) {
					vertices.push(particles_free[i][j].position.x, particles_free[i][j].position.y);
					
					if (j < particles_free[i].length-1) {
						//subdivide columns as we go
						for (var k:uint = 1; k < subdivisions; k++) {
							var _f:Number = k*(1/subdivisions); 
							var _midx:Number = particles_free[i][j].position.x + (particles_free[i][j+1].position.x - particles_free[i][j].position.x)*_f;
							var _midy:Number = particles_free[i][j].position.y + (particles_free[i][j+1].position.y - particles_free[i][j].position.y)*_f;
							vertices.push(_midx, _midy);
						}
					}
					
				}
				
				//before moving on to the next row, subdivide rows (+ cols of subdivided rows)
				
				if (i < particles_free.length -1) {
					
					for (var l:uint = 1; l < subdivisions; l++) {
						
						var _frow:Number = l*(1/subdivisions);
						
						for (j=0; j<particles_free[i].length; j++) {
							
							var _mid_rowx:Number = particles_free[i][j].position.x + (particles_free[i+1][j].position.x - particles_free[i][j].position.x)*_frow;
							var _mid_rowy:Number = particles_free[i][j].position.y + (particles_free[i+1][j].position.y - particles_free[i][j].position.y)*_frow;
							vertices.push(_mid_rowx, _mid_rowy);
							
							if (j < particles_free[i].length-1) {
								
								for (k = 1; k < subdivisions; k++) {
									_f = k*(1/subdivisions);
									var _n_mid_rowx:Number = particles_free[i][j+1].position.x + (particles_free[i+1][j+1].position.x - particles_free[i][j+1].position.x)*_frow;
									var _n_mid_rowy:Number = particles_free[i][j+1].position.y + (particles_free[i+1][j+1].position.y - particles_free[i][j+1].position.y)*_frow;
									var _mm_rowx:Number = _mid_rowx + (_n_mid_rowx - _mid_rowx)*_f;
									var _mm_rowy:Number = _mid_rowy + (_n_mid_rowy - _mid_rowy)*_f;
									vertices.push(_mm_rowx, _mm_rowy);
								}
								
							}
							
						}
						
					}
					
				}
				
			}

		}
		
		private function generateParticles():void {
			
			attractor = s.makeParticle(1, new Vector3D(300, 300, 0)); attractor.makeFixed();
			
			for (var i:uint=0; i<=num_rows; i++) {
				var _row_particles_fixed:Vector.<Particle> = new Vector.<Particle>;
				var _row_particles_free:Vector.<Particle> = new Vector.<Particle>;
				for (var j:uint=0; j<=num_cols; j++) {
					// grid is scaled down here (*.7) so when the texture is stretched it's not pixelated too too much
					var a:Particle = s.makeParticle(.8, new Vector3D(sx+(j*cell_width*.7), sy+(i*cell_height*.7), 0));
					a.makeFixed();
					var b:Particle = s.makeParticle(.8, new Vector3D(sx+(j*cell_width*.7), sy+(i*cell_height*.7), 0));
					_row_particles_fixed.push(a);
					_row_particles_free.push(b);
					s.makeSpring(a, b, .017, .6, 0);
					s.makeAttraction(attractor, b, -46800, 100);
				}
				particles_fixed.push(_row_particles_fixed);
				particles_free.push(_row_particles_free);
			}
			
			/*
			//deform grid (over-simplification: the original wonder-wall has a way nicer touch to it than this)
			var _theta:Number = Math.PI;
			var _r:Number = 10;
			for (i=0; i<particles_fixed.length; i++) {
				for (j=0; j<particles_fixed[i].length; j++) {
					var _rand1:Number = (-5 + Math.random()*10);
					var _rand2:Number = (-20 + Math.random()*40);
					particles_fixed[i][j].position.x += Math.sin(_theta)*_r + _rand1;
					particles_free[i][j].position.x += Math.sin(_theta)*_r + _rand1;
					particles_fixed[i][j].position.y += _rand2;
					particles_free[i][j].position.y += _rand2;
				}
				_theta += 1.8;
			}
			*/
			
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
		
		private function isMouseOnGrid():Boolean {
			
			
			var _mp:Point = new Point(mouseX, mouseY);
			var _o:Point = new Point(-400, -400);
			var numIntersect:uint;

			for (var i:uint = 0; i<particles_free.length-1; i++) {
				
				for (var j:uint=0; j<particles_free[i].length-1; j++) {
				
					var q0:Point = new Point(particles_free[i][j].position.x, particles_free[i][j].position.y);
					var q1:Point = new Point(particles_free[i][j+1].position.x, particles_free[i][j+1].position.y);
					var q2:Point = new Point(particles_free[i+1][j+1].position.x, particles_free[i+1][j+1].position.y);
					var q3:Point = new Point(particles_free[i+1][j].position.x, particles_free[i+1][j].position.y);
				
					numIntersect = 0;
				
					if (doesIntersectOnBothSegments(_mp, _o, q0, q1)) numIntersect++;
					if (doesIntersectOnBothSegments(_mp, _o, q1, q2)) numIntersect++;
					if (doesIntersectOnBothSegments(_mp, _o, q2, q3)) numIntersect++;
					if (doesIntersectOnBothSegments(_mp, _o, q3, q0)) numIntersect++;
				
					if (numIntersect == 1 || numIntersect == 3) {
						graphics.beginFill(0xFFFFFF, .35);
						graphics.lineStyle(1, 0xF7F7F7);
						graphics.moveTo(q1.x, q1.y);
						graphics.lineTo(q2.x, q2.y);
						graphics.lineTo(q3.x, q3.y);
						graphics.lineTo(q0.x, q0.y);
						graphics.lineTo(q1.x, q1.y);
						graphics.lineTo(q3.x, q3.y);
						graphics.moveTo(q0.x, q0.y);
						graphics.lineTo(q2.x, q2.y);
						graphics.endFill();
						return true;
					}
				
				}
				
			}
			
			return false;
			
		}
		
		private function doesIntersectOnBothSegments(p1:Point, p2:Point, p3:Point, p4:Point):Boolean {
			
			// based on an algorithm by Paul Bourke
			// http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
			
			var denom:Number = (p4.y - p3.y)*(p2.x - p1.x) - (p4.x - p3.x)*(p2.y - p1.y);
			var num_a:Number = (p4.x - p3.x)*(p1.y - p3.y) - (p4.y - p3.y)*(p1.x - p3.x);
			var num_b:Number = (p2.x - p1.x)*(p1.y - p3.y) - (p2.y - p1.y)*(p1.x - p3.x);
			
			if (denom == 0) {
				return false; //lines are parallel
			} else {

				if (ua == denom && ub == denom) {
					return false; //lines are coincident
				} else {
					var ua:Number = num_a / denom;
					var ub:Number =  num_b / denom;
					//var intersect:Point = new Point(p1.x + ua*(p2.x - p1.x), p1.y + ua*(p2.y - p1.y));
					if (ub >= 0 && ub <= 1 && ua >=0 && ua <= 1) {
						return true;
					} else {
						return false;
					}
				}
				
				//NOTE: if (ua >= 0 && ua <=1 && ub >= 0 && ub <= 1) then intersection lies within both segments
				//if only ua lies between 0 and 1, then intersection is within segment p1,p2
				//if only ub lies between 0 and 1, then intersection is within segment p3,p4
				
				
			}
			
		}
		
		private function render(evt:Event):void {
			
			s.tick(2.9);
			
			//attractor.position.x = mouseX;
			//attractor.position.y = mouseY;
			
			getVerticesFromParticles();
			trianglePath.vertices = vertices;

			graphics.clear();
			//graphics.lineStyle(1, 0xFFFFFF);

			graphics.drawGraphicsData(Vector.<IGraphicsData>([
						bitmapFill,
						trianglePath,
					]));
			
			//!
			
			if (! isMouseOnGrid()) {
				attractor.position.x = -50000;
				attractor.position.y = -50000;
			} else {
				attractor.position.x = mouseX;
				attractor.position.y = mouseY;
			}
			
		}
		
	}
	
}