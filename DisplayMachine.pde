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


  
  // this scales a value from the screen to be a position on the machine
  /**  Given a point on-screen, this works out where on the 
       actual machine it refers to.
  */
  public PVector scaleToDisplayMachine(PVector screen)
  {
    // offset
    float x = screen.x - getOffset().x;
    float y = screen.y - getOffset().y;

    // transform
    float scalingFactor = 1.0/getScaling();
    x = scalingFactor * x;
    y = scalingFactor * y;
    
    // and out
    PVector mach = new PVector(x,y);
    return mach;
  }
  
  /** This works out the position, on-screen of a specific point on the machine.
       Both values are cartesian coordinates.
  */
  public PVector scaleToScreen(PVector mach)
  {
    // transform
    float x = mach.x * scaling;
    float y = mach.y * scaling;

    // offset
    x = x + getOffset().x;
    y = y + getOffset().y;

    // and out!
    PVector screen = new PVector(x, y);
    return screen;
  }
  
  // converts a cartesian coord into a native one
  public PVector convertToNative(PVector cart)
  {
    // width of machine in mm
    float width = inMM(super.getWidth());
    
    // work out distances
    float a = dist(0,0,cart.x,cart.y);
    float b = dist(width,0,cart.x,cart.y);
    
    // and out
    PVector nativeMM = new PVector(a, b);
    return nativeMM;
  }

  /**  This draws on screen, showing an arc highlighting the row that the mouse
  is on.
  */
  void showRows()
  {
    PVector mVect = getMouseVector();
    
    // scale it to  find out the coordinates on the machine that the mouse is pointing at.
    mVect = scaleToDisplayMachine(mVect);
    // convert it to the native coordinates system
    mVect = convertToNative(mVect);
    // scale it back to find out how to represent this on-screen
    mVect = scaleToScreen(mVect);
    
    // and finally, because scaleToScreen also allows for the machine position (offset), subtract it.
    mVect.sub(getOffset());
    
    float dia = mVect.x*2;
    arc(getLeft(), getTop(), dia, dia, 0, 1.57079633);
    
    dia = mVect.y*2;
    arc(getRight(), getTop(), dia, dia, 1.57079633, 3.14159266);
  }
  
    
  
}
