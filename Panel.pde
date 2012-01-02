class Panel
{
  private Rectangle outline = null;
  private String name = null;
  private List<Button> buttons = null;
  private List<PVector> buttonPositions = null;

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
  
  public List<Button> getButtons()
  {
    return this.buttons;
  }
  public void setButtons(List<Button> b)
  {
    this.buttons = b;
  }
  
  public List<PVector> getButtonPositions()
  {
    return this.buttonPositions;
  }
  public void setButtonPositions(List<PVector> bp)
  {
    this.buttonPositions = bp;
  }
  
  public void draw()
  {
    stroke(200,200,200,255);
    strokeWeight(2);
    rect(getOutline().getLeft(), getOutline().getTop(), getOutline().getWidth(), getOutline().getHeight());
    
  }
  
  
}
