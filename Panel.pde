class Panel
{
  private Rectangle outline = null;
  private String name = null;
  private List<Controller> controls = null;
  private Map<String, PVector> controlPositions = null;
  private Map<String, PVector> controlSizes = null;
  private boolean resizable = true;
  private float minimumHeight = DEFAULT_CONTROL_SIZE.y+4;
  private color outlineColour = color(255);

  public Panel(String name, Rectangle outline)
  {
    this.name = name;
    this.outline = outline;
  }
  
  public Rectangle getOutline()
  {
    return this.outline;
  }
  public void setOutline(Rectangle r)
  {
    this.outline = r;
  }
  
  public String getName()
  {
    return this.name;
  }
  public void setName(String name)
  {
    this.name = name;
  }
  
  public List<Controller> getControls()
  {
    if (this.controls == null)
      this.controls = new ArrayList<Controller>(0);
    return this.controls;
  }
  public void setControls(List<Controller> c)
  {
    this.controls = c;
  }
  
  public Map<String, PVector> getControlPositions()
  {
    return this.controlPositions;
  }
  public void setControlPositions(Map<String, PVector> cp)
  {
    this.controlPositions = cp;
  }
  
  public Map<String, PVector> getControlSizes()
  {
    return this.controlSizes;
  }
  public void setControlSizes(Map<String, PVector> cs)
  {
    this.controlSizes = cs;
  }
  
  void setOutlineColour(color c)
  {
    this.outlineColour = c;
  }
  
  void setResizable(boolean r)
  {
    this.resizable = r;
  }
  boolean isResizable()
  {
    return this.resizable;
  }
  
  void setMinimumHeight(float h)
  {
    this.minimumHeight = h;
  }
  float getMinimumHeight()
  {
    return this.minimumHeight;
  }
  
  public void draw()
  {
//    stroke(outlineColour);
//    strokeWeight(2);
//    rect(getOutline().getLeft(), getOutline().getTop(), getOutline().getWidth(), getOutline().getHeight());

    drawControls();
  }
  
  public void drawControls()
  {
    for (Controller c : this.getControls())
    {
      PVector pos = getControlPositions().get(c.name());
      float x = pos.x+getOutline().getLeft();
      float y = pos.y+getOutline().getTop();
      c.setPosition(x, y);
      c.setSize((int)DEFAULT_CONTROL_SIZE.x, (int)DEFAULT_CONTROL_SIZE.y);
    }
  }
  
  void setHeight(float h)
  {
    if (this.isResizable())
    {
      if (h <= getMinimumHeight())
        this.getOutline().setHeight(getMinimumHeight());
      else
        this.getOutline().setHeight(h);
      setControlPositions(buildControlPositionsForPanel(this));
      
      float left = 0.0;
      String controlName = "";
      for (String key : getControlPositions().keySet())
      {
        PVector pos = getControlPositions().get(key);
        if (pos.x >= left)
        {
          left = pos.x;
          controlName = key;
        }
      }
      
      Map<String, PVector> map = getControlSizes();
      
//      PVector size = getControlSizes().get(controlName);
//      println("size: " + size);
      float right = left + DEFAULT_CONTROL_SIZE.x;
      
      this.getOutline().setWidth(right);
    }
  }
  
  
}
