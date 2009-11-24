package com.sqrtof5.geom {
	
	import flash.geom.Vector3D;
	import flash.geom.Point;
	
	public class CatmullRomSpline {
		
		private var vertices		:Vector.<Vector3D>;
		private var n				:int;
		private var t_inc			:Number;
		private var tension			:Number;
		private var isClosed		:Boolean;
		
		private var tangents		:Vector.<Object>;
		
		function CatmullRomSpline(vertices:Vector.<Vector3D>, subdivisions:int, tension:Number, isClosed:Boolean) {
			
			this.vertices		= vertices.concat(); //work off a copy since closed path will need to alter the structure
			this.n				= subdivisions;
			this.tension		= tension;
			this.isClosed		= isClosed;
			
			t_inc				= 1/n;
			
			computeTangents();
			
		}
		
		private function computeTangents():void {
			
			tangents = new Vector.<Object>();
			
			for (var i:uint = 0; i<vertices.length-1; i++) {
				
				//get necessary coordinates
					var p0x:Number		= vertices[i].x;
					var p0y:Number		= vertices[i].y;
					var p1x:Number		= vertices[i+1].x;
					var p1y:Number		= vertices[i+1].y;
					
					var p2x:Number;
					var p2y:Number;
					var pn1x:Number;
					var pn1y:Number;
					
					if (i != 0) {
						pn1x = vertices[i-1].x;
						pn1y = vertices[i-1].y;
					} else {
						//for the first segment there is no previous point, we need to use a phantom point to calculate the staring tangent
						if (! isClosed) {
							if (! p2x) {
								p2x = vertices[i+2].x;
								p2y = vertices[i+2].y;
							}
							pn1x = p0x + p2x - p1x;
							pn1y = p0y + p2y - p1y;
						} else {
							pn1x = vertices[vertices.length-1].x;
							pn1y = vertices[vertices.length-1].y;
						}
					}
					
					if (i < vertices.length-2) {
						p2x = vertices[i+2].x;
						p2y = vertices[i+2].y;
					} else {
						//for the last segment, there is no next point, we need to use a phantom point to calculate the ending tangent
						if (! isClosed) {
							p2x = p1x + (p1x - p0x);
							p2y = p1y + (p1y - p0y);
						} else {
							p2x = vertices[0].x;
							p2y = vertices[0].y;
						}
					}
					
				//define starting tangent
					var m0x:Number = tension*(p1x - pn1x); 
					var m0y:Number = tension*(p1y - pn1y);
					
				//define ending tangent
					var m1x:Number = tension*(p2x - p0x);
					var m1y:Number = tension*(p2y - p0y);
					
				//store
					var _tangents:Object = {};
					_tangents.m0x = m0x;
					_tangents.m0y = m0y;
					_tangents.m1x = m1x;
					_tangents.m1y = m1y;
					tangents[i] = _tangents;
					
			}
			
			if (isClosed) {
				
				//push to end a clone of first vertex
				vertices.push(vertices[0].clone());
				
				//add addtional last point/first point tangents
				var _add_tangents:Object = {};
				
				_add_tangents.m0x = tangents[(vertices.length-3)].m1x;
				_add_tangents.m0y = tangents[(vertices.length-3)].m1y;
				_add_tangents.m1x = tangents[0].m0x;
				_add_tangents.m1y = tangents[0].m0y;
				
				tangents[(vertices.length-2)] = _add_tangents;
				
			}
			
		}
		
		public function getPoints():Vector.<Point> {
			
			var _points:Vector.<Point> = new Vector.<Point>();
			
			for (var i:uint=0; i<vertices.length-1; i++) {

				//points coordinates
				//TODO: this is where one would project vectors to screen coordinates
					
					var p0x:Number	= vertices[i].x;
					var p0y:Number	= vertices[i].y;
					var p1x:Number	= vertices[i+1].x;
					var p1y:Number	= vertices[i+1].y;
				
				//retrieve tangents
				
					var m0x:Number	= tangents[i].m0x; 
					var m0y:Number	= tangents[i].m0y;
					var m1x:Number	= tangents[i].m1x;
					var m1y:Number	= tangents[i].m1y;
				
				//set n screen coordinate points as segments of the curves
				
					for (var j:uint=1; j<n; j++) {
						
						var t:Number	= j*t_inc;
						var t2:Number	= t*t;
						var t3:Number	= t2*t;
						var h00:Number	= 2*t3 - 3*t2 +1;
						var h10:Number	= t3 - 2*t2 + t;
						var h01:Number	= -2*t3 + 3*t2;
						var h11:Number	= t3 - t2;
						
						var x:Number	= h00*p0x + h10*m0x + h01*p1x + h11*m1x;
						var y:Number	= h00*p0y + h10*m0y + h01*p1y + h11*m1y;
						
						_points.push(new Point(x, y));
						
					}
					
					_points.push(new Point(p1x, p1y));

			}
			
			return _points;
			
		}

		public function updateVertices(v:Vector.<Vector3D>):void {
			
			this.vertices = v;
			computeTangents();
			
		}
		
	}
	
}