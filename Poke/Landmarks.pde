class Landmarks
{
  //landmarks requires a color image
  PImage colorImage;

  PXCMFaceAnalysis.Detection.Data faceLoc;

  PVector leftEye;
  PVector rightEye;
  PVector mouth;
  float faceX, faceY, faceWidth, faceHeight;
  PVector spots[] = new PVector[6];

  int faceLabels[] = {
    PXCMFaceAnalysis.Landmark.LABEL_LEFT_EYE_OUTER_CORNER, 
    PXCMFaceAnalysis.Landmark.LABEL_LEFT_EYE_INNER_CORNER, 
    PXCMFaceAnalysis.Landmark.LABEL_RIGHT_EYE_OUTER_CORNER, 
    PXCMFaceAnalysis.Landmark.LABEL_RIGHT_EYE_INNER_CORNER, 
    PXCMFaceAnalysis.Landmark.LABEL_MOUTH_LEFT_CORNER, 
    PXCMFaceAnalysis.Landmark.LABEL_MOUTH_RIGHT_CORNER
  };

  Landmarks()
  { //init stuff
    colorImage = createImage(640, 480, RGB);
    for (int i=0;i<6;i++)
    {
      spots[i] = new PVector(1, 1, 1);
    }
  }
  
  void update(PXCUPipeline _session, boolean bDoAcquire )
  {
    if(_session.AcquireFrame(false) || !bDoAcquire)
    {
      _session.QueryRGB(colorImage);
      
      long[] faces = new long [4]; //how many faces do you intend to track? times 2
      if (_session.QueryFaceID(0, faces))
      {
        for (int f=0;f<faces.length;f+=2)
        {
          int faceId = int(faces[f]);
          faceLoc = new PXCMFaceAnalysis.Detection.Data();
          if (_session.QueryFaceLocationData(faceId, faceLoc))
          {
            faceX = faceLoc.rectangle.x;
            faceY = faceLoc.rectangle.y;
            faceWidth = faceLoc.rectangle.w;
            faceHeight = faceLoc.rectangle.h;
          }
  
          for (int i=0;i<faceLabels.length;i++)
          {
            PXCMFaceAnalysis.Landmark.LandmarkData facePts2 = new PXCMFaceAnalysis.Landmark.LandmarkData();
            if(_session.QueryFaceLandmarkData(faceId, faceLabels[i], faceId, facePts2))//faceLabels[i]
            {
              if(facePts2.position.x != 0)
              {
                spots[i].x = facePts2.position.x;
                spots[i].y = facePts2.position.y;
              }
            }
          }
        }
      }
      //Figure out centers of eyes, Z is set by the distance between end points
      leftEye = new PVector((spots[0].x+spots[1].x)/2, (spots[0].y+spots[1].y)/2, dist(spots[0].x, spots[0].y, spots[1].x, spots[1].y));
      rightEye = new PVector((spots[2].x+spots[3].x)/2, (spots[2].y+spots[3].y)/2, dist(spots[2].x, spots[2].y, spots[3].x, spots[3].y));
      mouth = new PVector((spots[4].x+spots[5].x)/2, (spots[4].y+spots[5].y)/2, dist(spots[4].x, spots[4].y, spots[5].x, spots[5].y));
      if ( bDoAcquire ) _session.ReleaseFrame();
    }
  }

  void drawFace()
  {
    pushStyle();  
    noFill();
    stroke(255);
    strokeWeight(2);
    rect(faceX, faceY, faceWidth, faceHeight);

    ellipse(rightEye.x, rightEye.y, rightEye.z, rightEye.z);
    ellipse(leftEye.x, leftEye.y, leftEye.z, leftEye.z);
    rectMode(RADIUS);
    rect(mouth.x, mouth.y, mouth.z/2, 20);
    popStyle();
  }
}

