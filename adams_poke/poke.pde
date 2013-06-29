//import org.json.*;

/*
 * Base Example 
 *
 *   Sketch that features the basic building blocks of a Spacebrew client app.
 * 
 */

import spacebrew.*;
import org.json.*;

String server = "sandbox.spacebrew.cc"; //server="spacebrew.madsci1.havasworldwide.com";
String name="Poke Client";
String description ="This is an blank example client that publishes .... and also listens to ...";

Spacebrew sb;

eyes YourEyes;
finger YourFinger;

int WIDTH = 800;
int HEIGHT = 600;

class finger
{
  float x,y;
  
  finger()
  {
    
  }
  
  void draw()
  {
    ellipse(WIDTH*x,HEIGHT*y,10,10);
  }

  void update(float _x, float _y)
  {
    x = _x;
    y = _y;
  }
  
}

class eyes
{
  float lx,ly,rx,ry;
  
  eyes ()
  {
     lx = 0; 
     ly = 0; 
     rx = 0; ry = 0;
  }
  
  void draw()
  {
    ellipse(WIDTH*lx,HEIGHT*ly,20,20);
    ellipse(WIDTH*rx,HEIGHT*ry,20,20);
  }
  
  void update(float _lx, float _ly, float _rx, float _ry)
  {
    lx = _lx;
    ly = _ly;
    rx = _rx;
    ry = _ry;
  }
}

void setup() {
  
  size(WIDTH, HEIGHT);

	// instantiate the sb variable
  sb = new Spacebrew( this );

	// add each thing you publish to
	// sb.addPublish( "buttonPress", "boolean", buttonSend ); 

  // add each thing you subscribe to
  sb.addSubscribe( "eyes", "eyes" );
  sb.addSubscribe( "finger", "point" );
  sb.addSubscribe( "poke", "range" );

	// connect to spacebrew
	sb.connect(server, name, description );

  YourEyes = new eyes();
  YourFinger = new finger();

}

void draw() {
  background(0);
	// do whatever you want to do here

    YourEyes.draw();
    YourFinger.draw();
}


void onRangeMessage( String name, int value ){
	println("got range message " + name + " : " + value);
}

void onBooleanMessage( String name, boolean value ){
	println("got boolean message " + name + " : " + value);  
}

void onStringMessage( String name, String value ){
	println("got string message " + name + " : " + value);  
}


void onCustomMessage( String name, String type, String value ) {

   println(name);
   println(value);
 
   JSONObject m = new JSONObject( value );
   
   if (name.equals("eyes"))
   {
     JSONObject l = m.getJSONObject("left");
     JSONObject r = m.getJSONObject("right");
     
     YourEyes.update((float)l.getDouble("x"),(float)l.getDouble("y"),(float)r.getDouble("x"),(float)r.getDouble("y"));     
     
   } else if (name.equals("finger")) {
     
     YourFinger.update((float)m.getDouble("x"), (float)m.getDouble("y"));
  
     //YourFinger.update();
   } else if (name.equals("poke")) {
     //Hit();
   }
   
}

