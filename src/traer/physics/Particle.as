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

	public class Particle {
		
		public var position		:Vector3D;
		public var velocity		:Vector3D;
		public var force		:Vector3D;
		public var mass			:Number;
		public var age			:Number;
		public var fixed		:Boolean;
		
		internal var dead		:Boolean;
		
		function Particle(mass:Number, position:Vector3D = null) {

			this.mass	= mass;
			
			this.position	= (position)? position : new Vector3D();
			velocity		= new Vector3D();
			force			= new Vector3D();
			
			fixed		= false;
			age			= 0;
			dead		= false;
			
		}
		
		public function distanceTo(p:Particle):Number {
			return Vector3D.distance(this.position, p.position);
		}
		
		public function makeFixed():void {
			fixed = true;
			velocity.x = 0; velocity.y = 0; velocity.z = 0;
		}
		
		public function makeFree():void {
			fixed = false;
		}
		
		public function isFixed():Boolean {
			return fixed;
		}
		
		public function isFree():Boolean {
			return !fixed;
		}
		
		public function setMass(m:Number):void {
			mass = m;
		}
		
		protected function reset():void {
			age = 0;
			dead = false;
			position.x	= 0; position.y	= 0; position.z	= 0;
			velocity.x	= 0; velocity.y	= 0; velocity.z	= 0;
			force.x		= 0; force.y	= 0; force.z	= 0;
			mass = 1;
		}
		
		public function toString():String {
			return ("[object Particle]\tm:" + mass + " [" + position.x + ", " + position.y + ", " + position.z +"]");
		}
		
	}
	
}