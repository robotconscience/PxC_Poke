class Face {
  
  // props
  PVector leftEye   = new PVector(-1,-1);
  PVector rightEye   = new PVector(-1,-1);
  PVector finger     = new PVector(-1,-1);
  
  PImage  image;
  
  // hit counter
  int leftHit   = 0;
  int rightHit  = 0;
  
  // hit threshold aka eye radius
  float hitThresh = 20;

  Face(){
    image = loadImage( "horrifying.png" );
  }
  
  /**  
   * @return one, 1 = left, 2 = right
   */
  int checkHit( float x, float y ){
    PVector check = new PVector(x, y);
    println(  check.dist(leftEye) );
    println(  check.dist(rightEye) );
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
    
    image( image, centerX - image.width * scale / 2.0, centerY, image.width * scale, image.height * scale);
    
    fill( 255, alpha );
    ellipse(leftEye.x, leftEye.y, 20, 20 );
    ellipse(rightEye.x, rightEye.y, 20, 20 );
    ellipse( finger.x, finger.y, 20, 20 );
  }
  
  void drawEnemy( float alpha ){
    stroke(255, alpha);
    float centerX = rightEye.x - leftEye.x;
    float centerY = rightEye.y - leftEye.y;
    float scale = (float) abs(leftEye.x - rightEye.x) / image.width;
    
    image( image, centerX, centerY - image.height * .8, image.width * scale, image.height * scale);
    if ( leftEye.x >= 0 ){
      line(leftEye.x-10, leftEye.y-10,leftEye.x+10, leftEye.y+10);
      line(leftEye.x+10, leftEye.y-10,leftEye.x-10, leftEye.y+10);
      
      line(rightEye.x-10, rightEye.y-10,rightEye.x+10, rightEye.y+10);
      line(rightEye.x+10, rightEye.y-10,rightEye.x-10, rightEye.y+10);
    }
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
  
  void onPoke( int state ){
    if ( state == 0 ){
      leftHit++;
    } else if ( state == 1){
      rightHit++;
    }
  }
}
