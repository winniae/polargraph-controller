
/**
*
*
*
*/
class Machine
{
  protected PVector machineSize = null;

  protected Rectangle page = null;
  protected Rectangle imageFrame = null;
  protected Rectangle pictureFrame = null;

  protected Float stepsPerRev = 800.0;
  protected Float mmPerRev = 95.0;
  
  protected Float mmPerStep = null;
  protected Float stepsPerMM = null;
  protected Float maxLength = null;
  protected Float gridSize = null;
  protected List<Float> gridLinePositions = null;
  
  protected PImage imageBitmap = null;
  protected String imageFilename = null;
  
  
  public Machine(Integer width, Integer height, Float stepsPerRev, Float mmPerRev)
  {
    this.setSize(width, height);
    this.setStepsPerRev(stepsPerRev);
    this.setMMPerRev(mmPerRev);
  }
  
  public void setSize(Integer width, Integer height)
  {
    PVector s = new PVector(width, height);
    this.machineSize = s;
    maxLength = null;
  }
  public PVector getSize()
  {
    return this.machineSize;
  }
  public Float getMaxLength()
  {
    if (maxLength == null)
    {
      maxLength = dist(0,0, getWidth(), getHeight());
    }
    return maxLength;
  }
  
  public void setPage(Rectangle r)
  {
    this.page = r;
  }
  public Rectangle getPage()
  {
    return this.page;
  }
  public float getPageCentrePosition(float pageWidth)
  {
    return (getWidth()/2) - (pageWidth/2);
  }

  public void setImageFrame(Rectangle r)
  {
    setImageFrame(r, true);
  }
  public void setImageFrame(Rectangle r, boolean resizeImage)
  {
    this.imageFrame = r;
    if (resizeImage)
      resizeImage(this.imageFrame);
  }
  public Rectangle getImageFrame()
  {
    return this.imageFrame;
  }

  public void setPictureFrame(Rectangle r)
  {  
    this.pictureFrame = r;
  }
  public Rectangle getPictureFrame()
  {
    return this.pictureFrame;
  }
    
  public Integer getWidth()
  {
    return int(this.machineSize.x);
  }
  public Integer getHeight()
  {
    return int(this.machineSize.y);
  }
  
  public void setStepsPerRev(Float s)
  {
    this.stepsPerRev = s;
  }
  public Float getStepsPerRev()
  {
    mmPerStep = null;
    stepsPerMM = null;
    return this.stepsPerRev;
  }
  public void setMMPerRev(Float d)
  {
    mmPerStep = null;
    stepsPerMM = null;
    this.mmPerRev = d;
  }
  public Float getMMPerRev()
  {
    return this.mmPerRev;
  }
  public Float getMMPerStep()
  {
    if (mmPerStep == null)
    {
      mmPerStep = mmPerRev / stepsPerRev;
    }
    return mmPerStep;
  }
  public Float getStepsPerMM()
  {
    if (stepsPerMM == null)
    {
      stepsPerMM = stepsPerRev / mmPerRev;
    }
    return stepsPerMM;
  }
  
  public int inSteps(int inMM) 
  {
    double steps = inMM * getStepsPerMM();
    int stepsInt = (int) steps;
    return stepsInt;
  }
  
  public int inSteps(float inMM) 
  {
    double steps = inMM * getStepsPerMM();
    int stepsInt = (int) steps;
    return stepsInt;
  }
  
  public PVector inSteps(PVector mm)
  {
    PVector steps = new PVector(inSteps(mm.x), inSteps(mm.y));
    return steps;
  }
  
  public int inMM(float steps) 
  {
    double mm = steps / getStepsPerMM();
    int mmInt = (int) mm;
    return mmInt;
  }
  
  public PVector inMM (PVector steps)
  {
    PVector mm = new PVector(inMM(steps.x), inMM(steps.y));
    return mm;
  }
  
  
  int getPixelDensity(PVector o, int dim)
  {
    int averageDensity = 0;
    
    PVector v = PVector.sub(o, getImageFrame().getTopLeft());
    
    if (v.x <= getImage().width && v.x>=0 
    && v.y>=0 && v.y <= getImage().height)
    {
      // get pixels from the vector coords
      int centrePixel = getImage().get((int)v.x, (int)v.y);
      int x = ((int)v.x) - (dim/2);
      int y = ((int)v.y) - (dim/2);
      
      int dimWidth = dim;
      int dimHeight = dim;
      
      if (x+dim > getImage().width)
        dimWidth = getImage().width-x;
        
      if (y+dim > getImage().height)
        dimHeight = getImage().height-y;
        
      PImage block = getImage().get(x, y, dimWidth, dimHeight);
      
      block.loadPixels();
      int numberOfPixels = block.pixels.length;
      float totalPixelDensity = 0;
      for (int i = 0; i < numberOfPixels; i++)
      {
        color p = block.pixels[i];
        float r = red(p);
        totalPixelDensity += r;
  //      println("Pixel " + i + ", color:" + p + ", red: "+r+", totalpixDensity: "+totalPixelDensity);
      }
      
      float avD = totalPixelDensity / numberOfPixels;
      averageDensity = int(avD);
  //    println("No of pixels: "+numberOfPixels+", average density: " + avD + ", int: " + averageDensity);
    }
    // average them
    return averageDensity;
  }
    
