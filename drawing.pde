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
  
  String command = CMD_SETPOSITION+p.x+","+p.y+",END";
  commandQueue.add(command);
}

void sendSetHomePosition()
{
  PVector homePoint = getDisplayMachine().inSteps(getHomePoint());
  PVector pgCoords = getDisplayMachine().asNativeCoords(homePoint);
  
  String command = CMD_SETPOSITION+pgCoords.x+","+pgCoords.y+",END";
  commandQueue.add(command);
}

void sendSawtoothPixels()
{
//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    if (drawDirection == DRAW_DIR_SE)
//    {
//      for (PVector v : row) // left to right
//      {
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        String command = CMD_DRAWSAWPIXEL+inX+","+inY+","+rowWidth+","+density+",END";
//        commandQueue.add(command);
//      }
//    }
//    else
//    {
//      for (int i = row.size()-1; i >= 0; i--) // right to left
//      {
//        PVector v = row.get(i);
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        String command = CMD_DRAWSAWPIXEL+inX+","+inY+","+rowWidth+","+density+",END";
//        commandQueue.add(command);
//      }
//    }
//    flipDirection();
//    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
//    commandQueue.add(command);
//  }
}

void sendCircularPixels()
{
//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    if (drawDirection == DRAW_DIR_SE)
//    {
//      for (PVector v : row) // left to right
//      {
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        String command = CMD_DRAWROUNDPIXEL+inX+","+inY+","+int(rowWidth)+","+density+",END";
//        commandQueue.add(command);
//      }
//    }
//    else
//    {
//      for (int i = row.size()-1; i >= 0; i--) // right to left
//      {
//        PVector v = row.get(i);
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        String command = CMD_DRAWROUNDPIXEL+inX+","+inY+","+int(rowWidth)+","+density+",END";
//        commandQueue.add(command);
//      }
//    }
//    flipDirection();
//    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
//    commandQueue.add(command);
//  }
}

int scaleDensity(int inDens, int inMax, int outMax)
{
  float reducedDens = (float(inDens) / float(inMax)) * float(outMax);
  reducedDens = outMax-reducedDens;
  println("inDens:"+inDens+", inMax:"+inMax+", outMax:"+outMax+", reduced:"+reducedDens);
  
  // round up if bigger than .5
  int result = int(reducedDens);
  if (reducedDens - (result) > 0.5)
    result ++;
  
  //result = outMax - result;
  return result;
}

void sendScaledSquarePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
  commandQueue.add(changeDir);
//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    if (drawDirection == DRAW_DIR_SE)
//    {
//      for (PVector v : row) // left to right
//      {
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        int pixelSize = scaleDensity(density, 255, rowWidth);
//        String command = CMD_DRAWPIXEL+inX+","+inY+","+(pixelSize)+",0,END";
//
//        commandQueue.add(command);
//      }
//    }
//    else
//    {
//      for (int i = row.size()-1; i >= 0; i--) // right to left
//      {
//        PVector v = row.get(i);
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        int pixelSize = scaleDensity(density, 255, rowWidth);
//        String command = CMD_DRAWPIXEL+inX+","+inY+","+(pixelSize)+",0,END";
//        commandQueue.add(command);
//      }
//    }
//    flipDirection();
//    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
//    commandQueue.add(command);
//  }
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

void sendSolidSquarePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
  commandQueue.add(changeDir);
//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    if (drawDirection == DRAW_DIR_SE)
//    {
//      for (PVector v : row) // left to right
//      {
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        String command = CMD_DRAWPIXEL+inX+","+inY+","+(rowWidth)+",0,END";
//
//        commandQueue.add(command);
//      }
//    }
//    else
//    {
//      for (int i = row.size()-1; i >= 0; i--) // right to left
//      {
//        PVector v = row.get(i);
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        String command = CMD_DRAWPIXEL+inX+","+inY+","+(rowWidth)+",0,END";
//        commandQueue.add(command);
//      }
//    }
//    flipDirection();
//    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
//    commandQueue.add(command);
//  }
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

void sendSquarePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
  commandQueue.add(changeDir);

//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    if (drawDirection == DRAW_DIR_SE)
//    {
//      for (PVector v : row) // left to right
//      {
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        String command = CMD_DRAWPIXEL+inX+","+inY+","+(rowWidth)+","+density+",END";
//
//        commandQueue.add(command);
//      }
//    }
//    else
//    {
//      for (int i = row.size()-1; i >= 0; i--) // right to left
//      {
//        PVector v = row.get(i);
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        String command = CMD_DRAWPIXEL+inX+","+inY+","+(rowWidth)+","+density+",END";
//        commandQueue.add(command);
//      }
//    }
//    flipDirection();
//    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
//    commandQueue.add(command);
//  }
  
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

int getPixelDirectionMode()
{
  return pixelDirectionMode;
}
void sendScribblePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
  commandQueue.add(changeDir);

