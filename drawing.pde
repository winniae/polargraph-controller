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
static final String CMD_CHANGELENGTH = "C01,";
static final String CMD_CHANGEPENWIDTH = "C02,";
static final String CMD_CHANGEMOTORSPEED = "C03,";
static final String CMD_CHANGEMOTORACCEL = "C04,";
static final String CMD_DRAWPIXEL = "C05,";
static final String CMD_DRAWSCRIBBLEPIXEL = "C06,";
static final String CMD_DRAWRECT = "C07,";
static final String CMD_CHANGEDRAWINGDIRECTION = "C08,";
static final String CMD_SETPOSITION = "C09,";
static final String CMD_TESTPATTERN = "C10,";
static final String CMD_TESTPENWIDTHSQUARE = "C11,";
static final String CMD_TESTPENWIDTHSCRIBBLE = "C12,";
static final String CMD_PENDOWN = "C13,";
static final String CMD_PENUP = "C14,";
static final String CMD_DRAWSAWPIXEL = "C15,";
static final String CMD_DRAWROUNDPIXEL = "C16,";
static final String CMD_CHANGELENGTHDIRECT = "C17,";
static final String CMD_TXIMAGEBLOCK = "C18,";
static final String CMD_STARTROVE = "C19,";
static final String CMD_STOPROVE = "C20,";
static final String CMD_SETROVEAREA = "C21,";
static final String CMD_LOADMAGEFILE = "C23,";
static final String CMD_CHANGEMACHINESIZE = "C24,";
static final String CMD_CHANGEMACHINENAME = "C25,";
static final String CMD_REQUESTMACHINESIZE = "C26,";
static final String CMD_RESETMACHINE = "C27,";
static final String CMD_DRAWDIRECTIONTEST = "C28,";
static final String CMD_CHANGEMACHINEMMPERREV = "C29,";
static final String CMD_CHANGEMACHINESTEPSPERREV = "C30,";
static final String CMD_SETMOTORSPEED = "C31,";
static final String CMD_SETMOTORACCEL = "C32,";

private PVector mouseVector = new PVector(0,0);

Comparator xAscending = new Comparator() 
{
  public int compare(Object p1, Object p2)
  {
    PVector a = (PVector) p1;
    PVector b = (PVector) p2;
    
    int xValue = new Float(a.x).compareTo(b.x);
    return xValue;
  }
};

Comparator yAscending = new Comparator() 
{
  public int compare(Object p1, Object p2)
  {
    PVector a = (PVector) p1;
    PVector b = (PVector) p2;
    
    int yValue = new Float(a.y).compareTo(b.y);
    return yValue;
  }
};

void sendResetMachine()
{
  String command = CMD_RESETMACHINE + "END";
  commandQueue.add(command);
}
void sendRequestMachineSize()
{
  String command = CMD_REQUESTMACHINESIZE + "END";
  commandQueue.add(command);
}
void sendMachineSpec()
{
  // ask for input to get the new machine size
  String command = CMD_CHANGEMACHINENAME+newMachineName+",END";
  commandQueue.add(command);
  command = CMD_CHANGEMACHINESIZE+getDisplayMachine().getWidth()+","+getDisplayMachine().getHeight()+",END";
  commandQueue.add(command);
  command = CMD_CHANGEMACHINEMMPERREV+getDisplayMachine().getMMPerRev()+",END";
  commandQueue.add(command);
  command = CMD_CHANGEMACHINESTEPSPERREV+getDisplayMachine().getStepsPerRev()+",END";
  commandQueue.add(command);
}

public PVector getMouseVector()
{
  if (mouseVector == null)
  {
    mouseVector = new PVector(0,0);
  }
  
  mouseVector.x = mouseX;
  mouseVector.y = mouseY;
  return mouseVector;
}
void sendMoveToPosition(boolean direct)
{
  String command = null;
  PVector p = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
  p = getDisplayMachine().inSteps(p);
  p = getDisplayMachine().asNativeCoords(p);
  if (direct)
  {
    command = CMD_CHANGELENGTHDIRECT+p.x+","+p.y+","+getMaxSegmentLength()+",END";
  }
  else
    command = CMD_CHANGELENGTH+(int)p.x+","+(int)p.y+",END";
  
  commandQueue.add(command);
}

