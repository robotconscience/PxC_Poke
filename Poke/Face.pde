class Face {
  
  // props
  PVector leftEye   = new PVector(0,0);
  PVector rightEye   = new PVector(0,0);
  PVector finger     = new PVector(0,0);
  
  // hit counter
  int leftHit   = 0;
  int rightHit  = 0;
  
  // hit threshold aka eye radius
  float hitThresh = 20;

  Face(){
  }
  
  /**
   * @returns int 0-2; 0 = none, 1 = left, 2 = right
   */
  int checkHit( float x, float y ){
    PVector check = new PVector(x, y);
    if ( check.dist(leftEye) < hitThresh ){
      leftHit++;
      return 1;
    } else if ( check.dist(rightEye) < hitThresh ){
      rightHit++;
      return 2;
    }
    return 0;
  }
  
  void draw(){
    line(leftEye.x-10, leftEye.y-10,leftEye.x+10, leftEye.y+10);
    line(leftEye.x+10, leftEye.y-10,leftEye.x-10, leftEye.y+10);
    
    line(rightEye.x-10, rightEye.y-10,rightEye.x+10, rightEye.y+10);
    line(rightEye.x+10, rightEye.y-10,rightEye.x-10, rightEye.y+10);
  }
  
  void updateEyes( float leftX, float leftY, float rightX, float rightY ){
    leftEye.set(leftX * width, leftY * height, 0);
    rightEye.set(rightX * width, rightY * height, 0);
  }
  
  void updateFinger( float x, float y ){
    finger.set(x * width,y * height);
  }

}
