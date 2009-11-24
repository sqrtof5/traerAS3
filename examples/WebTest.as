package {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import flash.geom.Vector3D;
	import flash.geom.Point;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	import traer.physics.Attraction;
	import traer.physics.Spring;
	
	[ SWF (width = 600, height = 600, backgroundColor = 0x909090, frameRate = 31) ]
	
	public class WebTest extends Sprite {
		
		private var s				:ParticleSystem;
		private var attractor		:Particle;
		private var particles		:Vector.<Particle>;
		private var anchors			:Vector.<Particle>;
		private var _anchors_copy	:Vector.<Vector3D>;
		private var joints			:Vector.<Particle>;
		private var attractions		:Vector.<Attraction>;
		
		// modifying an archimedean spiral to get a spider web-like structure
		
		private var steps		:int = 29;
		private var numTurns	:int = 16;
		
		private var ox			:Number = 300;
		private var oy			:Number = 300;
		private var a			:Number	= 4;
		private var b			:Number = 1.3;
		
		private var prev_x		:Number;
		private var prev_y		:Number;
		
		//points defining the frame the structure is attached to
		private var q0			:Point = new Point(50, 50);
		private var q1			:Point = new Point(550, 50);
		private var q2			:Point = new Point(550, 550);
		private var q3			:Point = new Point(50, 550);
		
		[ Embed (source="_assets/reset.png") ]
		public var Reset:Class;
		
		private var _MOUSE_DOWN:Boolean;
		
		function WebTest() {
			
			s				= new ParticleSystem(new Vector3D(0, 1, 0), .42);
			attractor		= s.makeParticle(1, new Vector3D(300, 300, 0)); attractor.makeFixed();
			particles		= new Vector.<Particle>();
			anchors			= new Vector.<Particle>();
			_anchors_copy 	= new Vector.<Vector3D>();
			joints			= new Vector.<Particle>();
			attractions		= new Vector.<Attraction>();
			
			// generate main archimedean spiral, from polar equation r = a + b*theta
			// create two sets of particles, one set fixed, one set free
			// http://en.wikipedia.org/wiki/Archimedean_spiral
			
				for (var i:int = 1; i <= numTurns; i++) {
				
					for (var j:int = 0; j < steps; j++) {
					
						var _rand:Number = 1 + Math.random() * .008; //add some small irregularities
					
						var theta:Number = (j * ((Math.PI * 2) / steps)) + (i * Math.PI * 2) + Math.PI/2; // add 90 deg so the orientation of web is correct (starts at top)
						var r:Number = a + (b * theta) * _rand;
						var pos:Point = Point.polar(r, -theta); // use theta*-1 as spiders create their final web outwards, turning clockwise 
					
						var _p:Particle = s.makeParticle(.8, new Vector3D(ox + pos.x * _rand, oy + pos.y * _rand, 0));
						var _pfixed:Particle = s.makeParticle(.8, new Vector3D(ox + pos.x * _rand, ox + pos.y * _rand, 0));
						_pfixed.makeFixed();
						
						attractions.push(s.makeAttraction(attractor, _p, 1, 1)); //these values will be overriden based on mouse motion
						particles.push(_p);
						anchors.push(_pfixed);
						
						if (i == 1) {
							_p.position.x = _pfixed.position.x = ox;
							_p.position.y = _pfixed.position.y = oy;
						}
						
						_anchors_copy.push(new Vector3D(_pfixed.position.x, _pfixed.position.y, _pfixed.position.z));
						
						s.makeSpring(_p, _pfixed, .42, 0, Math.random()*1.01);
					
					}
				
				}
				
				// at this point the pattern we have is too regular
				// we need to change that a bit
				
				// NOTE: the mix of vector math + "custom" calc is horrible, to rewrite using Vector3D methods only
				
				for (i = 0; i < steps-2; i++) {

					var seed_index:int = i + (numTurns-1) * steps;

					if (seed_index < particles.length) {
						
						var seed_pos:Vector3D = particles[seed_index].position;
						var n_pt_pos:Vector3D = particles[i + (numTurns-2) * steps].position;
						var mod_v:Vector3D = n_pt_pos.clone();
						mod_v = mod_v.subtract(seed_pos);
						mod_v.scaleBy(-Math.random()*4);
						
						var next_seed_pos:Vector3D = seed_pos.clone();
						next_seed_pos = next_seed_pos.add(mod_v);
						
						//clip to frame with an offset
						var _sp:Number = 25;
						if (next_seed_pos.x < q0.x + _sp) next_seed_pos.x = q0.x + _sp;
						if (next_seed_pos.y < q0.y + _sp) next_seed_pos.y = q0.y + _sp;
						if (next_seed_pos.x > q1.x - _sp) next_seed_pos.x = q1.x - _sp;
						if (next_seed_pos.y > q2.y - _sp) next_seed_pos.y = q2.y - _sp;
						
						var dx:Number = next_seed_pos.x - seed_pos.x;
						var dy:Number = next_seed_pos.y - seed_pos.y;
						var d:Number = Math.sqrt(dx*dx + dy*dy);
						
						for (j=0; j<particles.length; j++) {
							//if (j != seed_index) {
								var _dx:Number = next_seed_pos.x - particles[j].position.x;
								var _dy:Number = next_seed_pos.y - particles[j].position.y;
								var _d:Number = Math.sqrt(_dx*_dx + _dy*_dy);
								if (d != 0) {
									r = (d/_d); // we could use just that...
									//r = r*r; // ...but here we attenuate a bit the displacement of the influenced particles
									//r = r*r*r; // ...or this would give an even more spiky look
									
									var p_pos_x:Number = particles[j].position.x + dx*r;
									var p_pos_y:Number = particles[j].position.y + dy*r;
	
									particles[j].position.x = p_pos_x;
									particles[j].position.y = p_pos_y;
									anchors[j].position.x = p_pos_x;
									anchors[j].position.y = p_pos_y;
									_anchors_copy[j] = new Vector3D(p_pos_x, p_pos_y, 0);
									
								}
							//}
						}
						
						particles[seed_index].position = next_seed_pos.clone();
						anchors[seed_index].position = next_seed_pos.clone();
						_anchors_copy[seed_index] = next_seed_pos.clone();
						
						//i+=1;
						
					}
					
				}
			
			// generate spring-dampers keeping the structure together

				// main spiral
					for (i = 2; i < particles.length; i++) {
						dx = particles[i].position.x - particles[i-1].position.x;
						dy = particles[i].position.y - particles[i-1].position.y;
						d = Math.sqrt(dx*dx + dy*dy);
						s.makeSpring(particles[int(i-1)], particles[i], .03, .61, d);
					}
				
				
				// joints to frame: create necessary fixed particles and connect
				// we'll need to figure out were the armature should intersect the frame
				
					for (i = 0; i <= steps; i++) {

						var p0_index:int = i + (numTurns-1) * steps;

						if (p0_index < particles.length) {

							var p1_index:int = i + (numTurns-2) * steps;

							var p0:Point = new Point(particles[p0_index].position.x, particles[p0_index].position.y);
							var p1:Point = new Point(particles[p1_index].position.x, particles[p1_index].position.y);

							var intersect_top		:Point = getIntersect(p0, p1, q0, q1);
							var intersect_right		:Point = getIntersect(p0, p1, q1, q2);
							var intersect_bottom	:Point = getIntersect(p0, p1, q3, q2);
							var intersect_left		:Point = getIntersect(p0, p1, q0, q3);

							// what's the closest intersection point to p0?
							var top_bottom:Point = (Point.distance(p0, intersect_top) < Point.distance(p0, intersect_bottom))? intersect_top : intersect_bottom;
							var left_right:Point = (Point.distance(p0, intersect_left) < Point.distance(p0, intersect_right))? intersect_left : intersect_right;
							var closest:Point = (Point.distance(p0, top_bottom) < Point.distance(p0, left_right))? top_bottom : left_right;
							
							_p = s.makeParticle(.8, new Vector3D(closest.x, closest.y, 0));
							_p.makeFixed();
							
							joints.push(_p);
							
							d = Point.distance(closest, p0); //make the rest length equals to the distance between these 2 points
							s.makeSpring(_p, particles[p0_index], .05, .01, d); //make these a bit different to stretch the structure

						}

					}
			
			// reset button
			var reset_bmp:Bitmap = new Reset() as Bitmap;
			var reset_sp:Sprite = new Sprite();
			reset_sp.addChild(reset_bmp);
			addChild(reset_sp);
			reset_sp.x = 500;
			reset_sp.y = 525;
			reset_sp.buttonMode = true;
			reset_sp.addEventListener(MouseEvent.MOUSE_DOWN, doReset);
			
			// ready to start simulation
			addEventListener(Event.ENTER_FRAME, render);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
			
		}
		
		private function handleMouseEvents(evt:MouseEvent):void {
			if (evt.currentTarget == stage) {
				switch (evt.type) {
					case MouseEvent.MOUSE_DOWN:
						_MOUSE_DOWN = true;
						break;
					case MouseEvent.MOUSE_UP:
						_MOUSE_DOWN = false;
						break;
				}
			}
		}
		
		private function doReset(evt:MouseEvent):void {
			for (var i:uint=0; i<_anchors_copy.length; i++) {
				anchors[i].position.x = particles[i].position.x = _anchors_copy[i].x;
				anchors[i].position.y = particles[i].position.y = _anchors_copy[i].y;
			}
		}
		
		private function getIntersect(p1:Point, p2:Point, p3:Point, p4:Point):Point {
			
			// based on an algorithm by Paul Bourke
			// http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/
			
			var denom:Number = (p4.y - p3.y)*(p2.x - p1.x) - (p4.x - p3.x)*(p2.y - p1.y);
			var num_a:Number = (p4.x - p3.x)*(p1.y - p3.y) - (p4.y - p3.y)*(p1.x - p3.x);
			var num_b:Number = (p2.x - p1.x)*(p1.y - p3.y) - (p2.y - p1.y)*(p1.x - p3.x);
			
			if (denom == 0) {
				return null; //lines are parallel
			} else {

				if (ua == denom && ub == denom) {
					return null; //lines are coincident
				} else {
					var ua:Number = num_a / denom;
					var ub:Number =  num_b / denom;
					return new Point(p1.x + ua*(p2.x - p1.x), p1.y + ua*(p2.y - p1.y));
				}
				
				//NOTE: if (ua >= 0 && ua <=1 && ub >= 0 && ub <= 1) then intersection lies within both segments
				//if only ua lies between 0 and 1, then intersection is within segment p1,p2
				//if only ub lies between 0 and 1, then intersection is within segment p3,p4
				//but we don't need that here
				
				
			}
			
		}
		
		private function render(evt:Event):void {
			
			s.tick(1);
			
			attractor.position.x = mouseX;
			attractor.position.y = mouseY;
			
			graphics.clear();
			graphics.lineStyle(1, 0xc2c2c2);
			
			// draw spiral			
			for (i = 2; i < particles.length; i++) {
				graphics.moveTo(particles[int(i-1)].position.x,  particles[(i-1)].position.y);
				graphics.lineTo(particles[i].position.x, particles[i].position.y);
			}
			
			// draw armature
			for (i = 1; i <= steps; i++) {
				graphics.moveTo(particles[i].position.x, particles[i].position.y);
				for (var j:uint = 0; j <= numTurns; j++) {
					var index:int = i + (j * steps);
					if (index < particles.length) {
						graphics.lineTo(particles[index].position.x, particles[index].position.y);
					}
				}
			}
			
			// draw joints to frame
			for (i = 0; i <= steps; i++) {
				var p0_index:int = i + (numTurns-1) * steps;
				if (p0_index < particles.length) {
					graphics.moveTo(particles[p0_index].position.x, particles[p0_index].position.y);
					graphics.lineTo(joints[i].position.x, joints[i].position.y);
				}
				//i+=1; //draw only 1 out of 2
			}
			
			// draw frame
			graphics.moveTo(q0.x, q0.y);
			graphics.lineTo(q1.x, q1.y);
			graphics.lineTo(q2.x, q2.y);
			graphics.lineTo(q3.x, q3.y);
			graphics.lineTo(q0.x, q0.y);
			
			// draw springs
/*			graphics.lineStyle(1, 0xFF3333);
			for (i = 0; i < particles.length; i++) {
				graphics.moveTo(particles[i].position.x, particles[i].position.y);
				graphics.lineTo(anchors[i].position.x, anchors[i].position.y);
			}
*/						
			// set attraction based on mouse motion, and modify structure if mouse pressed
			if (prev_x) {
				
				var mouse_d:Number = Point.distance(new Point(mouseX, mouseY), new Point(prev_x, prev_y));
				
				for (var i:uint = 0; i < attractions.length; i++) {

					attractions[i].setMinimumDistance(mouse_d*1.2);
					attractions[i].setStrength((100 * (mouse_d*mouse_d)));
					
					if (mouse_d > 4 && _MOUSE_DOWN) {
						anchors[i].position.x += (particles[i].position.x - anchors[i].position.x)*.2;
						anchors[i].position.y += (particles[i].position.y - anchors[i].position.y)*.2;
					}
						
				}
			}
			
			prev_x = mouseX;
			prev_y = mouseY;
			
		}
	
	}	
		
}