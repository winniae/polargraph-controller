/**
  Polargraph controller
  Copyright Sandy Noble 2012.

  This file is part of Polargraph Controller.

  Polargraph Controller is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Polargraph Controller is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Polargraph Controller.  If not, see <http://www.gnu.org/licenses/>.
    
  Requires the excellent ControlP5 GUI library available from http://www.sojamo.de/libraries/controlP5/.
  
  This is an application for controlling a polargraph machine, communicating using ASCII command language over a serial link.

  sandy.noble@gmail.com
  http://www.polargraph.co.uk/
  http://code.google.com/p/polargraph/
*/

class DisplayMachine extends Machine
{
  private Rectangle outline = null;
  private float scaling = 1.0;
  private Scaler scaler = null;
  private PVector offset = null;

  private Set<PVector> extractedPixels = new HashSet<PVector>(0);

  PImage scaledImage = null;

  public DisplayMachine(Machine m, PVector offset, float scaling)
  {
    // construct
    super(m.getWidth(), m.getHeight(), m.getMMPerRev(), m.getStepsPerRev());

    super.machineSize = m.machineSize;

    super.page = m.page;
    super.imageFrame = m.imageFrame;
    super.pictureFrame = m.pictureFrame;

    super.imageBitmap = m.imageBitmap;
    super.imageFilename = m.imageFilename;

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
  public final int DROP_SHADOW_DISTANCE = 4;
  public void draw()
  {
    // work out the scaling factor.
    noStroke();
    // draw machine outline

    fill(80);
    rect(getOutline().getLeft()+DROP_SHADOW_DISTANCE, getOutline().getTop()+DROP_SHADOW_DISTANCE, getOutline().getWidth(), getOutline().getHeight());

    fill(150);
    rect(getOutline().getLeft(), getOutline().getTop(), getOutline().getWidth(), getOutline().getHeight());
    text("machine", getOutline().getLeft(), getOutline().getTop());

    // draw some guides
    stroke(255, 255, 255, 128);
    strokeWeight(1);
    line(getOutline().getLeft()+(getOutline().getWidth()/2), getOutline().getTop(), 
    getOutline().getLeft()+(getOutline().getWidth()/2), getOutline().getBottom());

    line(getOutline().getLeft(), getOutline().getTop()+sc(getPage().getTop()), 
    getOutline().getRight(), getOutline().getTop()+sc(getPage().getTop()));
    // draw page
    fill(220);
    rect(getOutline().getLeft()+sc(getPage().getLeft()), 
    getOutline().getTop()+sc(getPage().getTop()), 
    sc(getPage().getWidth()), 
    sc(getPage().getHeight()));
    text("page", getOutline().getLeft()+sc(getPage().getLeft()), 
    getOutline().getTop()+sc(getPage().getTop()));
    noFill();



    // draw actual image
    if (displayingImage && imageIsLoaded())
    {
      float ox = getOutline().getLeft()+sc(getImageFrame().getLeft());
      float oy = getOutline().getTop()+sc(getImageFrame().getTop());
      float w = sc(getImageFrame().getWidth());
      float h = sc(getImageFrame().getHeight());
      image(getImage(), ox, oy, w, h);
      strokeWeight(1);
      stroke(150, 150, 150, 40);
      rect(ox, oy, w-1, h-1);
      fill(150, 150, 150, 40);
      text("image", ox, oy);
      noFill();
    }

    drawPictureFrame();


    if (displayingSelectedCentres)
    {
      drawExtractedPixelCentres();
    }
    if (displayingDensityPreview)
    {
      drawExtractedPixelDensities();
    }

    if (getOutline().surrounds(getMouseVector()))
    {  
      drawHangingStrings();
      drawRows();
      cursor(CROSS);
    }
    else
    {
      cursor(ARROW);
    }

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
    PVector mach = new PVector(x, y);
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
    float a = dist(0, 0, cart.x, cart.y);
    float b = dist(width, 0, cart.x, cart.y);

    // and out
    PVector nativeMM = new PVector(a, b);
    return nativeMM;
  }

  void drawPictureFrame()
  {
    strokeWeight(1);

    PVector topLeft = scaleToScreen(inMM(getPictureFrame().getTopLeft()));
    PVector botRight = scaleToScreen(inMM(getPictureFrame().getBotRight()));

    stroke (255, 0, 0);

    // top left    
    line(topLeft.x-4, topLeft.y, topLeft.x-10, topLeft.y);
    line(topLeft.x, topLeft.y-4, topLeft.x, topLeft.y-10);

    // top right
    line(botRight.x+4, topLeft.y, botRight.x+10, topLeft.y);
    line(botRight.x, topLeft.y-4, botRight.x, topLeft.y-10);

    // bot right
    line(botRight.x+4, botRight.y, botRight.x+10, botRight.y);
    line(botRight.x, botRight.y+4, botRight.x, botRight.y+10);
    
    // bot left
    line(topLeft.x-4, botRight.y, topLeft.x-10, botRight.y);
    line(topLeft.x, botRight.y+4, topLeft.x, botRight.y+10);

    stroke(255);
    

//    float width = inMM(getPictureFrame().getBotRight().x - getPictureFrame().getTopLeft().x);
//    println("width: "+ width);
  }


  public void drawHangingStrings()
  {
    // hanging strings
    strokeWeight(4);
    stroke(255, 255, 255, 64);
    line(getOutline().getLeft(), getOutline().getTop(), mouseX, mouseY);
    line(getOutline().getRight(), getOutline().getTop(), mouseX, mouseY);
  }

  /**  This draws on screen, showing an arc highlighting the row that the mouse
   is on.
   */
  public void drawRows()
  {
    PVector mVect = getMouseVector();

    // scale it to  find out the coordinates on the machine that the mouse is pointing at.
    mVect = scaleToDisplayMachine(mVect);
    // convert it to the native coordinates system
    mVect = convertToNative(mVect);
    // snap it to the grid
    mVect = snapToGrid(mVect, getGridSize());
    // scale it back to find out how to represent this on-screen
    mVect = scaleToScreen(mVect);

    // and finally, because scaleToScreen also allows for the machine position (offset), subtract it.
    mVect.sub(getOffset());


    float rowThickness = inMM(getGridSize()) * getScaling();
    rowThickness = (rowThickness < 1.0) ? 1.0 : rowThickness;
    strokeWeight(rowThickness);
    stroke(200, 200, 255, 128);
    strokeCap(SQUARE);

    float dia = mVect.x*2;
    arc(getOutline().getLeft(), getOutline().getTop(), dia, dia, 0, 1.57079633);

    dia = mVect.y*2;
    arc(getOutline().getRight(), getOutline().getTop(), dia, dia, 1.57079633, 3.14159266);
  }

  void drawExtractedPixelCentres()
  {
    for (PVector cartesianPos : getExtractedPixels())
    {
      // scale em, danno.
      PVector scaledPos = scaleToScreen(cartesianPos);
      strokeWeight(1);
      stroke(255, 0, 0, 128);
      noFill();
      line(scaledPos.x-1, scaledPos.y-1, scaledPos.x+1, scaledPos.y+1);
      line(scaledPos.x-1, scaledPos.y+1, scaledPos.x+1, scaledPos.y-1);
    }
  }
  
  void drawExtractedPixelDensities()
  {

    float pixelSize = inMM(getGridSize()) * getScaling();
    pixelSize = (pixelSize < 1.0) ? 1.0 : pixelSize;
    
    pixelSize = pixelSize * 1.1;

    for (PVector cartesianPos : getExtractedPixels())
    {
      // scale em, danno.
      PVector scaledPos = scaleToScreen(cartesianPos);
      noStroke();
      fill(cartesianPos.z);
      ellipse(scaledPos.x, scaledPos.y, pixelSize, pixelSize);
    }
    noFill();
  }

  Set<PVector> getExtractedPixels()
  {
    return this.extractedPixels;
  }
  void setExtractedPixels(Set<PVector> p)
  {
    this.extractedPixels = p;
  }

  /* This will return a list of pixels that are included in the area in the 
   parameter.  All coordinates are for the screen.
   */
  Set<PVector> getPixelsPositionsFromArea(PVector p, PVector s, float rowSize)
  {
    extractPixelsFromArea(p, s, rowSize, 0.0);
    return getExtractedPixels();
  }

//  public void extractPixelsFromArea(PVector p, PVector s, Float rowSize)
//  {
//    extractPixelsFromArea(p, s, rowSize, 0.0);
//  }

  public void extractPixelsFromArea(PVector p, PVector s, float rowSize, float sampleSize)
  {
    // get the native positions from the superclass
    Set<PVector> nativePositions = super.getPixelsPositionsFromArea(inSteps(p), inSteps(s), rowSize, sampleSize);

    // work out the cartesian positions
    Set<PVector> cartesianPositions = new HashSet<PVector>(nativePositions.size());
    for (PVector nativePos : nativePositions)
    {
      // convert to cartesian
      PVector displayPos = super.asCartesianCoords(nativePos);
      displayPos = inMM(displayPos);
      displayPos.z = nativePos.z;
      cartesianPositions.add(displayPos);
    }
    setExtractedPixels(cartesianPositions);
  }

  protected PVector snapToGrid(PVector loose, float rowSize)
  {
    PVector snapped = inSteps(loose);
    snapped = super.snapToGrid(snapped, rowSize);
    snapped = inMM(snapped);
    return snapped;
  }
}

