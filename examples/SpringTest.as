package {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import flash.display.Bitmap;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	
	import traer.physics.ParticleSystem;
	import traer.physics.Particle;
	import traer.physics.Spring;
	
	import com.sqrtof5.geom.CatmullRomSpline;
		
	[ SWF (width=600, height=600, backgroundColor=0xd6d6d6, frameRate=31) ]
	
	public class SpringTest extends Sprite {
		
		[ Embed (source="_assets/handle.png") ]
		public var Img:Class;
		
		private var s				:ParticleSystem;
		private var p				:Vector.<Particle>;
		private var anchor			:Particle;
		
		private var spring_length	:Number = 70;
		private var subdivisions	:uint = 5;
		
		private var handle_img		:Sprite;
		private var isDragging		:Boolean;
		
		private var spline			:CatmullRomSpline;
		
		function SpringTest() {
			
			s = new ParticleSystem(new Vector3D(0, 2, 0), .15);
			p = new Vector.<Particle>();
			
			var _bm:Bitmap = new Img() as Bitmap;
			_bm.smoothing = true;
			handle_img = new Sprite();
			var handle_img_cont:Sprite = new Sprite();
			handle_img_cont.addChild(_bm);
			handle_img.addChild(handle_img_cont);
			_bm.x = -16;
			_bm.y = -16;
			addChild(handle_img);
			
			var sy:Number = 200;
			
			anchor = s.makeParticle(1, new Vector3D(300, sy, 0));
			anchor.makeFixed();
			p.push(anchor);
			
			var sub_len:Number = spring_length/subdivisions;
			for (var i:uint=1; i<=subdivisions; i++) {
				p.push(s.makeParticle(.6, new Vector3D(300, sy + i*sub_len, 0)));
			}
			
			for (i=0; i<p.length-1; i++)  {
				s.makeSpring(p[i], p[i+1], .5, .2, sub_len);
			} 
			
			handle_img.buttonMode = true;
			handle_img.mouseChildren = false;
			handle_img.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvents);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseEvents);
			
			spline = new CatmullRomSpline(getVerticesFromParticles(), 6, .5, false);
			
			//render
			addEventListener(Event.ENTER_FRAME, render);
			
		}
		
		private function getVerticesFromParticles():Vector.<Vector3D> {
			
			var vertices:Vector.<Vector3D> = new Vector.<Vector3D>();
			for (var i:uint=1; i<p.length; i++) { //skip 1st point so the string appears to float ;)
				vertices.push(p[i].position);
			}
			
			return vertices;
			
		}
		
		private function handleMouseEvents(evt:MouseEvent):void {
			
			switch(evt.type) {
				
				case MouseEvent.MOUSE_DOWN:
					isDragging = true;
					handle_img.startDrag();
					break;
				
				case MouseEvent.MOUSE_UP:
					isDragging = false;
					handle_img.stopDrag();
					break;
				
			}
			
		}
		
		private function render(evt:Event):void {
			
			s.tick(1.8);
			spline.updateVertices(getVerticesFromParticles());
			
			
			if (! isDragging) {
				p[subdivisions].makeFree();
				handle_img.x = p[subdivisions].position.x;
				handle_img.y = p[subdivisions].position.y;
			} else {
				p[subdivisions].makeFixed();
				p[subdivisions].position.x = handle_img.x;
				p[subdivisions].position.y = handle_img.y;
			}
			
			graphics.clear();
			graphics.lineStyle(2, 0x333333, .5);
			
			var pts:Vector.<Point> = spline.getPoints();
			graphics.moveTo(pts[0].x, pts[0].y);
			for (var i:uint=1; i<pts.length; i++) {
				graphics.lineTo(pts[i].x, pts[i].y);
			}
						
		}
		
	}
	
}