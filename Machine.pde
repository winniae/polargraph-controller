
/**
*
*
*
*/
class Machine
{
  public PVector machineSize = null;

  public Rectangle page = null;
  public Rectangle imageFrame = null;
  public Rectangle pictureFrame = null;

  public Float stepsPerRev = 800.0;
  public Float mmPerRev = 95.0;
  
  public Float mmPerStep = null;
  public Float stepsPerMM = null;
  
  
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
      
  
}
