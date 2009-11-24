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
	
	public class Spring implements Force {
		
		private var a					:Particle;
		private var b					:Particle;
		
		private var springConstant		:Number; //ks
		
		private var damping				:Number;
		private var restLength			:Number;
		
		private var on					:Boolean;
		
		function Spring(a:Particle, b:Particle, springConstant:Number, damping:Number, restLength:Number) {

			this.a 					= a;
			this.b					= b;
			this.springConstant		= springConstant;
			this.damping			= damping;
			this.restLength			= restLength;
			on = true;
			
		}
		
		public function turnOn():void {
			on = true;
		}
		
		public function turnOff():void {
			on = false;
		}
		
		public function isOn():Boolean {
			return on;
		}
		
		public function isOff():Boolean {
			return !on;
		}
		
		public final function currentLength():Number {
			return Vector3D.distance(a.position, b.position);
		}
		
		public final function getStrength():Number {
			return springConstant;
		}
		
		public final function setStrength(ks:Number):void {
			springConstant = ks;
		}
		
		public final function getDamping():Number {
			return damping;
		}
		
		public final function setDamping(d:Number):void {
			damping = d;
		}
		
		public final function getRestLength():Number {
			return restLength;
		}
		
		public final function setRestLength(l:Number):void {
			restLength = l;
		}
		
		internal function setA(p:Particle):void {
			a = p;
		}
		
		internal function setB(p:Particle):void {
			b = p;
		}
		
		public final function getOneEnd():Particle {
			return a;
		}
		
		public final function getTheOtherEnd():Particle {
			return b;
		}
		
		public function apply():void {

			if ( on && ( a.isFree() || b.isFree() ) ) {

				var a2bX:Number = a.position.x - b.position.x;
				var a2bY:Number = a.position.y - b.position.y;
				var a2bZ:Number = a.position.z - b.position.z;
				
				var a2bDistance:Number = Math.sqrt(a2bX*a2bX + a2bY*a2bY + a2bZ*a2bZ);
				
				if (a2bDistance == 0) {
					
					a2bX = 0;
					a2bY = 0;
					a2bZ = 0;
					
				} else {
					
					a2bX /= a2bDistance;
					a2bY /= a2bDistance;
					a2bZ /= a2bDistance;
					
				}
				
				var springForce:Number = -( a2bDistance - restLength ) * springConstant;
				
				var Va2bX:Number = a.velocity.x - b.velocity.x;
				var Va2bY:Number = a.velocity.y - b.velocity.y;
				var Va2bZ:Number = a.velocity.z - b.velocity.z;
				
				var dampingForce:Number = -damping * ( a2bX*Va2bX + a2bY*Va2bY + a2bZ*Va2bZ );
				var r:Number = springForce + dampingForce;
				
				a2bX *= r;
				a2bY *= r;
				a2bZ *= r;

				if (a.isFree()) a.force = a.force.add( new Vector3D(a2bX, a2bY, a2bZ) );
				if (b.isFree()) b.force = b.force.add( new Vector3D(-a2bX, -a2bY, -a2bZ) );

			}
		}
		
	}
	
}