  boolean isPixelChromaKey(PVector o)
  {
    
    PVector v = PVector.sub(o, getImageFrame().getTopLeft());
    
    if (v.x < getImage().width && v.y < getImage().height)
    {
      // get pixels from the vector coords
      color centrePixel = getImage().get((int)v.x, (int)v.y);
      float r = red(centrePixel);
      float g = green(centrePixel);
      float b = blue(centrePixel);
      
      if (g > 253.0 
      && r != g 
      && b != g)
      {
  //      println("is chroma key " + red(centrePixel) + ", "+green(centrePixel)+","+blue(centrePixel));
        return true;
      }
      else
      {
  //      println("isn't chroma key " + red(centrePixel) + ", "+green(centrePixel)+","+blue(centrePixel));
        return false;
      }
    }
    else return false;
  }
  
  public PVector asNativeCoords(PVector cartCoords)
  {
    return asNativeCoords(cartCoords.x, cartCoords.y);
  }
  public PVector asNativeCoords(float cartX, float cartY)
  {
    float distA = dist(0,0,cartX, cartY);
    float distB = dist(getWidth(),0,cartX, cartY);
    PVector pgCoords = new PVector(distA, distB);
    return pgCoords;
  }
  
  
  public PVector asCartesianCoords(PVector pgCoords)
  {
    float calcX = int((pow(getWidth(), 2) - pow(pgCoords.y, 2) + pow(pgCoords.x, 2)) / (getWidth()*2));
    float calcY = int(sqrt(pow(pgCoords.x,2)-pow(calcX,2)));
    PVector vect = new PVector(calcX, calcY);
    return vect;
  }
  
  public void loadDefinitionFromProperties(Properties props)
  {
    // get these first because they are important to convert the rest of them
    setStepsPerRev(getFloatProperty("machine.motors.stepsPerRev", 800.0));
    setMMPerRev(getFloatProperty("machine.motors.mmPerRev", 95.0));
    
    // now stepsPerMM and mmPerStep should have been calculated. It's safe to get the rest.
   
    // machine size
    setSize(inSteps(getIntProperty("machine.width", 600)), inSteps(getIntProperty("machine.height", 800)));
    
    // page size
    PVector pageSize = new PVector(getIntProperty("controller.page.width", A3_WIDTH), getIntProperty("controller.page.height", A3_HEIGHT));
    PVector pagePos = new PVector(getIntProperty("controller.page.position.x", (int) getMachine().getPageCentrePosition(pageSize.x)), getIntProperty("controller.page.position.y", 120));
    Rectangle page = new Rectangle(inSteps(pagePos), inSteps(pageSize));
    setPage(page);

    // bitmap
    setImageFilename(getStringProperty("controller.image.filename", "portrait_330.jpg"));
    loadImageFromFilename(imageFilename);
  
    // image position
    Float offsetX = getFloatProperty("controller.image.position.x", 0.0);
    Float offsetY = getFloatProperty("controller.image.position.y", 0.0);
    PVector imagePos = new PVector(offsetX, offsetY);
    Float imageWidth = getFloatProperty("controller.image.width", 300);
    PVector imageSize = new PVector(imageWidth, imageWidth);
    Rectangle imageFrame = new Rectangle(inSteps(imagePos), inSteps(imageSize));
    setImageFrame(imageFrame); // this automatically resizes the image if nec

    // picture frame size
    PVector frameSize = new PVector(getIntProperty("controller.pictureframe.width", 200), getIntProperty("controller.pictureframe.height", 200));
    PVector framePos = new PVector(getIntProperty("controller.pictureframe.position.x", 200), getIntProperty("controller.pictureframe.position.y", 200));
    Rectangle frame = new Rectangle(inSteps(framePos), inSteps(frameSize));
    setPictureFrame(frame);
  }
  public Properties loadDefinitionIntoProperties(Properties props)
  {
    // Put keys into properties file:
    props.setProperty("machine.motors.stepsPerRev", getMachine().getStepsPerRev().toString());
    props.setProperty("machine.motors.mmPerRev", getMachine().getMMPerRev().toString());

    // machine width
    props.setProperty("machine.width", Integer.toString((int) inMM(getMachine().getWidth())));
    // machine.height
    props.setProperty("machine.height", Integer.toString((int) inMM(getMachine().getHeight())));

    // image filename
    props.setProperty("controller.image.filename", (getImageFilename() == null) ? "" : getImageFilename());
    
    // image position
    props.setProperty("controller.image.position.x", Integer.toString((int) inMM(getMachine().getImageFrame().getLeft())));
    props.setProperty("controller.image.position.y", Integer.toString((int) inMM(getMachine().getImageFrame().getTop())));
    // image size
    props.setProperty("controller.image.width", Integer.toString((int) inMM(getMachine().getImageFrame().getWidth())));
  
    // page size
    props.setProperty("controller.page.width", Integer.toString((int) inMM(getMachine().getPage().getWidth())));
    props.setProperty("controller.page.height", Integer.toString((int) inMM(getMachine().getPage().getHeight())));
    
    // page position
    props.setProperty("controller.page.position.x", Integer.toString((int) inMM(getMachine().getPage().getLeft())));
    props.setProperty("controller.page.position.y", Integer.toString((int) inMM(getMachine().getPage().getTop())));
  
    // picture frame size
    props.setProperty("controller.pictureframe.width", Integer.toString((int) inMM(getMachine().getPictureFrame().getWidth())));
    props.setProperty("controller.pictureframe.height", Integer.toString((int) inMM(getMachine().getPictureFrame().getHeight())));
    
    // picture frame position
    props.setProperty("controller.pictureframe.position.x", Integer.toString((int) inMM(getMachine().getPictureFrame().getLeft())));
    props.setProperty("controller.pictureframe.position.y", Integer.toString((int) inMM(getMachine().getPictureFrame().getTop())));
    
    return props;
  }

