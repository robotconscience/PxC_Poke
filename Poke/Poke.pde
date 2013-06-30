import spacebrew.*;
import intel.pcsdk.*;
import org.json.*;
import saito.objloader.*;

// finger + face tracking
PXCUPipeline session;
Hands hands;
Landmarks lm;

// faces
Face myFace, theirFace;

boolean bPoking = false;
int pokeThreshold = 75;

// Spacebrew
Spacebrew sb;
String server="10.200.82.197";
String name="Spacebrew PxC Poke BR";
String description ="";

// messages
String eyeJSON = "";
String fingerJSON = "";
boolean bHit = false;

// rendering helpers
float scaleX = 1024.0 / 320.0;
float scaleY = 768.0 / 240.0;

// rough game state stuff
boolean bGameStarted = false;
boolean bGameEnded   = false;
int     gameStartedAt = 0;
int     lastSent     = 0;

int missOpacity = 255;

// layout stuff
PFont   fontBig, fontSmall;

void setup() {
  frameRate(60);
  size(1024, 768, P3D);
  smooth();
  

  myFace = new Face(this);
  theirFace = new Face(this);
  
  // get to brewin'
  sb = new Spacebrew(this);
  
  // try to load from external config
  String spacebrewConfig[] = loadStrings("spacebrew.txt");
  if ( spacebrewConfig != null && spacebrewConfig.length > 1 ){
    server = spacebrewConfig[0];
    name = spacebrewConfig[1];
  }
  
  // publishers: pxc stuff
  sb.addPublish( "eyes", "eyes", eyeJSON );
  sb.addPublish( "finger", "point", fingerJSON );
  sb.addPublish( "poke", "string", "" );

  // publishers: game logic
  sb.addPublish( "playerReady", "string", "" );
  sb.addPublish( "playerExit", "string", "" );

  // subscribers: pxc
  sb.addSubscribe( "eyes", "eyes" );
  sb.addSubscribe( "finger", "point" );
  sb.addSubscribe( "poke", "range" );
  
  // subscribers: game logic
  sb.addSubscribe( "startGame", "boolean" );
  sb.addSubscribe( "endGame", "boolean" );

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
  
  // layout
  fontBig = createFont("Franklin Gothic Medium", 50);
  fontSmall = createFont("Franklin Gothic Medium", 20);
  textFont( fontBig );
  
  println(PFont.list());
}

void exit(){
  sb.send("playerExit", name );
  println("trying to exit");
  super.exit();
}

void draw() { 
  // say we're ready if we haven't started
  if ( !bGameStarted ){
    if ( millis() - lastSent > 1000 ){
      lastSent = millis();
      sb.send("playerReady", name );
    }
  }
  
  background(255);
  if ( session.AcquireFrame(true ) ){
    hands.update(session, false);
    lm.update(session, false);
    
    updateFingers();
    updateFace();    
    session.ReleaseFrame();
  }
  
  // render!
  noFill();
  strokeWeight(.5);
  stroke(0,200,0);
  pushMatrix();
  translate(width/2, height/2, -500);
  box(width, height, 1000);
  popMatrix();
  
  fill(0);
  pushMatrix();
  String str = "";
  translate(width/2, height/2);
  float sc = abs(sin(millis() * .001))*.5;
  scale( 1.0 + sc,  1.0 + sc );
  textFont( fontBig );
  
  if ( !bGameStarted && !bGameEnded ){
    str = "WAITING FOR OPPONENT!";
  } else if (bGameStarted){
    if ( millis() - gameStartedAt > 1000 && millis() - gameStartedAt < 1500 ){
      str = "FIGHT!";
    } else if ( millis() - gameStartedAt < 1000 ){
      str = "WAIT FOR IT...";
    }
  } else if ( bGameEnded ){
    fill(255,0,0);
    str = "GAME OVER, MAN";
  }
  
  text(str, -textWidth(str)/2.0,0);
  popMatrix();
  fill(255);
  
  if ( bGameStarted || mousePressed ){
    pushMatrix();
    translate(0,0,-1000);
    theirFace.drawEnemy(255);
    popMatrix();
  }
  
  pushMatrix();
  translate(0,0,100);
  myFace.drawMe(100);
  popMatrix();
  noLights();
  
  textFont( fontSmall );
  noStroke();
  
  pushMatrix();
  fill(150,0,150);
  translate( width - 120, 20 );
  rect( 0,0, 100, 30 );
  fill(255);
  str = "SCORE";
  text( str, 10, 20 );
  
  translate( 0, 30 );
  
  fill(150,255,0);
  rect( 0,0, 100, 30 );
  str = "YOU: "+(theirFace.leftHit + theirFace.rightHit);
  fill(255);
  text( str, 10, 20 );
  
  translate( 0, 30 );
  
  fill(0,255,150);
  rect( 0, 0, 100, 30 );
  fill( 255);
  str = "THEM: "+(myFace.leftHit + myFace.rightHit);
  text( str, 10, 20 );
  popMatrix();
}

