class Panel
{
  private Rectangle outline = null;
  private String name = null;
  private List<Integer> buttons = null;
  private List<PVector> buttonPositions = null;

  public Panel(String name, Rectangle outline, List<Integer> buttons, List<PVector> buttonPositions)
  {
    this.name = name;
    this.outline = outline;
    this.buttons = buttons;
    this.buttonPositions = buttonPositions;
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
  
  public List<Integer> getButtons()
  {
    return this.buttons;
  }
  public void setButtons(List<Integer> b)
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
  
  
}