int getMaxSegmentLength()
{
  return this.maxSegmentLength;
}

void sendTestPattern()
{
  String command = CMD_DRAWDIRECTIONTEST+int(gridSize)+",6,END";
  commandQueue.add(command);
}

void sendTestPenWidth()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  
  df.applyPattern("##0.##");
  StringBuilder sb = new StringBuilder();
  sb.append(testPenWidthCommand)
    .append(int(gridSize))
    .append(",")
    .append(df.format(testPenWidthStartSize))
    .append(",")
    .append(df.format(testPenWidthEndSize))
    .append(",")
    .append(df.format(testPenWidthIncrementSize))
    .append(",END");
  commandQueue.add(sb.toString());
}

void sendSetPosition()
{
  PVector p = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
  p = getDisplayMachine().convertToNative(p);
  p = getDisplayMachine().inSteps(p);
  
  String command = CMD_SETPOSITION+int(p.x+0.5)+","+int(p.y+0.5)+",END";
  commandQueue.add(command);
}

void sendSetHomePosition()
{
  PVector homePoint = getDisplayMachine().inSteps(getHomePoint());
  PVector pgCoords = getDisplayMachine().asNativeCoords(homePoint);
  
  String command = CMD_SETPOSITION+int(pgCoords.x+0.5)+","+int(pgCoords.y+0.5)+",END";
  commandQueue.add(command);
}

int scaleDensity(int inDens, int inMax, int outMax)
{
  float reducedDens = (float(inDens) / float(inMax)) * float(outMax);
  reducedDens = outMax-reducedDens;
//  println("inDens:"+inDens+", inMax:"+inMax+", outMax:"+outMax+", reduced:"+reducedDens);
  
  // round up if bigger than .5
  int result = int(reducedDens);
  if (reducedDens - (result) > 0.5)
    result ++;
  
  //result = outMax - result;
  return result;
}

SortedMap<Float, List<PVector>> divideIntoRows(Set<PVector> pixels, int direction)
{
  SortedMap<Float, List<PVector>> inRows = new TreeMap<Float, List<PVector>>();
  
  for (PVector p : pixels)
  {
    Float row = p.x;
    if (direction == DRAW_DIR_SE || direction == DRAW_DIR_NW)
      row = p.y;
      
    if (!inRows.containsKey(row))
    {
      inRows.put(row, new ArrayList<PVector>());
    }
    inRows.get(row).add(p);
  }
  return inRows;
}

PVector sortPixelsInRowsAlternating(SortedMap<Float, List<PVector>> inRows, int initialDirection, float maxPixelSize)
{
  PVector startPoint = null;
  Comparator comp = null;
  boolean rowIsAlongXAxis = true;
  
  if (initialDirection == DRAW_DIR_SE || initialDirection == DRAW_DIR_NW)
  {
    rowIsAlongXAxis = true;
    comp = xAscending;
  }
  else
  {
    rowIsAlongXAxis = false;
    comp = yAscending;
  }
  
  // now sort each row, reversing the direction after each row
  boolean reverse = false;
  for (Float rowCoord : inRows.keySet())
  {
    println("row: " + rowCoord);
    List<PVector> row = inRows.get(rowCoord);

    if (reverse)
    {
      // reverse it (descending)
      Collections.sort(row, comp);
      Collections.reverse(row);
      if (startPoint == null)
      {
        if (rowIsAlongXAxis)
          startPoint = new PVector(row.get(0).x+(maxPixelSize/2.0), row.get(0).y);
        else
          startPoint = new PVector(row.get(0).x, row.get(0).y-(maxPixelSize/2.0));
      }
      reverse = false;
    }
    else
    {
      // sort row ascending
      Collections.sort(row, comp);
      if (startPoint == null)
      {
        if (rowIsAlongXAxis)
          startPoint = new PVector(row.get(0).x-(maxPixelSize/2.0), row.get(0).y);
        else
          startPoint = new PVector(row.get(0).x, row.get(0).y+(maxPixelSize/2.0));
      }
      reverse = true;
    }
  }
  return startPoint;
}
   
