import spacebrew.*;
import intel.pcsdk.*;

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

// incoming

void setup() {
  size(640, 480);
  
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
        ellipse(width - hands.primaryHand[i].x * 2.0, hands.primaryHand[i].y * 2.0, hands.primaryHand[i].z, hands.primaryHand[i].z);
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
        fingerJSON = "{\"x\": " + hands.primaryHand[i].x + " ,\"y\":" + hands.primaryHand[i].y + "}"; 
        sb.send("finger", "point", fingerJSON );
        break;
      }
      if (hands.secondaryHand[i].x >0) { //check to see if it's null
        ellipse(width - hands.secondaryHand[i].x * 2.0, hands.secondaryHand[i].y * 2.0, hands.secondaryHand[i].z, hands.secondaryHand[i].z);
        if ( hands.secondaryHand[i].z > pokeThreshold ){
          background(255,0,0);
        }
        
        // send raw finger
        fingerJSON = "{\"x\": " + hands.primaryHand[i].x + " ,\"y\":" + hands.primaryHand[i].y + "}"; 
        sb.send("finger", "point", fingerJSON );
        break;
      }
    }
    
    lm.drawFace();
    
    // send face
    eyeJSON = "{\"left\":{\"x\":"+ lm.leftEye.x +", \"y\":"+ lm.leftEye.y +"},\"right\":{\"x\":" + lm.rightEye.x +", \"y\":" + lm.rightEye.y +"}}";
    sb.send("eyes", "eyes", eyeJSON );
    session.ReleaseFrame();
  }
}

// coming from andy
void onCustomMessage( String name, String value ){
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

