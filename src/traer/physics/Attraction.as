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
	
	public class Attraction implements Force {
		
		private var a					:Particle;
		private var b					:Particle;
		
		private var strength			:Number; //k

		private var minDistance			:Number; //set to private as squared needs to be updated at the same time
		private var minDistanceSquared	:Number;

		private var on					:Boolean;
		
		function Attraction(a:Particle, b:Particle, strength:Number, minDistance:Number) {

			this.a						= a;
			this.b						= b;
			this.strength				= strength;
			
			on							= true;
			
			this.minDistance			= minDistance;
			this.minDistanceSquared		= minDistance*minDistance;
			
		}
		
		public final function getMinimumDistance():Number {
			return minDistance;
		}
		
		public function setMinimumDistance(d:Number):void {
			minDistance = d;
			minDistanceSquared = d*d;
		}
		
		public final function turnOn():void {
			on = true;
		}
		
		public final function turnOff():void {
			on = false;
		}
		
		public final function isOn():Boolean {
			return on;
		}
		
		public final function isOff():Boolean {
			return !on;
		}
		
		public final function getStrength():Number {
			return strength;
		}
		
		public final function setStrength(k:Number):void {
			strength = k;
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
			return a;
		}
		
		public function apply():void {
			
			if ( on && ( a.isFree() || b.isFree() ) ) {
				
				var a2bX:Number = a.position.x - b.position.x;
				var a2bY:Number = a.position.y - b.position.y;
				var a2bZ:Number = a.position.z - b.position.z;

				var a2bDistanceSquared:Number = a2bX*a2bX + a2bY*a2bY + a2bZ*a2bZ;

				if ( a2bDistanceSquared < minDistanceSquared ) a2bDistanceSquared = minDistanceSquared;

				var force:Number = strength * a.mass * b.mass / a2bDistanceSquared;

				var length:Number = Math.sqrt( a2bDistanceSquared );

				a2bX /= length;
				a2bY /= length;
				a2bZ /= length;
				
				a2bX *= force;
				a2bY *= force;
				a2bZ *= force;

				if (a.isFree()) a.force = a.force.add( new Vector3D(-a2bX, -a2bY, -a2bZ) );
				if (b.isFree()) b.force = b.force.add( new Vector3D(a2bX, a2bY, a2bZ) );

			}
			
		}
		
	}
	
}