void sortPixelsInRows(SortedMap<Float, List<PVector>> inRows, int initialDirection)
{
  PVector startPoint = null;
  Comparator comp = null;
  boolean rowIsAlongXAxis = true;
  
  if (initialDirection == DRAW_DIR_SE || initialDirection == DRAW_DIR_NW)
  {
    rowIsAlongXAxis = true;
    comp = xAscending;
  }
  else
  {
    rowIsAlongXAxis = false;
    comp = yAscending;
  }
  
  // now sort each row, reversing the direction after each row
  for (Float rowCoord : inRows.keySet())
  {
    println("row: " + rowCoord);
    List<PVector> row = inRows.get(rowCoord);
    // sort row ascending
    Collections.sort(row, comp);
    
    if (initialDirection == DRAW_DIR_NW || initialDirection == DRAW_DIR_NE)
      Collections.reverse(row);
  }
}


void sendPixels(Set<PVector> pixels, String pixelCommand, int initialDirection, float maxPixelSize, boolean scaleSizeToDensity)
{
  // sort it into a map of rows, keyed by y coordinate value
  SortedMap<Float, List<PVector>> inRows = divideIntoRows(pixels, initialDirection);
  
  PVector startPoint = sortPixelsInRowsAlternating(inRows, initialDirection, maxPixelSize);
  
  // that was easy.
  // load the queue
  // add a preamble
  
  // set the first direction
  int drawDirection = initialDirection;
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
  commandQueue.add(changeDir);
  
  // and move the pen to just next to the first pixel
  if (startPoint != null)
  {
    String touchdown = CMD_CHANGELENGTH+int(startPoint.x+0.5)+","+int(startPoint.y+0.5)+",END";
    commandQueue.add(touchdown);
    commandQueue.add(CMD_PENDOWN+"END");
  }
    
  
  for (Float key : inRows.keySet())
  {
    List<PVector> row = inRows.get(key);
    for (PVector v : row)
    {
      // now convert to ints 
      int inX = int(v.x);
      int inY = int(v.y);
      Integer density = int(v.z);
      int pixelSize = int(maxPixelSize);
      if (scaleSizeToDensity)
      {
        pixelSize = scaleDensity(density, 255, int(maxPixelSize));
        density = 0;
      }
      String command = pixelCommand+inX+","+inY+","+int(pixelSize+0.5)+","+density+",END";

      commandQueue.add(command);
    }

    drawDirection = flipDrawDirection(drawDirection);
    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
    commandQueue.add(command);
  }
  
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

int flipDrawDirection(int curr)
{
  if (curr == DRAW_DIR_SE)
    return DRAW_DIR_NW;
  else if (curr == DRAW_DIR_NW)
    return DRAW_DIR_SE;
  else if (curr == DRAW_DIR_NE)
    return DRAW_DIR_SW;
  else if (curr == DRAW_DIR_SW)
    return DRAW_DIR_NE;
  else return DRAW_DIR_SE;
}
  

int getPixelDirectionMode()
{
  return pixelDirectionMode;
}


void sendSawtoothPixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWSAWPIXEL, DRAW_DIR_SE, getGridSize(), false);
}
void sendCircularPixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWROUNDPIXEL, DRAW_DIR_SE, getGridSize(), false);
}

void sendScaledSquarePixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWPIXEL, DRAW_DIR_SE, getGridSize(), true);
}

