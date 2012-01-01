class DisplayMachine extends Machine
{
  private Rectangle outline = null;
  private float scaling = 1.0;
  private Scaler scaler = null;
  private PVector offset = null;
  
  public DisplayMachine(Machine m, PVector offset, float scaling)
  {
    // construct
    super(m.getWidth(), m.getHeight(), m.getMMPerRev(), m.getStepsPerRev());
    
    super.machineSize = m.machineSize;
    
    super.page = m.page;
    super.imageFrame = m.imageFrame;
    super.pictureFrame = m.pictureFrame;
    
    super.stepsPerRev = m.stepsPerRev;
    super.mmPerRev = m.mmPerRev;
      
    super.mmPerStep = m.mmPerStep;
    super.stepsPerMM = m.stepsPerMM;
    super.maxLength = m.maxLength;
    super.gridSize = m.gridSize;
    
    this.offset = offset;
    this.scaling = scaling;
    this.scaler = new Scaler(scaling, 100.0);
    
    this.outline = null;
  }
  
  public Rectangle getOutline()
  {
    outline = new Rectangle(offset, new PVector(sc(super.getWidth()), sc(super.getHeight())));
    return this.outline;
  }
  
  
  private Scaler getScaler()
  {
    if (scaler == null)
      this.scaler = new Scaler(getScaling(), getMMPerStep());
    return scaler;
  }
  
  public void setScale(float scale)
  {
    this.scaling = scale;
    this.scaler = new Scaler(scale, getMMPerStep());
  }
  public float getScaling()
  {
    return this.scaling;
  }
  public float sc(float val)
  {
    return getScaler().scale(val);
  }
  public void setOffset(PVector offset)
  {
    this.offset = offset;
  }
  public PVector getOffset()
  {
    return this.offset;
  }
  public Integer getLeft()
  {
    return int(getOutline().getLeft());
  }
  public Integer getTop()
  {
    return int(getOffset().y);
  }
  public Integer getRight()
  {
    return int(getOffset().x+sc(super.getWidth()));
  }
  public Integer getBottom()
  {
    return int(getOffset().y+sc(super.getHeight()));
  }
  public Integer getWidth()
  {
    return int(sc(super.getWidth()));
  }
  public Integer getHeight()
  {
    return int(sc(super.getHeight()));
  }
  public void draw()
  {
    // work out the scaling factor.
    
    // draw machine outline
    rect(getLeft(), getTop(), getWidth(), getHeight());
    
    // draw page
    rect(getLeft()+sc(getPage().getLeft()), 
      getTop()+sc(getPage().getTop()), 
      sc(getPage().getWidth()), 
      sc(getPage().getHeight()));

    // draw image
    rect(getLeft()+sc(getImageFrame().getLeft()), 
      getTop()+sc(getImageFrame().getTop()), 
      sc(getImageFrame().getWidth()), 
      sc(getImageFrame().getHeight()));

    // hanging strings
    line(getLeft(), getTop(), mouseX, mouseY);
    line(getRight(), getTop(), mouseX, mouseY);

    showRows();

  }
  
  public PVector scaleToScreen(float x, float y)
  {
    PVector coords = new PVector(scaleToScreen(x), scaleToScreen(y));
    return coords;
  }
  public PVector scaleToScreen(PVector p)
  {
    PVector coords = new PVector(scaleToScreen(p.x), scaleToScreen(p.y));
    return coords;  
  }
  public float scaleToScreen(float c)
  {
    float scalingFactor = 1.0/getScaling();
    float scaled = scalingFactor * c;
    return scaled;
    
  }    
  
  // converts a cartesian screen coordinate into a machine coordinate in steps
  public PVector asNativeCoords(float x, float y)
  {
    // first scale the coordinates to the current scaling setting of the machine
    PVector scaled = scaleToScreen(x, y);
    // then get the native equivalents
    PVector pos = super.asNativeCoords(scaled.x, scaled.y);
    return pos;
  }
  
  // converts a cartesian screen coordinate into a machine coordinates in steps
  public PVector asNativeCoords(PVector mm)
  {
    PVector p = asNativeCoordsMM(mm);
    p.x = inSteps(p.x);
    p.y = inSteps(p.y);
    return p;
  }
  
  // converts a cartesian screen coordinate into a machine coordinate in mm
  public PVector asNativeCoordsMM(PVector mm)
  {
    // offset machine position
    PVector p = PVector.sub(mm, getOffset());
    // scale with machine scaling
    p = asScaledCoords(p.x, p.y);
    
    ellipse(getOffset().x+p.x, getOffset().y+p.y, 5, 5);
    
    // now convert to 
    PVector pos = super.asNativeCoords(p.x, p.y);
    return pos;
  }
  
  // converts cartesian screen coordinate into a cartesian machine coordinate in mm
  public PVector asCartesianCoords(PVector c)
  {
    PVector p = PVector.sub(c, getOffset());
    p = asScaledCoords(p.x, p.y);
    return p;
  }

  
  void showRows()
  {
    PVector mVect = getMouseVector();
    mVect = this.asNativeCoordsMM(mVect);
    println("mVect: " + mVect);
    
    mVect.x = mVect.x * scaling;
    mVect.y = mVect.y * scaling;
    
    println("mvect sc: " + mVect);
    
    int roundedLength = rounded(mVect.x);
    int dia = roundedLength*2;
    ellipse(getLeft(), getTop(), dia, dia);
    
    roundedLength = rounded(mVect.y);
    dia = roundedLength*2;
    ellipse(getRight(), getTop(), dia, dia);
  }
  
    
  
}
