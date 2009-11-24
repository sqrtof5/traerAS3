/*
*	
*	Traer v3.0 physics engine, AS3 port
*		original Java code by Jeffrey Traer Bernstein
*		source available at: http://www.cs.princeton.edu/~traer/physics/
*		ported by Arnaud Icard, http://blog.sqrtof5.com, http://github.com/sqrtof5
*	
*/

package traer.physics {
	
	import flash.geom.Vector3D;
	
	public class ParticleSystem {
		
		public static const RUNGE_KUTTA		:uint = 0;
		public static const MODIFIED_EULER	:uint = 1;
		
		private var integrator				:Integrator;
		
		public var gravity					:Vector3D;
		public var drag						:Number;
		
		internal var particles				:Vector.<Particle>;
		internal var springs				:Vector.<Spring>;
		internal var attractions			:Vector.<Attraction>;
		internal var custom					:Vector.<Force>;

		protected var hasDeadParticles		:Boolean = false;
		
		function ParticleSystem(gravity:Vector3D = null, drag:Number = 0.001) {
			
			integrator	= new RungeKuttaIntegrator(this);
			
			particles	= new Vector.<Particle>();
		    springs		= new Vector.<Spring>();
		    attractions = new Vector.<Attraction>();
			custom		= new Vector.<Force>();
			
			this.gravity = (gravity)? gravity : new Vector3D();
			
			this.drag = drag;

		}
		
		public function setIntegrator(integrator:uint):void {
			
			switch (integrator) {
				
				case RUNGE_KUTTA:
					this.integrator = new RungeKuttaIntegrator(this);
					break;
				
				case MODIFIED_EULER:
					this.integrator = new ModifiedEulerIntegrator(this);
					break;
				
			}
			
		}
		
		public final function setGravity(gravity:Vector3D):void {
			this.gravity = gravity;
		}
		
		public final function setDrag(d:Number):void {
			this.drag = drag;
		}
		
		public final function tick(t:Number = 1):void {
			integrator.step(t);
		}
		
		public final function makeParticle(mass:Number = 1, position:Vector3D = null):Particle {
			var p:Particle = new Particle(mass, position);
			particles.push(p);
			return p;
		}
		
		public final function makeSpring(a:Particle, b:Particle, springConstant:Number, damping:Number, restLength:Number):Spring {
			var s:Spring = new Spring(a, b, springConstant, damping, restLength);
			springs.push(s);
			return s;
		}
		
		public final function makeAttraction(a:Particle, b:Particle, strength:Number, minDistance:Number):Attraction {
			var m:Attraction = new Attraction(a, b, strength, minDistance);
			attractions.push(m);
			return m;
		}
		
		public final function clear():void {
			
			var i:uint;
			
			for (i=0; i<particles.length; i++) {
				particles[i] = null;
			}
			for (i=0; i<springs.length; i++) {
				springs[i] = null;
			}
			for (i=0; i<attractions.length; i++) {
				attractions[i] = null;
			}
									
			particles	= new Vector.<Particle>();
		    springs		= new Vector.<Spring>();
		    attractions = new Vector.<Attraction>();

		}
		
		internal final function applyForces():void {
			
			var i:uint;
			var p_length:uint = particles.length;
			var s_length:uint = springs.length;
			var a_length:uint = attractions.length;
			var c_length:uint = custom.length;
			
			//trace(gravity)
									
			if ( gravity.x != 0 || gravity.y != 0 || gravity.x != 0) {
				for (i=0; i<p_length; i++) {
					particles[i].force = particles[i].force.add(gravity);
				}
			}
			
			for (i=0; i<p_length; i++) {
				var p:Particle = particles[i];
				var vdrag:Vector3D = p.velocity.clone();
				vdrag.scaleBy(-drag);
				p.force = p.force.add(vdrag);
			}
			
			for (i=0; i<s_length; i++) {
				springs[i].apply();
			}
			
			for (i=0; i<a_length; i++) {
				attractions[i].apply();
			}
			
			for (i=0; i<c_length; i++) {
				custom[i].apply();
			}
			
		}
		
		internal final function clearForces():void {

			var p_length:uint = particles.length;

			for (var i:uint=0; i<p_length; i++) {
				var p:Particle = particles[i];
				p.force.x = 0; p.force.y = 0; p.force.z = 0;
			}
			
		}
		
		public final function numberOfParticles():uint {
			return particles.length;
		}
		
		public final function numberOfSprings():uint {
			return springs.length;
		}
		
		public final function numberOfAttractions():uint {
			return attractions.length;
		}
		
		public final function getParticle(i:uint):Particle {
			return particles[i];
		}
		
		public final function getSpring(i:uint):Spring {
			return springs[i];
		}
		
		public final function getAttraction(i:uint):Attraction {
			return attractions[i];
		}
		
		public final function addCustomForce(f:Force):void {
			custom.push(f);
		}
		
		public final function numberOfCustomForces():uint {
			return custom.length;
		}
		
		public final function getCustomForce(i:uint):Force {
			return custom[i];
		}
		
		public final function removeCustomForce(i:uint):void {
			custom[i] = null;
			custom.splice(i, 1);
		}
		
		public final function removeCustomForceByReference(f:Force):Boolean {
			var i:uint;
			var n:int = -1;
			var c_length:uint = custom.length;
			for (i=0; i<c_length; i++) {
				if (custom[i] == f) {
					n = i;
					break;
				}
			}
			if (n != -1) {
				custom[n] = null;
				custom.splice(n, 1);
				return true;
			} else {
				return false;
			}
		}
		
		public final function removeSpring(i:uint):void {
			springs[i] = null;
			springs.splice(i, 1);
		}
		
		public final function removeSpringByReference(s:Spring):Boolean {
			var i:uint;
			var n:int = -1;
			var s_length:uint = springs.length;
			for (i=0; i<s_length; i++) {
				if (springs[i] == s) {
					n = i;
					break;
				}
			}
			if (n != -1) {
				springs[n] = null;
				springs.splice(n, 1);
				return true;
			} else {
				return false;
			}
		}
		
		public final function removeAttraction(i:uint):void {
			attractions[i] = null;
			attractions.splice(i, 1);
		}
		
		public final function removeAttractionByReference(s:Attraction):Boolean {
			var i:uint;
			var n:int = -1;
			var a_length:uint = attractions.length;
			for (i=0; i<a_length; i++) {
				if (attractions[i] == s) {
					n = i;
					break;
				}
			}
			if (n != -1) {
				attractions[n] = null;
				attractions.splice(n, 1);
				return true;
			} else {
				return false;
			}
		}
		
		public final function removeParticle(i:uint):void {
			particles[i] = null;
			particles.splice(i, 1);
		}
		
		public final function removeParticleByReference(p:Particle):Boolean {
			var i:uint;
			var n:int = -1;
			var p_length:uint = particles.length;
			for (i=0; i<p_length; i++) {
				if (particles[i] == p) {
					n = i;
					break;
				}
			}
			if (n != -1) {
				particles[n] = null;
				particles.splice(n, 1);
				return true;
			} else {
				return false;
			}
		}
		
	}
	
}