void onRangeMessage( String name, int value ){
  if (name.equals("poke")){
    println("GOT POKE!");
    myFace.onPoke( value );
    theirFace.finger.z = 1000;
  }
}

void onStringMessage ( String name, String value ){
  println("got message "+name);
}

void onBooleanMessage( String name, boolean value ){
  if (name.equals("startGame")){
    bGameStarted = true;
    gameStartedAt = millis();
    println("start game");
  } else if ( name.equals("endGame")){
    bGameStarted = false;
    bGameEnded   = true;
    
  }
}

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
     
   }
   
}

/********************************************
  POKE: Check against current face, send if
  it's a hit
********************************************/

void poke( PVector finger ){
  int test = theirFace.checkHit(finger.x, finger.y);

  println(test);
  if ( mousePressed) test = 1;
  switch ( test ){
    case 1:
      // left eye hit!
      sb.send( "poke", name + ":0" );
      break;
    case 2:
      // right eye hit!
      sb.send( "poke", name + ":1" );
      break;
    default:
      sb.send( "poke", name + ":2" );
      break;
  }
}

/********************************************
  Grab first valid fingertip + send
********************************************/
void updateFingers(){
  // finger can really be any one of five, but we do stop at the first one...
    for (int i = 0;i<5;i++) {
      if (hands.primaryHand[i].x >0) { //check to see if it's null
        myFace.updateFinger( (float) (320.0f - hands.primaryHand[i].x) / 320.f, (float) hands.primaryHand[i].y / 240.f, hands.primaryHand[i].z );
        //ellipse(width - hands.primaryHand[i].x * scaleX, hands.primaryHand[i].y * scaleY, hands.primaryHand[i].z, hands.primaryHand[i].z);
        if ( hands.primaryHand[i].z > pokeThreshold ){
          if ( !bPoking ){
            bPoking = true;
            poke( myFace.finger );
            myFace.finger.z -= 1000;
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
        myFace.updateFinger( (float) (320.0f - hands.secondaryHand[i].x) / 320.f, (float) hands.secondaryHand[i].y / 240.f );
        //ellipse(width - hands.secondaryHand[i].x * 2.0, hands.secondaryHand[i].y * 2.0, hands.secondaryHand[i].z, hands.secondaryHand[i].z);
        if ( hands.secondaryHand[i].z > pokeThreshold ){
          if ( !bPoking ){
            bPoking = true;
            poke( myFace.finger );
            myFace.finger.z -= 1000;
          }
        } else {
          bPoking = false;
        }
        
        // send raw finger
        fingerJSON = "{\"x\": " + (float) (320.0f - hands.secondaryHand[i].x) / 320.f + " ,\"y\":" + (float) hands.secondaryHand[i].y / 240.f + "}"; 
        sb.send("finger", "point", fingerJSON );
        break;
      }
    }
}

/********************************************
  Update eyeballs
********************************************/
void updateFace(){
    // send face
    eyeJSON = "{\"left\":{\"x\":"+ lm.leftEye.x / 640.0f +", \"y\":"+ lm.leftEye.y / 480.f +"},\"right\":{\"x\":" + lm.rightEye.x / 640.f +", \"y\":" + lm.rightEye.y / 480.f +"}}";
    myFace.updateEyes( lm.leftEye.x / 640.0f, lm.leftEye.y / 480.f, lm.rightEye.x / 640.f, lm.rightEye.y / 480.f);
    sb.send("eyes", "eyes", eyeJSON );
}

