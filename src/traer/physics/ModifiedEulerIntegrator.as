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
	
	public class ModifiedEulerIntegrator implements Integrator {
		
		private var s	:ParticleSystem;
		
		function ModifiedEulerIntegrator(s:ParticleSystem) {
			this.s = s;
		}
		
		public function step(t:Number):void {
			
			var particles:Vector.<Particle> = s.particles;
			var p_length:uint = particles.length;
			
			s.clearForces();
			s.applyForces();
			
			var halftt:Number = (t*t)*.5;
			var one_over_t:Number = 1/t;
			
			for (var i:uint = 0; i<p_length; i++) {
				
				var p:Particle = particles[i];
				
				if (! p.fixed) {
					
					var ax:Number = p.force.x/p.mass;
					var ay:Number = p.force.y/p.mass;
					var az:Number = p.force.z/p.mass;
					
					var vel_div_t:Vector3D = p.velocity.clone();
					vel_div_t.scaleBy(one_over_t);
					p.position = p.position.add(vel_div_t);
					p.position = p.position.add(new Vector3D(ax*halftt, ay*halftt, az*halftt));
					p.velocity = p.velocity.add(new Vector3D(ax*one_over_t, ay*one_over_t, az*one_over_t));
					
				}
				
			}

		}
		
	}
	
}