//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    if (drawDirection == DRAW_DIR_SE)
//    {
//      for (PVector v : row) // left to right
//      {
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        String command = CMD_DRAWSCRIBBLEPIXEL+inX+","+inY+","+(rowWidth)+","+density+",END";
//
//        commandQueue.add(command);
//      }
//    }
//    else
//    {
//      for (int i = row.size()-1; i >= 0; i--) // right to left
//      {
//        PVector v = row.get(i);
//        // now convert to ints 
//        int inX = int(v.x);
//        int inY = int(v.y);
//        Integer density = int(v.z);
//        String command = CMD_DRAWSCRIBBLEPIXEL+inX+","+inY+","+(rowWidth)+","+density+",END";
//        commandQueue.add(command);
//      }
//    }
//    flipDirection();
//    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
//    commandQueue.add(command);
//  }
  
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}


void sendOutlineOfPixels()
{
  PVector offset = new PVector(gridSize/2.0, gridSize/2.0);

//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    for (PVector v : row)
//    {
//      // now convert to native format
//      // now offset by row size
//      PVector startPoint = PVector.sub(v, offset);
//      PVector endPoint = PVector.add(v, offset);
//      // now convert to steps
//      String command = CMD_DRAWRECT+int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
//      commandQueue.add(command);
//    }
//  }
}

void sendOutlineOfRows()
{
//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    PVector first = row.get(0);
//    PVector last = row.get(row.size()-1);
//    
//    // now offset by row size
//    PVector offset = new PVector(rowWidth/2.0, rowWidth/2.0);
//    
//    PVector startPoint = PVector.sub(first, offset);
//    PVector endPoint = PVector.add(last, offset);
//    
//    // now convert to steps
//    String command = CMD_DRAWRECT+int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
//    commandQueue.add(command);
//  }
  
  // now do it in the opposite axis
  
//  List<List<PVector>> otherWay = extractRowsFromBoxOpposite();
//  for (List<PVector> row : otherWay)
//  {
//    PVector first = row.get(0);
//    PVector last = row.get(row.size()-1);
//    
//    // now offset by row size
//    PVector offset = new PVector(rowWidth/2.0, rowWidth/2.0);
//    
//    PVector startPoint = PVector.sub(first, offset);
//    PVector endPoint = PVector.add(last, offset);
//    
//    // now convert to steps
//    String command = CMD_DRAWRECT+int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
//    commandQueue.add(command);
//  }

}

void sendGridOfBox()
{
  String rowDirection = "LTR";
  float halfRow = gridSize/2.0;
  PVector startPoint = null;
  PVector endPoint = null;

//  for (List<PVector> row : pixelCentresForMachine)
//  {
//    PVector first = row.get(0);
//    PVector last = row.get(row.size()-1);
//
//
//    if (rowDirection.equals("LTR"))
//    {
//      // now offset by row size
//      startPoint = new PVector(first.x-halfRow, first.y-halfRow);
//      endPoint = new PVector(last.x+halfRow, last.y-halfRow);
//    }
//    else
//    {
//      // now offset by row size
//      startPoint = new PVector(last.x+halfRow, last.y-halfRow);
//      endPoint = new PVector(first.x-halfRow, first.y-halfRow);
//    }      
//      
//    
//    // goto beginning of long line (probably the shortline)
//    String command = CMD_CHANGELENGTH+int(startPoint.x)+","+int(startPoint.y)+",END";
//    commandQueue.add(command);
//    
//    // draw long line
//    command=CMD_CHANGELENGTH+int(endPoint.x)+","+int(endPoint.y)+",END";
//    commandQueue.add(command);
//    
//    if (rowDirection.equals("LTR"))
//      rowDirection = "RTL";
//    else
//      rowDirection = "LTR";
//  }
//  
//  // now do it in the opposite axis
//  
//  List<List<PVector>> otherWay = extractRowsFromBoxOpposite();
//  for (List<PVector> row : otherWay)
//  {
//    PVector first = row.get(0);
//    PVector last = row.get(row.size()-1);
//    
//    if (rowDirection.equals("LTR"))
//    {
//      // now offset by row size
//      startPoint = new PVector(first.x-halfRow, first.y+halfRow);
//      endPoint = new PVector(last.x-halfRow, last.y-halfRow);
//    }
//    else
//    {
//      // now offset by row size
//      startPoint = new PVector(last.x-halfRow, last.y-halfRow);
//      endPoint = new PVector(first.x-halfRow, first.y+halfRow);
//    }
//      
//    
//    // goto beginning of line (probably the shortline)
//    String command = CMD_CHANGELENGTH+int(startPoint.x)+","+int(startPoint.y)+",END";
//    commandQueue.add(command);
//    
//    // draw long line
//    command=CMD_CHANGELENGTH+int(endPoint.x)+","+int(endPoint.y)+",END";
//    commandQueue.add(command);
//    
//    if (rowDirection.equals("LTR"))
//      rowDirection = "RTL";
//    else
//      rowDirection = "LTR";
//  }

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

