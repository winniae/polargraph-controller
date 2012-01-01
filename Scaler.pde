class Scaler
{
  public float scale = 1.0;
  public float mmPerStep = 1.0;
  
  public Scaler(float scale, float mmPerStep)
  {
    this.scale = scale;
    this.mmPerStep = mmPerStep;
  }
  public void setScale(float scale)
  {
    this.scale = scale;
  }
  
  public float scale(float in)
  {
    return in * mmPerStep * scale;
  }
}
