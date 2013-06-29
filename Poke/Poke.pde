import spacebrew.*;
import intel.pcsdk.*;
import org.json.*;

// finger + face tracking
PXCUPipeline session;
Hands hands;
Landmarks lm;

// opponent's face
Face theirFace = new Face();

boolean bPoking = false;
int pokeThreshold = 75;

// Spacebrew
Spacebrew sb;
String server="sandbox.spacebrew.cc";
String name="Spacebrew PxC Poke";
String description ="";

// messages
String eyeJSON = "";
String fingerJSON = "";
boolean bHit = false;

// rendering helpers
float scaleX = 1024.0 / 320.0;
float scaleY = 768.0 / 240.0;

void setup() {
  size(1024, 768);
  
  // get to brewin'
  sb = new Spacebrew(this);
  
  // declare your publishers
  sb.addPublish( "eyes", "eyes", eyeJSON );
  sb.addPublish( "finger", "point", fingerJSON );
  sb.addPublish( "hit", "range", bHit );

  // declare your subscribers
  sb.addSubscribe( "eyes", "eyes" );
  sb.addSubscribe( "finger", "point" );
  sb.addSubscribe( "hit", "range" );

  // connect!
  sb.connect(server, name, description );
  
  // setup PxC stuff
  session = new PXCUPipeline(this);
  if (!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.FACE_LANDMARK|PXCUPipeline.COLOR_VGA)) {
    print("Failed to initialize PXCUPipeline\n");
    exit();
  }
  
  hands = new Hands(); //requires PXCUPipeline session to init(PXCUPipeline.GESTURE)
  lm = new Landmarks();
}

void draw() { 
  background(0);
  if ( session.AcquireFrame(true ) ){
    hands.update(session, false);
    lm.update(session, false);
    
    // finger can really be any one of five, but we do stop at the first one...
    for (int i = 0;i<5;i++) {
      if (hands.primaryHand[i].x >0) { //check to see if it's null
        ellipse(width - hands.primaryHand[i].x * scaleX, hands.primaryHand[i].y * scaleY, hands.primaryHand[i].z, hands.primaryHand[i].z);
        if ( hands.primaryHand[i].z > pokeThreshold ){
          if ( !bPoking ){
            bPoking = true;
            background(255,0,0);
            poke( hands.primaryHand[i].x, hands.primaryHand[i].y );
          }
        } else {
          bPoking = false;
        }
        // send raw finger
        fingerJSON = "{\"x\": " + (float) (320.0f - hands.primaryHand[i].x) / 320.f + " ,\"y\":" + (float) hands.primaryHand[i].y / 240.f + "}"; 
        sb.send("finger", "point", fingerJSON );
        break;
      }
      if (hands.secondaryHand[i].x >0) { //check to see if it's null
        ellipse(width - hands.secondaryHand[i].x * 2.0, hands.secondaryHand[i].y * 2.0, hands.secondaryHand[i].z, hands.secondaryHand[i].z);
        if ( hands.secondaryHand[i].z > pokeThreshold ){
          background(255,0,0);
        }
        
        // send raw finger
        fingerJSON = "{\"x\": " + (float) (320.0f - hands.secondaryHand[i].x) / 320.f + " ,\"y\":" + (float) hands.secondaryHand[i].y / 240.f + "}"; 
        sb.send("finger", "point", fingerJSON );
        break;
      }
    }
    
    pushMatrix();
    scale(scaleX/2.0,scaleY/2.0);
    lm.drawFace();
    popMatrix();
    
    // send face
    eyeJSON = "{\"left\":{\"x\":"+ lm.leftEye.x / 640.0f +", \"y\":"+ lm.leftEye.y / 480.f +"},\"right\":{\"x\":" + lm.rightEye.x / 640.f +", \"y\":" + lm.rightEye.y / 480.f +"}}";
    sb.send("eyes", "eyes", eyeJSON );
    session.ReleaseFrame();
  }
}

// coming from andy
void onCustomMessage( String name, String type, String value ) {

   org.json.JSONObject m = new org.json.JSONObject( value );
   
   if (name.equals("eyes"))
   {
     org.json.JSONObject l = m.getJSONObject("left");
     org.json.JSONObject r = m.getJSONObject("right");
     
     theirFace.updateEyes((float)l.getDouble("x"),(float)l.getDouble("y"),(float)r.getDouble("x"),(float)r.getDouble("y"));     
     
   } else if (name.equals("finger")) {
     
     theirFace.updateFinger((float)m.getDouble("x"), (float)m.getDouble("y"));
  
     //YourFinger.update();
   } else if (name.equals("poke")) {
     //Hit();
   }
   
}


/********************************************
  POKE: Check against current face, send if
  it's a hit
********************************************/

void poke( float x, float y ){
  int test = theirFace.checkHit(x, y);
  switch ( test ){
    case 1:
      // left eye hit!
      sb.send( "hit", 0 );
      break;
    case 2:
      // right eye hit!
      sb.send( "hit", 1 );
      break;
    default:
      // crickets
  }
}

