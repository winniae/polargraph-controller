
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
    this.imageFrame = r;
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
  
  private int inSteps(int inMM) 
  {
    double steps = inMM * getStepsPerMM();
    int stepsInt = (int) steps;
    return stepsInt;
  }
  
  private int inSteps(float inMM) 
  {
    double steps = inMM * getStepsPerMM();
    int stepsInt = (int) steps;
    return stepsInt;
  }
  
  private PVector inSteps(PVector mm)
  {
    mm.x = inSteps(mm.x);
    mm.y = inSteps(mm.y);
    return mm;
  }
  
  public int inMM(float steps) 
  {
    double mm = steps / getStepsPerMM();
    int mmInt = (int) mm;
    return mmInt;
  }
  
  
  int getPixelDensity(PVector o, int dim)
  {
    int averageDensity = 0;
    
    PVector v = PVector.sub(o, getImageFrame().getTopLeft());
    
    if (v.x <= bitmap.width && v.x>=0 
    && v.y>=0 && v.y <= bitmap.height)
    {
      // get pixels from the vector coords
      int centrePixel = bitmap.get((int)v.x, (int)v.y);
      int x = ((int)v.x) - (dim/2);
      int y = ((int)v.y) - (dim/2);
      
      int dimWidth = dim;
      int dimHeight = dim;
      
      if (x+dim > bitmap.width)
        dimWidth = bitmap.width-x;
        
      if (y+dim > bitmap.height)
        dimHeight = bitmap.height-y;
        
      PImage block = bitmap.get(x, y, dimWidth, dimHeight);
      
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
    
    if (v.x < bitmap.width && v.y < bitmap.height)
    {
      // get pixels from the vector coords
      color centrePixel = bitmap.get((int)v.x, (int)v.y);
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
    PVector pgCoords = new PVector(inSteps(distA), inSteps(distB));
    return pgCoords;
  }
  public PVector asCartesian(PVector pgCoords)
  {
    float calcX = int((pow(getWidth(), 2) - pow(pgCoords.y, 2) + pow(pgCoords.x, 2)) / (getWidth()*2));
    float calcY = int(sqrt(pow(pgCoords.x,2)-pow(calcX,2)));
    PVector vect = new PVector(inMM(calcX), inMM(calcY));
    return vect;
  }
  
  public void loadDefinitionFromProperties(Properties props)
  {
    // get these first because they are important to convert the rest of them
    getMachine().setStepsPerRev(getFloatProperty("machine.motors.stepsPerRev", 800.0));
    getMachine().setMMPerRev(getFloatProperty("machine.motors.mmPerRev", 95.0));
    
    // now stepsPerMM and mmPerStep should have been calculated. It's safe to get the rest.
   
    // machine size
    getMachine().setSize(inSteps(getIntProperty("machine.width", 600)), inSteps(getIntProperty("machine.height", 800)));
    
    // page size
    PVector pageSize = new PVector(getIntProperty("controller.page.width", A3_WIDTH), getIntProperty("controller.page.height", A3_HEIGHT));
    PVector pagePos = new PVector(getIntProperty("controller.page.position.x", (int) getMachine().getPageCentrePosition(pageSize.x)), getIntProperty("controller.page.position.y", 120));
    Rectangle page = new Rectangle(inSteps(pagePos), inSteps(pageSize));
    getMachine().setPage(page);
  
    // image position
    Float offsetX = getFloatProperty("controller.image.position.x", 0.0);
    Float offsetY = getFloatProperty("controller.image.position.y", 0.0);
    PVector imagePos = new PVector(offsetX, offsetY);
    Float imageWidth = getFloatProperty("controller.image.width", 300);
    PVector imageSize = new PVector(imageWidth, imageWidth);
    Rectangle imageFrame = new Rectangle(inSteps(imagePos), inSteps(imageSize));
    getMachine().setImageFrame(imageFrame);
  
    // picture frame size
    PVector frameSize = new PVector(getIntProperty("controller.pictureframe.width", 200), getIntProperty("controller.pictureframe.height", 200));
    PVector framePos = new PVector(getIntProperty("controller.pictureframe.position.x", 200), getIntProperty("controller.pictureframe.position.y", 200));
    Rectangle frame = new Rectangle(inSteps(framePos), inSteps(frameSize));
    getMachine().setPictureFrame(frame);
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
  
  private Scaler getScaler()
  {
    return scaler;
  }
  
  public void setScale(float scale)
  {
    this.scaler = new Scaler(scale, getMMPerStep());
  }
  public float sc(float val)
  {
    return getScaler().scale(val);
  }
  public void setDisplayPosition(PVector offset)
  {
    this.displayPosition = offset;
  }
  public PVector
  
  public void draw(PVector pos)
  {
    // work out the scaling factor.
    
    // draw machine outline
    rect(pos.x, pos.y, sc(getWidth()), sc(getHeight()));
    
    // draw page
    rect(pos.x+sc(getPage().getLeft()), 
      pos.y+sc(getPage().getTop()), 
      sc(getPage().getWidth()), 
      sc(getPage().getHeight()));

    // draw image
    rect(pos.x+sc(getImageFrame().getLeft()), 
      pos.y+sc(getImageFrame().getTop()), 
      sc(getImageFrame().getWidth()), 
      sc(getImageFrame().getHeight()));

    showARow(pos);
    showBRow(pos);

    line(pos.x, pos.y, mouseX, mouseY);
    line(pos.x+sc(getWidth()), pos.y, mouseX, mouseY);
  }
  
  
  
  void showARow(PVector pos)
  {
    int roundedLength = getMachine().inMM(rounded(getALength()));
    int dia = roundedLength*2;
    int rowMM = inMM(rowWidth);
    ellipse(pos.x, pos.y, dia, dia);
  }
  void showBRow(PVector pos)
  {
    int roundedLength = getMachine().inMM(rounded(getBLength()));
    int dia = roundedLength*2;
    ellipse(pos.x+sc(getWidth()), pos.y, dia, dia);
  }
  
  public PVector getALength(PVector coord)
  {
    
  }
  
}
