class Face {
  
  // props
  PVector leftEye   = new PVector(-1,-1);
  PVector rightEye   = new PVector(-1,-1);
  PVector finger     = new PVector(-1,-1);
  PVector miss = new PVector(-1,-1);
  
  PImage  image;
  PGraphics hit;
  
  // hit counter
  int leftHit   = 0;
  int rightHit  = 0;
  
  // hit threshold aka eye radius
  float hitThresh = 40;

  Face(){
    image = loadImage( "horrifying.png" );
    hit = createGraphics(1024,768);
    hit.clear();
  }
  
  /**  
   * @return one, 1 = left, 2 = right
   */
  int checkHit( float x, float y ){
    PVector check = new PVector(x, y);
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
    
    //tint(255, alpha);
    float centerX = (rightEye.x + leftEye.x)/ 2.0;
    float centerY = (rightEye.y + leftEye.y)/ 2.0;
    float scale = (float) abs(rightEye.x - leftEye.x) / image.width;
    
    //image( image, centerX - image.width/ 2.0, centerY, image.width * scale, image.height * scale);
    
    //fill( 255, alpha );
    ellipse(leftEye.x, leftEye.y, 20, 20 );
    ellipse(rightEye.x, rightEye.y, 20, 20 );
    
    //ellipse( finger.x, finger.y, 20, 20 );
    pushMatrix();
    translate( finger.x, finger.y, finger.z);
    lights();  
    box(20,20,500);
    popMatrix();
    
    if (miss.x != 0)
    {
      pushMatrix();
      translate(miss.x, miss.y);
      
      stroke(255);
      line(-10,-10,10,10);
      line(-10,10,10,-10);
      popMatrix();
    }
    
    finger.z *= .8;
  }
  
  void drawEnemy( float alpha ){
    fill(255);
    noStroke();
    pushMatrix();
    translate(0,0,-200);
    image(hit,0,0);
    popMatrix();
    
    stroke(255, alpha);
    float centerX = (rightEye.x + leftEye.x)/ 2.0;
    float centerY = (rightEye.y + leftEye.y)/ 2.0;
    float scale = (float) abs(leftEye.x - rightEye.x) / image.width;
    
    pushMatrix();
    translate(centerX, centerY, -200);
    scale(1,1.8);
    sphere(100);
    popMatrix();
    
    stroke(255,0,0);
    if ( leftEye.x >= 0 ){
      line(leftEye.x-10, leftEye.y-10,leftEye.x+10, leftEye.y+10);
      line(leftEye.x+10, leftEye.y-10,leftEye.x-10, leftEye.y+10);
      
      line(rightEye.x-10, rightEye.y-10,rightEye.x+10, rightEye.y+10);
      line(rightEye.x+10, rightEye.y-10,rightEye.x-10, rightEye.y+10);
    }
    fill(255);
    if ( finger.x >= 0){
      fill( 255, alpha );
      ellipse( finger.x, finger.y, 20, 20 );
    }
  }
  
  void updateEyes( float leftX, float leftY, float rightX, float rightY ){
    leftEye.set(leftX * width, leftY * height, 0);
    rightEye.set(rightX * width, rightY * height, 0);
  }
  
  void updateFinger( float x, float y ){
    finger.set(x * width,y * height);
  }
  
  void updateFinger( float x, float y, float z ){
    finger.x = finger.x * .9 + (x * width) * .1;
    finger.y = finger.y * .9 + (y * height) * .1;
  }
  
  void onPoke( int state ){
    if ( state == 0 ){
      leftHit++;
    } else if ( state == 1){
      rightHit++;
    }
  }
}
