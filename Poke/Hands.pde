class Hands {
  PImage labelMapImage;
  PVector primaryHand[] = new PVector[5];
  PVector secondaryHand[] = new PVector[5];

  int PrimaryHandLabels[] = {
    PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB, 
    PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX, 
    PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE, 
    PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_RING, 
    PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY
  };

  int SecondaryHandLabels[] = {
    PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB, 
    PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_INDEX, 
    PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_MIDDLE, 
    PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_RING, 
    PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY|PXCMGesture.GeoNode.LABEL_FINGER_PINKY
  };


  Hands()
  { //init stuff
    int[] labelMapSize = new int[2];
    session.QueryLabelMapSize(labelMapSize);
    labelMapImage = createImage(labelMapSize[0], labelMapSize[1], RGB);
    for (int i=0;i<5;i++)
    {
      primaryHand[i] = new PVector(1, 1, 1);
      secondaryHand[i] = new PVector(1, 1, 1);
    }
  }

  void update(PXCUPipeline _session, boolean bDoAcquire)
 {
    if ( bDoAcquire ) _session.AcquireFrame(true);
    _session.QueryLabelMapAsImage(labelMapImage);

    for(int i=0;i<PrimaryHandLabels.length;i++)
    {
      PXCMGesture.GeoNode primaryHandNode=new PXCMGesture.GeoNode();
      if(_session.QueryGeoNode(PrimaryHandLabels[i], primaryHandNode))
      {
        //if(primaryHandNode.positionImage.x != 0 && primaryHandNode.positionWorld.x >0)
        //{
          primaryHand[i].x = primaryHandNode.positionImage.x;
          primaryHand[i].y = primaryHandNode.positionImage.y;
          primaryHand[i].z = map(primaryHandNode.positionWorld.y, 0, 1, 100, 0);
        //}
      } else {
        primaryHand[i].x =  primaryHand[i].y = primaryHand[i].z = 0;
      }
    }

    for (int i=0;i<SecondaryHandLabels.length;i++)
    {
      PXCMGesture.GeoNode secondaryHandNode=new PXCMGesture.GeoNode();
      if(_session.QueryGeoNode(SecondaryHandLabels[i], secondaryHandNode))
      {
        //if(secondaryHandNode.positionImage.x != 0 && secondaryHandNode.positionWorld.x >0)
        //{
          secondaryHand[i].x = secondaryHandNode.positionImage.x;
          secondaryHand[i].y = secondaryHandNode.positionImage.y;
          secondaryHand[i].z = map(secondaryHandNode.positionWorld.y, 0, 1, 100, 0);
        //}
      } else {
        secondaryHand[i].x =  secondaryHand[i].y = secondaryHand[i].z = 0;
      }
    }

    if ( bDoAcquire ) session.ReleaseFrame();
  }

  void drawPrimaryHand()
  {
    pushStyle();  
    fill(25, 255, 200, 200);
    for (int i = 0;i<5;i++) {
      if (primaryHand[i].x >0 && primaryHand[i].y > 0) {
        ellipse(primaryHand[i].x, primaryHand[i].y, 10, 10);
      }
    }
    popStyle();
  }

  void drawSecondaryHand()
  {
    pushStyle();  
    fill(25, 255, 200, 200);
    for (int i = 0;i<5;i++) {
      if (secondaryHand[i].x >0 && secondaryHand[i].y >0) {
        ellipse(secondaryHand[i].x, secondaryHand[i].y, 10, 10);
      }
    }
    popStyle();
  }

  void drawHands()
  {
    drawPrimaryHand();
    drawSecondaryHand();
  }
}

