class Face {
  
  // props
  PVector leftEye   = new PVector(-1,-1);
  PVector rightEye   = new PVector(-1,-1);
  PVector finger     = new PVector(-1,-1);
  PVector miss = new PVector(-1,-1);
  
  OBJModel model;
  
  boolean bHasFinger = false;
  boolean bHasFace = false;
  
  int lastFinger = 0;
  int lastFace = 0;
  
  PImage  image;
  PGraphics hit;
  
  // hit counter
  int leftHit   = 0;
  int rightHit  = 0;
  
  // hit threshold aka eye radius
  float hitThresh = 20;

  int missOpacity = 0;
  
  Face( PApplet parent ){
    model = new OBJModel(parent, "finger.obj", "absolute", TRIANGLES);
    model.enableDebug();

    model.scale(10);
    model.translateToCenter();
    
    
    hit = createGraphics(1024,768);
    hit.clear();
  }
  
  /**  
   * @return one, 1 = left, 2 = right
   */
  int checkHit( float x, float y ){
    PVector check = new PVector(x, y);
    miss.set(x,y);
    missOpacity = 255;
    
//    hit.beginDraw();
//    fill(255,0,0);
//    ellipse(x,y,20,20);
//    hit.endDraw();
    if ( check.dist(leftEye) < hitThresh ){
      leftHit++;
      return 1;
    } else if ( check.dist(rightEye) < hitThresh ){
      rightHit++;
      return 2;
    }
    return 0;
  }
  
  void drawMe( float alpha ){
    noStroke();
    
    drawFace( alpha, true);
    
    if ( bHasFinger ){
      
      //ellipse( finger.x, finger.y, 20, 20 );
      fill(255);
      pushMatrix();
      translate( finger.x, finger.y + 60, finger.z + 200);
      rotateX(radians(90));
      rotateZ(radians(270));
//      rotateY(radians(180));
      lights();  
      model.draw();
      //box(20,20,500);
      popMatrix();
      
      stroke(0);
      line( finger.x, finger.y, finger.z, finger.x, finger.y, finger.z - 1000);
      
//      ellipse( finger.x, finger.y, 20, 20 );
      
      finger.z *= .8;
    }
    
    updateValidStuff();
  }
  
  void drawEnemy( float alpha ){
    fill(255);
    drawFace( alpha, false);
    
    if (miss.x != 0)
    {
      if (missOpacity > 1) { missOpacity-=20;}
      
      pushMatrix();
      translate(miss.x, miss.y);
      stroke(255,0,0,missOpacity);
      line(-10,-10,10,10);
      line(-10,10,10,-10);
      popMatrix();
    }
    
    fill(255);
    if ( finger.x >= 0){
//      fill( 255, alpha );
//      ellipse( finger.x, finger.y, 20, 20 );
      pushMatrix();
      translate( finger.x, finger.y + 60, finger.z - 200);
      rotateX(radians(90));
      rotateZ(radians(90));
      lights();  
      model.draw();
      popMatrix();
    }
    
    updateValidStuff();
  }
  
  void drawFace( float alpha, boolean myFace) {
    if ( bHasFace ){
      if ( myFace ){
        noFill();
        stroke( 150, alpha );
      } else {
        fill( 150, alpha );
      }      
      float centerX = (rightEye.x + leftEye.x)/ 2.0;
      float centerY = (rightEye.y + leftEye.y)/ 2.0;
      
      float w = (leftEye.x - rightEye.x) * 1.5;
      float h = w * 1.7;
      
      ellipse( centerX, centerY, w, h );
      ellipse(leftEye.x, leftEye.y, 20, 20 );
      ellipse(rightEye.x, rightEye.y, 20, 20 );
 
      if (true)
      {
          pushStyle();
          noFill();
          strokeWeight(3*leftHit);
          stroke(255,0,0);
          ellipse(leftEye.x, leftEye.y, 20, 20 );
          
          strokeWeight(3*rightHit);
          stroke(255,0,0);
          ellipse(rightEye.x, rightEye.y, 20, 20);
          popStyle();
      }
    }
  }
  
  void updateValidStuff(){
    // check how long it's been since you saw a finger/face
    if ( millis() - lastFinger > 2000 ){
      bHasFinger = false;
    }
    
    if ( millis() - lastFace > 2000 ){
      bHasFace = false;
    }
  }
  
  void updateEyes( float leftX, float leftY, float rightX, float rightY ){
    leftEye.set(leftX * width, leftY * height, 0);
    rightEye.set(rightX * width, rightY * height, 0);
    
    bHasFace = true;
    lastFace = millis();
  }
  
  void updateFinger( float x, float y ){
    finger.set(x * width,y * height);
    
    bHasFinger = true;
    lastFinger = millis();
  }
  
  void updateFinger( float x, float y, float z ){
    finger.x = finger.x * .9 + (x * width) * .1;
    finger.y = finger.y * .9 + (y * height) * .1;
    
    bHasFinger = true;
    lastFinger = millis();
  }
  
  void onPoke( int state ){
    if ( state == 0 ){
      leftHit++;
    } else if ( state == 1){
      rightHit++;
    }
  }
}
