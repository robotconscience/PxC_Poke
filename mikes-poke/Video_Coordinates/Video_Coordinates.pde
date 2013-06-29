import processing.video.*;

Capture cam;
PGraphics pg; //layer above video that turns red with successive hits

int lefteye_counter;
int righteye_counter;

void setup() {
  
  righteye_counter = 0;
  lefteye_counter = 0;

  size(1280, 720);
  


  String[] cameras = Capture.list();
  

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } 
  else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}

void draw() {
  //layer over video that turns red with hits
  pg = createGraphics(1280, 445);
  image(pg, 1280, 445); 
  if ( cam.available() == true) {
    cam.read();
  }
 
  set(0, 0, cam);
 
  }
  
  void keyPressed() {
   pg.beginDraw();
if (key == CODED) {
     if (keyCode == LEFT) {
      lefteye_counter++;
      println("left");
      switch(lefteye_counter){
        case 1:
          println("leftcount1");
          fill(255, 0, 0, 30);
          rect(0, 0, 640, 455);
          break;
        case 2:
        println("leftcount2");
          fill(255, 0, 0, 60);
          rect(0, 0, 640, 455);
          break;
        case 3:
        println("leftcount3");
          fill(255, 0, 0, 90);
          rect(0, 0, 640, 455);
          break;
          } 
                         }
       
    if (keyCode == RIGHT) {
      righteye_counter++;
       println("right");
      switch(righteye_counter){
        case 1:
        println("rightcount1");
          fill(255, 0, 0, 30);
          rect(641, 0, 1280, 445);
          break;
       case 2:
        println("rightcount2");
          fill(255, 0, 0, 60);
          rect(641, 0, 1280, 445);
      break;
        case 3:
        println("rightcount3");
          fill(255, 0, 0, 90);
          rect(641, 0, 1280, 445);
          break;
                              }
                           } 
                        }
 pg.endDraw();
}