  void loadImageFromFilename(String filename)
  {
    // check for format etc here
    println("loading from filename: " + filename);
    this.imageBitmap = loadImage(filename);
    this.imageFilename = filename;
  }
  
  public void setImage(PImage b)
  {
    this.imageBitmap = b;
  }
  public void setImageFilename(String filename)
  {
    this.loadImageFromFilename(filename);
  }
  public String getImageFilename()
  {
    return this.imageFilename;
  }
  public PImage getImage()
  {
    return this.imageBitmap;
  }
  
  public boolean imageIsLoaded()
  {
    if (getImage() != null)
      return true;
    else
      return false;
  }


  private void resizeImage(Rectangle r)
  {
    println("image:" + getImage());
    if (imageIsLoaded())
    {
      getImage().resize(width, 0);
    }
    else
    {
      println("No image file loaded to resize.");
    }    
  }
  
  protected void setGridSize(float gridSize)
  {
    this.gridSize = gridSize;
    this.gridLinePositions = generateGridLinePositions(gridSize);
  }
  
  /**
    This takes in an area defined in cartesian steps,
    and returns a set of pixels that are included
    in that area.  Coordinates are specified 
    in cartesian steps.  The pixels are worked out 
    based on the gridsize parameter. d*/
  Set<PVector> getPixelsPositionsFromArea(PVector p, PVector s, float gridSize)
  {
    // work out the grid
    setGridSize(gridSize);
    float maxLength = getMaxLength();
    float numberOfGridlines = maxLength / gridSize;
    float gridIncrement = getMaxLength() / numberOfGridlines;
    
    List<Float> gridLinePositions = getGridLinePositions(gridSize);
    Rectangle selectedArea = new Rectangle (p.x,p.y, s.x,s.y);
    
    // now go through all the combinations of the two values.
    Set<PVector> nativeCoords = new HashSet<PVector>();
    for (Float a : gridLinePositions)
    {
      for (Float b : gridLinePositions)
      {
        PVector nativeCoord = new PVector(a, b);
        PVector cartesianCoord = asCartesianCoords(nativeCoord);
        if (selectedArea.surrounds(cartesianCoord))
           nativeCoords.add(nativeCoord);
      }
    }
    
    return nativeCoords;
  }
  
  protected PVector snapToGrid(PVector loose, float gridSize)
  {
    List<Float> pos = getGridLinePositions(gridSize);
    boolean higherupperFound = false;
    boolean lowerFound = false;
    
    float halfGrid = gridSize / 2.0;
    float x = loose.x;
    float y = loose.y;
    
    Float snappedX = null;
    Float snappedY = null;
    
    int i = 0;
    while ((snappedX == null || snappedY == null) && i < pos.size())
    {
      float upperBound = pos.get(i)+halfGrid;
      float lowerBound = pos.get(i)-halfGrid;
//      println("pos:" +pos.get(i) + "half: "+halfGrid+ ", upper: "+ upperBound + ", lower: " + lowerBound);
      if (snappedX == null 
        && x > lowerBound 
        && x <= upperBound)
      {
        snappedX = pos.get(i);
//        println("snappedX:" + snappedX);
      }

      if (snappedY == null 
        && y > lowerBound 
        && y <= upperBound)
      {
        snappedY = pos.get(i);
//        println("snappedY:" + snappedY);
      }
            
      i++;
    }
    
    PVector snapped = new PVector((snappedX == null) ? 0.0 : snappedX, (snappedY == null) ? 0.0 : snappedY);
//    println("loose:" + loose);
//    println("snapped:" + snapped);
    return snapped;
  }
  
  protected List<Float> getGridLinePositions(float gridSize)
  {
    setGridSize(gridSize);
    return this.gridLinePositions;
  }
  
  private List<Float> generateGridLinePositions(float gridSize)
  {
    List<Float> glp = new ArrayList<Float>();
    float maxLength = getMaxLength();
    for (float i = gridSize; i <= maxLength; i+=gridSize)
    {
      glp.add(i);
    }
    return glp;
  }    

 

}