void sendSolidSquarePixels(Set<PVector> pixels)
{
  for (PVector p : pixels)
  {
    p.z = 0.0;
  }
  sendPixels(pixels, CMD_DRAWPIXEL, DRAW_DIR_SE, getGridSize(), false);
}

void sendSquarePixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWPIXEL, DRAW_DIR_SE, getGridSize(), false);
}

void sendScribblePixels(Set<PVector> pixels)
{
  sendPixels(pixels, CMD_DRAWSCRIBBLEPIXEL, DRAW_DIR_SE, getGridSize(), false);
}


void sendOutlineOfPixels(Set<PVector> pixels)
{
  // sort it into a map of rows, keyed by y coordinate value
  SortedMap<Float, List<PVector>> inRows = divideIntoRows(pixels, DRAW_DIR_SE);
  
  sortPixelsInRowsAlternating(inRows, DRAW_DIR_SE, getGridSize());

  float halfGrid = getGridSize() / 2.0;
  for (Float key : inRows.keySet())
  {
    for (PVector p : inRows.get(key))
    {
      PVector startPoint = new PVector(p.x-halfGrid, p.y-halfGrid);
      PVector endPoint = new PVector(p.x+halfGrid, p.y+halfGrid);
      String command = CMD_DRAWRECT + int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
      commandQueue.add(command);
    }
  }  
}

void sendOutlineOfRows(Set<PVector> pixels, int drawDirection)
{
  // sort it into a map of rows, keyed by y coordinate value
  SortedMap<Float, List<PVector>> inRows = divideIntoRows(pixels, drawDirection);
  
  sortPixelsInRows(inRows, drawDirection);

  PVector offset = new PVector(getGridSize() / 2.0, getGridSize() / 2.0);
  for (Float key : inRows.keySet())
  {
    PVector startPoint = inRows.get(key).get(0);
    PVector endPoint = inRows.get(key).get(inRows.get(key).size()-1);
    
    if (drawDirection == DRAW_DIR_SE)
    {
      startPoint.sub(offset);
      endPoint.add(offset);
    }
    else if (drawDirection == DRAW_DIR_NW)
    {
      startPoint.add(offset);
      endPoint.sub(offset);
    }
    else if (drawDirection == DRAW_DIR_SW)
    {
      startPoint.add(offset);
      endPoint.sub(offset);
    }
    else if (drawDirection == DRAW_DIR_NW)
    {
      startPoint.add(offset);
      endPoint.sub(offset);
    }
    
    String command = CMD_DRAWRECT + int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
    commandQueue.add(command);
  }  
}

void sendGridOfBox(Set<PVector> pixels)
{
  sendOutlineOfRows(pixels, DRAW_DIR_SE);
  sendOutlineOfRows(pixels, DRAW_DIR_SW);
}


void sendOutlineOfBox()
{
  // convert cartesian to native format
  PVector tl = getDisplayMachine().inSteps(getBoxVector1());
  PVector br = getDisplayMachine().inSteps(getBoxVector2());

  PVector tr = new PVector(br.x, tl.y);
  PVector bl = new PVector(tl.x, br.y);
  
  tl = getDisplayMachine().asNativeCoords(tl);
  tr = getDisplayMachine().asNativeCoords(tr);
  bl = getDisplayMachine().asNativeCoords(bl);
  br = getDisplayMachine().asNativeCoords(br);
  
  String command = CMD_CHANGELENGTHDIRECT+(int)tl.x+","+(int)tl.y+",END";
  commandQueue.add(command);

  command = CMD_CHANGELENGTHDIRECT+(int)tr.x+","+(int)tr.y+",END";
  commandQueue.add(command);

  command = CMD_CHANGELENGTHDIRECT+(int)br.x+","+(int)br.y+",END";
  commandQueue.add(command);

  command = CMD_CHANGELENGTHDIRECT+(int)bl.x+","+(int)bl.y+",END";
  commandQueue.add(command);

  command = CMD_CHANGELENGTHDIRECT+(int)tl.x+","+(int)tl.y+",END";
  commandQueue.add(command);
}

