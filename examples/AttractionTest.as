package {

	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.geom.Vector3D;
	import flash.events.Event;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	import traer.physics.Spring;
		
	[ SWF (width=600, height=600, backgroundColor=0xd6d6d6, frameRate=31) ]

	public class AttractionTest extends Sprite {
		
		private var s			:ParticleSystem;
		private var particle	:Particle;
		private var anchor		:Particle;
		private var attractor	:Particle;
		private var spring		:Spring;
		
		[ Embed (source="_assets/anchor.png") ]
		private var AnchorGfx		:Class;
		private var _anchor_gfx		:Bitmap;
		
		[ Embed (source="_assets/large_particle.png") ]
		private var ParticleGfx		:Class;
		private var _particle_gfx	:Bitmap;
		
		[ Embed (source="_assets/attract_radius.png") ]
		private var AttractorGfx	:Class;
		private var _attractor_gfx	:Bitmap;
		
		function AttractionTest() {
			
			s			= new ParticleSystem(new Vector3D(0, 0, 0), .3);
			anchor		= s.makeParticle(1, new Vector3D(300, 300, 0)); anchor.makeFixed();
			particle	= s.makeParticle(1, new Vector3D(300, 300, 0));
			attractor	= s.makeParticle(1, new Vector3D(300, 300, 0)); attractor.makeFixed();

			spring		= s.makeSpring(anchor, particle, .1, .01, 0);			
			s.makeAttraction(attractor, particle, 9000, 30);
			
			// visuals
			_anchor_gfx = new AnchorGfx() as Bitmap;
			addChild(_anchor_gfx);
			_particle_gfx = new ParticleGfx() as Bitmap;
			addChild(_particle_gfx);
			_attractor_gfx = new AttractorGfx() as Bitmap;
			addChild(_attractor_gfx);
			
			// render
			addEventListener(Event.ENTER_FRAME, render);
			
		}
		
		private function render(evt:Event):void {
			
			s.tick(1);

			graphics.clear();
			graphics.lineStyle(1, 0xFF0000, .6);
			graphics.moveTo(anchor.position.x, anchor.position.y);
			graphics.lineTo(particle.position.x, particle.position.y);
			
			attractor.position.x = mouseX;
			attractor.position.y = mouseY;
			
			_anchor_gfx.x = anchor.position.x - 7;
			_anchor_gfx.y = anchor.position.y - 7;
			_particle_gfx.x = particle.position.x - 21;
			_particle_gfx.y = particle.position.y - 21;
			_attractor_gfx.x = attractor.position.x - 47;
			_attractor_gfx.y = attractor.position.y - 47;
			
		}
		
	}

}