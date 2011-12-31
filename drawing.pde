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
  command = CMD_CHANGEMACHINESIZE+getMachine().getWidth()+","+getMachine().getHeight()+",END";
  commandQueue.add(command);
  command = CMD_CHANGEMACHINEMMPERREV+getMachine().getMMPerRev()+",END";
  commandQueue.add(command);
  command = CMD_CHANGEMACHINESTEPSPERREV+getMachine().getStepsPerRev()+",END";
  commandQueue.add(command);
}


void sendMoveToPosition(boolean direct)
{
  String command = null;
  if (direct)
    command = CMD_CHANGELENGTHDIRECT+getALength()+","+getBLength()+","+getMaxSegmentLength()+",END";
  else
    command = CMD_CHANGELENGTH+getALength()+","+getBLength()+",END";
  
  commandQueue.add(command);
}

int getMaxSegmentLength()
{
  return this.maxSegmentLength;
}

void sendTestPattern()
{
  String command = CMD_DRAWDIRECTIONTEST+int(rowWidth)+",6,END";
  commandQueue.add(command);
}

void sendTestPenWidth()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  
  df.applyPattern("##0.##");
  StringBuilder sb = new StringBuilder();
  sb.append(testPenWidthCommand)
    .append(int(rowWidth))
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
  String command = CMD_SETPOSITION+getALength()+","+getBLength()+",END";
  commandQueue.add(command);
}

void sendSetHomePosition()
{
  PVector homePoint = new PVector(getMachine().getWidth()/2, getMachine().getPage().getTop());
  PVector pgCoords = getMachine().asNativeCoords(homePoint);
  
  String command = CMD_SETPOSITION+pgCoords.x+","+pgCoords.y+",END";
  commandQueue.add(command);
}

void sendSawtoothPixels()
{
  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == DRAW_DIR_SE)
    {
      for (PVector v : row) // left to right
      {
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        String command = CMD_DRAWSAWPIXEL+inX+","+inY+","+rowWidth+","+density+",END";
        commandQueue.add(command);
      }
    }
    else
    {
      for (int i = row.size()-1; i >= 0; i--) // right to left
      {
        PVector v = row.get(i);
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        String command = CMD_DRAWSAWPIXEL+inX+","+inY+","+rowWidth+","+density+",END";
        commandQueue.add(command);
      }
    }
    flipDirection();
    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
    commandQueue.add(command);
  }
}

void sendCircularPixels()
{
  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == DRAW_DIR_SE)
    {
      for (PVector v : row) // left to right
      {
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        String command = CMD_DRAWROUNDPIXEL+inX+","+inY+","+int(rowWidth)+","+density+",END";
        commandQueue.add(command);
      }
    }
    else
    {
      for (int i = row.size()-1; i >= 0; i--) // right to left
      {
        PVector v = row.get(i);
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        String command = CMD_DRAWROUNDPIXEL+inX+","+inY+","+int(rowWidth)+","+density+",END";
        commandQueue.add(command);
      }
    }
    flipDirection();
    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
    commandQueue.add(command);
  }
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
  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == DRAW_DIR_SE)
    {
      for (PVector v : row) // left to right
      {
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        int pixelSize = scaleDensity(density, 255, rowWidth);
        String command = CMD_DRAWPIXEL+inX+","+inY+","+(pixelSize)+",0,END";

        commandQueue.add(command);
      }
    }
    else
    {
      for (int i = row.size()-1; i >= 0; i--) // right to left
      {
        PVector v = row.get(i);
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        int pixelSize = scaleDensity(density, 255, rowWidth);
        String command = CMD_DRAWPIXEL+inX+","+inY+","+(pixelSize)+",0,END";
        commandQueue.add(command);
      }
    }
    flipDirection();
    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
    commandQueue.add(command);
  }
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

void sendSolidSquarePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
  commandQueue.add(changeDir);
  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == DRAW_DIR_SE)
    {
      for (PVector v : row) // left to right
      {
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        String command = CMD_DRAWPIXEL+inX+","+inY+","+(rowWidth)+",0,END";

        commandQueue.add(command);
      }
    }
    else
    {
      for (int i = row.size()-1; i >= 0; i--) // right to left
      {
        PVector v = row.get(i);
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        String command = CMD_DRAWPIXEL+inX+","+inY+","+(rowWidth)+",0,END";
        commandQueue.add(command);
      }
    }
    flipDirection();
    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
    commandQueue.add(command);
  }
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

void sendSquarePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
  commandQueue.add(changeDir);

  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == DRAW_DIR_SE)
    {
      for (PVector v : row) // left to right
      {
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        String command = CMD_DRAWPIXEL+inX+","+inY+","+(rowWidth)+","+density+",END";

        commandQueue.add(command);
      }
    }
    else
    {
      for (int i = row.size()-1; i >= 0; i--) // right to left
      {
        PVector v = row.get(i);
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        String command = CMD_DRAWPIXEL+inX+","+inY+","+(rowWidth)+","+density+",END";
        commandQueue.add(command);
      }
    }
    flipDirection();
    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
    commandQueue.add(command);
  }
  
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

  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == DRAW_DIR_SE)
    {
      for (PVector v : row) // left to right
      {
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        String command = CMD_DRAWSCRIBBLEPIXEL+inX+","+inY+","+(rowWidth)+","+density+",END";

        commandQueue.add(command);
      }
    }
    else
    {
      for (int i = row.size()-1; i >= 0; i--) // right to left
      {
        PVector v = row.get(i);
        // now convert to ints 
        int inX = int(v.x);
        int inY = int(v.y);
        Integer density = int(v.z);
        String command = CMD_DRAWSCRIBBLEPIXEL+inX+","+inY+","+(rowWidth)+","+density+",END";
        commandQueue.add(command);
      }
    }
    flipDirection();
    String command = CMD_CHANGEDRAWINGDIRECTION+getPixelDirectionMode()+"," + drawDirection +",END";
    commandQueue.add(command);
  }
  
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}


void sendOutlineOfPixels()
{
  PVector offset = new PVector(rowWidth/2.0, rowWidth/2.0);

  for (List<PVector> row : pixelCentresForMachine)
  {
    for (PVector v : row)
    {
      // now convert to native format
      // now offset by row size
      PVector startPoint = PVector.sub(v, offset);
      PVector endPoint = PVector.add(v, offset);
      // now convert to steps
      String command = CMD_DRAWRECT+int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
      commandQueue.add(command);
    }
  }
}

void sendOutlineOfRows()
{
  for (List<PVector> row : pixelCentresForMachine)
  {
    PVector first = row.get(0);
    PVector last = row.get(row.size()-1);
    
    // now offset by row size
    PVector offset = new PVector(rowWidth/2.0, rowWidth/2.0);
    
    PVector startPoint = PVector.sub(first, offset);
    PVector endPoint = PVector.add(last, offset);
    
    // now convert to steps
    String command = CMD_DRAWRECT+int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
    commandQueue.add(command);
  }
  
  // now do it in the opposite axis
  
  List<List<PVector>> otherWay = extractRowsFromBoxOpposite();
  for (List<PVector> row : otherWay)
  {
    PVector first = row.get(0);
    PVector last = row.get(row.size()-1);
    
    // now offset by row size
    PVector offset = new PVector(rowWidth/2.0, rowWidth/2.0);
    
    PVector startPoint = PVector.sub(first, offset);
    PVector endPoint = PVector.add(last, offset);
    
    // now convert to steps
    String command = CMD_DRAWRECT+int(startPoint.x)+","+int(startPoint.y)+","+int(endPoint.x)+","+int(endPoint.y)+",END";
    commandQueue.add(command);
  }

}

void sendGridOfBox()
{
  String rowDirection = "LTR";
  float halfRow = rowWidth/2.0;
  PVector startPoint = null;
  PVector endPoint = null;

  for (List<PVector> row : pixelCentresForMachine)
  {
    PVector first = row.get(0);
    PVector last = row.get(row.size()-1);


    if (rowDirection.equals("LTR"))
    {
      // now offset by row size
      startPoint = new PVector(first.x-halfRow, first.y-halfRow);
      endPoint = new PVector(last.x+halfRow, last.y-halfRow);
    }
    else
    {
      // now offset by row size
      startPoint = new PVector(last.x+halfRow, last.y-halfRow);
      endPoint = new PVector(first.x-halfRow, first.y-halfRow);
    }      
      
    
    // goto beginning of long line (probably the shortline)
    String command = CMD_CHANGELENGTH+int(startPoint.x)+","+int(startPoint.y)+",END";
    commandQueue.add(command);
    
    // draw long line
    command=CMD_CHANGELENGTH+int(endPoint.x)+","+int(endPoint.y)+",END";
    commandQueue.add(command);
    
    if (rowDirection.equals("LTR"))
      rowDirection = "RTL";
    else
      rowDirection = "LTR";
  }
  
  // now do it in the opposite axis
  
  List<List<PVector>> otherWay = extractRowsFromBoxOpposite();
  for (List<PVector> row : otherWay)
  {
    PVector first = row.get(0);
    PVector last = row.get(row.size()-1);
    
    if (rowDirection.equals("LTR"))
    {
      // now offset by row size
      startPoint = new PVector(first.x-halfRow, first.y+halfRow);
      endPoint = new PVector(last.x-halfRow, last.y-halfRow);
    }
    else
    {
      // now offset by row size
      startPoint = new PVector(last.x-halfRow, last.y-halfRow);
      endPoint = new PVector(first.x-halfRow, first.y+halfRow);
    }
      
    
    // goto beginning of line (probably the shortline)
    String command = CMD_CHANGELENGTH+int(startPoint.x)+","+int(startPoint.y)+",END";
    commandQueue.add(command);
    
    // draw long line
    command=CMD_CHANGELENGTH+int(endPoint.x)+","+int(endPoint.y)+",END";
    commandQueue.add(command);
    
    if (rowDirection.equals("LTR"))
      rowDirection = "RTL";
    else
      rowDirection = "LTR";
  }

}


void sendOutlineOfBox()
{
  // convert cartesian to native format
  PVector coords = getMachine().asNativeCoords(boxVector1);
  String command = CMD_CHANGELENGTHDIRECT+coords.x+","+coords.y+",END";
  commandQueue.add(command);

  coords = getMachine().asNativeCoords(boxVector2.x, boxVector1.y);
  command = CMD_CHANGELENGTHDIRECT+coords.x+","+coords.y+",END";
  commandQueue.add(command);

  coords = getMachine().asNativeCoords(boxVector2);
  command = CMD_CHANGELENGTHDIRECT+coords.x+","+coords.y+",END";
  commandQueue.add(command);

  coords = getMachine().asNativeCoords(boxVector1.x, boxVector2.y);
  command = CMD_CHANGELENGTHDIRECT+coords.x+","+coords.y+",END";
  commandQueue.add(command);

  coords = getMachine().asNativeCoords(boxVector1);
  command = CMD_CHANGELENGTHDIRECT+coords.x+","+coords.y+",END";
  commandQueue.add(command);
}

