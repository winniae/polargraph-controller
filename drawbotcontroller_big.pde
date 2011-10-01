/**
  Polargraph controller - written by Sandy Noble
*/

import processing.serial.*;

boolean drawbotReady = false;

String newMachineName = "PGXXABCD";
int newMachineWidth = 712;
int newMachineHeight = 980;

final int MACHINE_SRAM = 2048;
float stepsPerRev = 800.00;
float mmPerRev = 95;

float mmPerStep = mmPerRev / stepsPerRev;
float stepsPerMM = stepsPerRev / mmPerRev;

int homeALengthMM = 400;
int homeBLengthMM = 400;

int machineWidth = 712;
int machineHeight = 980;

final int A3_WIDTH = 297;
final int A3_HEIGHT = 420;

final int A2_WIDTH = 418;
final int A2_HEIGHT = 594;

final int A1_WIDTH = 594;
final int A1_HEIGHT = 841;

int pageWidth = A1_WIDTH;
int pageHeight = A1_HEIGHT;

int pagePositionX = (machineWidth/2) - (pageWidth/2);
int pagePositionY = 120;

//PVector imageOffset = new PVector(pagePositionX, pagePositionY+87); // 42cm square
//PVector imageOffset = new PVector(pagePositionX, pagePositionY-50); // mona lisa
//PVector imageOffset = new PVector(pagePositionX+87, pagePositionY);
PVector imageOffset = new PVector(pagePositionX, pagePositionY); // centred

PVector pictureFrameSize = new PVector(400.0, 400.0);
PVector pictureFrameTopLeft = new PVector((machineWidth/2) - (pictureFrameSize.x/2), (pageHeight/2)+pagePositionY - (pictureFrameSize.y/2));
PVector pictureFrameBotRight = new PVector(pictureFrameTopLeft.x + pictureFrameSize.x, pictureFrameTopLeft.y+pictureFrameSize.y);

//PVector pictureFrameSize = new PVector(250.0, 250.0);
//PVector pictureFrameTopLeft = new PVector((machineWidth/2) - (pictureFrameSize.x/2), 27+pagePositionY);
//PVector pictureFrameBotRight = new PVector(pictureFrameTopLeft.x + pictureFrameSize.x, pictureFrameTopLeft.y+pictureFrameSize.y);

int panelPositionX = machineWidth + 10;
int panelPositionY = 10;

int panelWidth = 50;
int panelHeight = machineHeight - panelPositionY;

int buttonHeight = 30;
int noOfButtons = 30;

int leftEdgeOfQueue = 800;
int rightEdgeOfQueue = 1100;
int topEdgeOfQueue = 0;
int bottomEdgeOfQueue = 0;
int queueRowHeight = 15;


Serial myPort;                       // The serial port
int[] serialInArray = new int[1];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive

PImage bitmap;

SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy hh:mm:ss");

String commandStatus = "Waiting for a click.";

int rowWidth = 75;
float currentPenWidth = 1.2;
final int TOTAL_ROW_WIDTH = inSteps(1200);
int rows = TOTAL_ROW_WIDTH / rowWidth;

int[] rowSegmentsForScreen = null;
int[] rowSegmentsForMachine = null;

List<List<PVector>> pixelCentresForScreen = null;
List<List<PVector>> pixelCentresForMachine = null;

List<String> commandQueue = new ArrayList<String>();
List<String> realtimeCommandQueue = new ArrayList<String>();
List<String> commandHistory = new ArrayList<String>();

String lastCommand = "";
Boolean commandQueueRunning = false;

String drawDirection = "LTR";

PVector currentMachinePos = new PVector();
int machineAvailMem = 0;
int machineUsedMem = 0;
int machineMinAvailMem = 2048;


static final int MODE_BEGIN = 0;
static final int MODE_INPUT_BOX_TOP_LEFT = 1;
static final int MODE_INPUT_BOX_BOT_RIGHT = 2;
static final int MODE_DRAW_OUTLINE_BOX = 4;
static final int MODE_DRAW_OUTLINE_BOX_ROWS = 5;
static final int MODE_DRAW_SHADE_BOX_ROWS_PIXELS = 6;
static final int MODE_DRAW_TO_POSITION = 7;
static final int MODE_RENDER_SQUARE_PIXELS = 8;
static final int MODE_RENDER_SAW_PIXELS = 9;
static final int MODE_RENDER_CIRCLE_PIXELS = 10;
static final int MODE_INPUT_ROW_START = 11;
static final int MODE_INPUT_ROW_END = 12;
static final int MODE_SET_POSITION = 13;
static final int MODE_DRAW_TESTPATTERN = 14;
static final int INS_INC_ROWSIZE = 15;
static final int INS_DEC_ROWSIZE = 16;
static final int MODE_DRAW_GRID = 17;
static final int PLACE_IMAGE = 18;
static final int LOAD_IMAGE = 19;
static final int PAUSE_QUEUE = 20;
static final int RUN_QUEUE = 21;
static final int CLEAR_QUEUE = 22;
static final int MODE_SET_POSITION_HOME = 23;
static final int MODE_INPUT_SINGLE_PIXEL = 24;
static final int MODE_DRAW_TEST_PENWIDTH = 25;
static final int MODE_RENDER_SCALED_SQUARE_PIXELS = 26;
static final int MODE_RENDER_SOLID_SQUARE_PIXELS = 27;
static final int MODE_RENDER_SCRIBBLE_PIXELS = 28;
static final int MODE_LOAD_SD_IMAGE = 29;
static final int MODE_START_ROVING = 30;
static final int MODE_STOP_ROVING = 31;
static final int MODE_SET_ROVE_AREA = 32;
static final int MODE_CREATE_MACHINE_TEXT_BITMAP = 34;
static final int MODE_CHANGE_MACHINE_SIZE = 35;
static final int MODE_CHANGE_MACHINE_NAME = 36;
static final int MODE_REQUEST_MACHINE_SIZE = 37;
static final int MODE_RESET_MACHINE = 38;


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
static final String CMD_DRAWROUNDPIXEL = "C16";
static final String CMD_GOTOCOORDS = "C17";
static final String CMD_TXIMAGEBLOCK = "C18";
static final String CMD_STARTROVE = "C19";
static final String CMD_STOPROVE = "C20";
static final String CMD_SETROVEAREA = "C21";
static final String CMD_LOADMAGEFILE = "C23";
static final String CMD_CHANGEMACHINESIZE = "C24";
static final String CMD_CHANGEMACHINENAME = "C25";
static final String CMD_REQUESTMACHINESIZE = "C26";
static final String CMD_RESETMACHINE = "C27";

//String testPenWidthCommand = "TESTPENWIDTHSCRIBBLE,";
String testPenWidthCommand = CMD_TESTPENWIDTHSQUARE;
String testPenWidthParameters = ",0.6,2.0,0.1,END"; // starting size, finish size, size of increments

Map<Integer, String> buttonLabels = buildButtonLabels();
Map<Integer, Integer> panelButtons = buildPanelButtons();

static int currentMode = MODE_BEGIN;

static PVector boxVector1 = null;
static PVector boxVector2 = null;

static PVector rowsVector1 = null;
static PVector rowsVector2 = null;

int numberOfPixelsTotal = 0;
int numberOfPixelsCompleted = 0;

Date timerStart = null;
Date timeLastPixelStarted = null;

boolean pixelTimerRunning = false;
boolean displayingSelectedCentres = false;
boolean displayingShadedCentres = true;
boolean displayingRowGridlines = false;

static final char BITMAP_BACKGROUND_COLOUR = 0x0F;

static final String filenameToLoadFromSD = "Marilyn         ";

void setup()
{
  size(machineWidth*2+panelWidth+20, 1020);

  // Print a list of the serial ports, for debugging purposes:
  println(Serial.list());

  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 57600);
  //read bytes into a buffer until you get a linefeed (ASCII 10):
  myPort.bufferUntil('\n');


//  bitmap = loadImage("monalisa2_l5.png");
//  bitmap = loadImage("monalisa2_l3+4.png");
//  bitmap = loadImage("monalisa2_l2.png");
//  bitmap = loadImage("monalisa2_l1a.png");
  bitmap = loadImage("liberty2.jpg");
//  bitmap = loadImage("earth2_400.jpg");
//  bitmap = loadImage("mars1_400.jpg");
//  bitmap = loadImage("moon2_400.jpg");
//  bitmap = loadImage("Marilyn1.jpg");
//  bitmap = loadImage("portrait_330.jpg");

  rebuildRows();  
  
  currentMode = MODE_BEGIN;
  
  commandQueue.add(CMD_CHANGEPENWIDTH+currentPenWidth+",END");
}

void draw()
{
  strokeWeight(1);
  if(mouseX >= pagePositionX 
  && mouseX < pagePositionX+pageWidth 
  && mouseY >= pagePositionY
  && mouseY < pagePositionY+pageHeight) {
    cursor(CROSS);
  } else {
    cursor(ARROW);
  }

  background(100);
  noFill();
  image(bitmap, imageOffset.x, imageOffset.y);
  
  stroke (100, 200, 100);

  showAllARows();
  showAllBRows();

  stroke(0, 0, 255, 50);
  strokeWeight(inMM(rowWidth));
  showARow();
  showBRow();
  strokeWeight(1);
  showMask();
  showPictureFrame();
  
  stroke(255, 150, 255, 100);
  strokeWeight(3);
  
  line(0,0, mouseX, mouseY);
  line(machineWidth,0, mouseX, mouseY);
  strokeWeight(1);
  
  stroke(150);
  noFill();
  rect(0, 0, machineWidth, machineHeight);

  
  stroke(255, 0, 0);
  showSelectedCentres(new PVector(0,0));
  
  showText();
  showPanel();
  showPreviewMachine();
  
  showGroupBox();

  showCurrentMachinePosition();

  if (drawbotReady)
  {
    dispatchCommandQueue();
  }
  
}

void showPictureFrame()
{
  stroke (255, 255, 0);
  ellipse(pictureFrameTopLeft.x, pictureFrameTopLeft.y, 10, 10);

  stroke (255, 128, 0);
  ellipse(pictureFrameBotRight.x, pictureFrameTopLeft.y, 10, 10);

  stroke (255, 0, 255);
  ellipse(pictureFrameBotRight.x, pictureFrameBotRight.y, 10, 10);

  stroke (255, 0, 128);
  ellipse(pictureFrameTopLeft.x, pictureFrameBotRight.y, 10, 10);

  stroke(255);
}

void showCurrentMachinePosition()
{
  noStroke();
  fill(255,0,255,150);
  PVector cartesian = getCartesian(inMM(currentMachinePos.x), inMM(currentMachinePos.y));
  ellipse(cartesian.x, cartesian.y, 20, 20);
  noFill();
}

int getALength() {
  int aLength = inSteps(dist(mouseX, mouseY, 0, 0));
  return aLength;
}
int getBLength() {
  int bLength = inSteps(dist(mouseX, mouseY, machineWidth, 0));
  return bLength;
}


void showGroupBox()
{
  if (boxVector1 != null && boxVector2 != null)
  {
    stroke(255,0,0);
    rect(boxVector1.x, boxVector1.y, boxVector2.x-boxVector1.x, boxVector2.y-boxVector1.y);
  }
}

void showPanel()
{
  stroke(150);
  noFill();
  rect(panelPositionX, panelPositionY, panelWidth, panelHeight);
  
  for (int i = 0; i < noOfButtons; i++)
  {
    if (panelButtons.containsKey(i))
    {
      Integer mode = panelButtons.get(i);
      if (currentMode == mode)
        stroke(255);
      else
        stroke(150);
      rect(panelPositionX+2, panelPositionY+(i*buttonHeight)+2, panelWidth-4,  buttonHeight-4);
      text(buttonLabels.get(mode), panelPositionX+6, panelPositionY+(i*buttonHeight)+20);
    }
  }
  
  noStroke();
}

String getButtonLabel(Integer butNo)
{
  if (buttonLabels.containsKey(butNo))
    return buttonLabels.get(butNo);
  else
    return "";
}


void showPreviewMachine()
{
  // machine outline
  int machineX = width - machineWidth;
  stroke(150);
  rect(machineX, 0, machineWidth, machineHeight); // machine
  rect(machineX+pagePositionX, pagePositionY, pageWidth, pageHeight); // page
  noStroke();
  
  showShadedCentres(new PVector(machineX, 0));
  
}

void showMask()
{
  noStroke();
  fill(100);
  rect(0, 0, width, pagePositionY); // top box
  rect(0, pagePositionY, pagePositionX, pageHeight+pagePositionY); // left box
  rect(pagePositionX+pageWidth, pagePositionY, width, pageHeight+pagePositionY); // right box
  rect(0, pageHeight+pagePositionY, width, height); // bottom box
  noFill();
  stroke(0);
  strokeWeight(2);
  rect(pagePositionX, pagePositionY, pageWidth, pageHeight); // page
  stroke(255);
  rect(pagePositionX-2, pagePositionY-2, pageWidth+4, pageHeight+4); // page
  strokeWeight(1);
}

void showSelectedCentres(PVector offset)
{
  if (displayingSelectedCentres)
  {
    int spotSize = 3;
    if (pixelCentresForScreen != null)
    {
      for (List<PVector> row : pixelCentresForScreen)
      {
        for (PVector v : row)
        {
          ellipse(offset.x+v.x, offset.y+v.y, spotSize, spotSize);
        }
      }
    }
  }
}

void showShadedCentres(PVector offset)
{
  if (displayingShadedCentres)
  {
    int spotSize = inMM(rowWidth);
    if (pixelCentresForScreen != null)
    {
      for (List<PVector> row : pixelCentresForScreen)
      {
        for (PVector v : row)
        {
          fill(v.z);
          ellipse(offset.x+v.x, offset.y+v.y, spotSize, spotSize);
        }
      }
    }
  }
  noFill();
}

int getDensity(PVector o, int dim)
{
  int averageDensity = 0;
  
  PVector v = PVector.sub(o,imageOffset);
  
  if (v.x < bitmap.width && v.y < bitmap.height)
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
  
  PVector v = PVector.sub(o,imageOffset);
  
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
      println("is chroma key " + red(centrePixel) + ", "+green(centrePixel)+","+blue(centrePixel));
      return true;
    }
    else
    {
      println("isn't chroma key " + red(centrePixel) + ", "+green(centrePixel)+","+blue(centrePixel));
      return false;
    }
  }
  else return false;
}

PVector getCartesian(int lenA, int lenB)
{
  int calcX = int((pow(machineWidth, 2) - pow(lenB, 2) + pow(lenA, 2)) / (machineWidth*2));
  int calcY = int(sqrt(pow(lenA,2)-pow(calcX,2)));
  PVector vect = new PVector(calcX, calcY);
  return vect;
}
PVector getNativeCoords(PVector cartesian)
{
  PVector result = getNativeCoords(cartesian.x, cartesian.y);
  return result;
}
PVector getNativeCoords(float x, float y)
{
  float aLine = dist(x, y, 0, 0);
  float bLine = dist(x, y, machineWidth, 0);
  
  PVector result = new PVector(aLine, bLine);
  return result;
}

void showAllARows()
{
  if (displayingRowGridlines)
  {
    if (pixelCentresForScreen == null || pixelCentresForScreen.isEmpty())
      stroke(0, 200, 0, 200);
    else
      stroke(0, 200, 0, 30);  
    for (int i = 0; i < rowSegmentsForScreen.length; i ++)
    {
      int dia = rowSegmentsForScreen[i]*2;
      ellipse(0, 0, dia, dia);
    }
  }
}
void showAllBRows()
{
  if (displayingRowGridlines)
  {
    if (pixelCentresForScreen == null || pixelCentresForScreen.isEmpty())
      stroke(0, 200, 0, 200);
    else
      stroke(0, 200, 0, 30);  
    for (int i = 0; i < rowSegmentsForScreen.length; i ++)
    {
      int dia = rowSegmentsForScreen[i]*2;
      ellipse(machineWidth, 0, dia, dia);
    }
  }
}

void showARow()
{
  int roundedLength = inMM(rounded(getALength()));
  int dia = roundedLength*2;
  int rowMM = inMM(rowWidth);
  ellipse(0, 0, dia, dia);
}
void showBRow()
{
  int roundedLength = inMM(rounded(getBLength()));
  int dia = roundedLength*2;
  ellipse(machineWidth, 0, dia, dia);
}

int rounded(int lineLength)
{
  int lowLine = rowSegmentsForMachine[0];
  int highLine = lowLine;
  int result = lowLine + (rowWidth / 2);
  
  for (int i = 0; i < (rowSegmentsForMachine.length-1); i++)
  {
    lowLine = rowSegmentsForMachine[i];
    highLine = rowSegmentsForMachine[i+1];
    
    if (lineLength >= lowLine 
    && lineLength <= highLine)
    {
      result = lowLine + (rowWidth / 2);
    }
  }
  
  return result;
}

boolean mouseOverMachine()
{
  boolean result = true;
  if (mouseX > machineWidth 
    || mouseY > machineHeight)
    result = false;
  return result;
}

boolean mouseOverPanel()
{
  boolean result = true;
  if (mouseX < panelPositionX
    || mouseX > panelPositionX + panelWidth
    || mouseY < panelPositionY
    || mouseY > panelPositionY + panelHeight)
    result = false;
  return result;
}

boolean mouseOverQueue()
{
  boolean result = true;
  if (mouseX < leftEdgeOfQueue
    || mouseX > rightEdgeOfQueue
    || mouseY < topEdgeOfQueue
    || mouseY > bottomEdgeOfQueue)
    result = false;
  return result;
}

Integer mouseOverButton()
{
  int posInPanel = mouseY - panelPositionY;
  int overButton = posInPanel / buttonHeight;
  
  if (panelButtons.containsKey(overButton))
    return panelButtons.get(overButton);
  else  
    return null;
}

void keyPressed()
{
  if (key == 'g' || key == 'G')
    displayingRowGridlines = (displayingRowGridlines) ? false : true;
  else if (key == 'p' || key == 'P')
    displayingShadedCentres = (displayingShadedCentres) ? false : true;
  else if (key == 's' || key == 'S')
    displayingSelectedCentres = (displayingSelectedCentres) ? false : true;
  else if (key == '+')
    realtimeCommandQueue.add(CMD_CHANGEMOTORSPEED+"25,END");  
  else if (key == '-')
    realtimeCommandQueue.add(CMD_CHANGEMOTORSPEED+"-25,END");  
  else if (key == '*')
    realtimeCommandQueue.add(CMD_CHANGEMOTORACCEL+"25,END");  
  else if (key == '/')
    realtimeCommandQueue.add(CMD_CHANGEMOTORACCEL+"-25,END");  
  else if (key == ']')
  {
    currentPenWidth = currentPenWidth+0.05;
    realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+currentPenWidth+",END");
  }
  else if (key == '[')
  {
    currentPenWidth = currentPenWidth-0.05;
    realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+currentPenWidth+",END");
  }
  else if (key == '#')
  {
    realtimeCommandQueue.add(CMD_PENUP+"END");
  }
  else if (key == '~')
  {
    realtimeCommandQueue.add(CMD_PENDOWN+"END");
  }
}
  
void mouseClicked()
{
  if (mouseOverMachine())
  { // picking coords
    machineClicked();
  }
  else if (mouseOverPanel())
  { // changing mode
    panelClicked();
  }
  else if (mouseOverQueue())
  {// stopping or starting 
    queueClicked();
  }
}

void machineClicked()
{
  switch (currentMode)
  {
    case MODE_BEGIN:
      currentMode = MODE_INPUT_BOX_TOP_LEFT;
      break;
    case MODE_INPUT_BOX_TOP_LEFT:
      setBoxVector1();
      extractRowsFromBox();
      currentMode = MODE_INPUT_BOX_BOT_RIGHT;
      break;
    case MODE_INPUT_BOX_BOT_RIGHT:
      setBoxVector2();
      extractRowsFromBox();
      break;
    case MODE_DRAW_OUTLINE_BOX_ROWS:
      break;
    case MODE_DRAW_SHADE_BOX_ROWS_PIXELS:
      setRowsVector1();
      setRowsVector2();
      extractRows();
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendOutlineOfPixels();
      break;
    case MODE_DRAW_OUTLINE_BOX:
      break;
    case MODE_SET_POSITION:
      sendSetPosition();
      break;
    case MODE_INPUT_ROW_START:
      setRowsVector1();
      extractRows();
      currentMode = MODE_INPUT_ROW_END;
      break;
    case MODE_INPUT_ROW_END:
      setRowsVector2();
      extractRows();
      break;
    case MODE_DRAW_TO_POSITION:
      sendMoveToPosition();
      break;
    default:
      break;
  }
}  

void panelClicked()
{
  Integer newMode = mouseOverButton();
  Integer lastMode = null;
  if (newMode != null)
  {
    lastMode = currentMode;
    currentMode = newMode;
  }
  
  
  switch (currentMode)
  {
    case MODE_BEGIN:
      reset();
      break;
    case MODE_DRAW_GRID:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendGridOfBox();
      break;
    case MODE_DRAW_OUTLINE_BOX_ROWS:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendOutlineOfRows();
      break;
    case MODE_DRAW_SHADE_BOX_ROWS_PIXELS:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendOutlineOfPixels();
      break;
    case MODE_DRAW_OUTLINE_BOX:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendOutlineOfBox();
      break;
    case INS_INC_ROWSIZE:
      rowWidth+=5;
      rebuildRows();
      extractRowsFromBox();
      extractRows();
      currentMode = lastMode;
      break;
    case INS_DEC_ROWSIZE:
      rowWidth-=5;
      rebuildRows();
      extractRowsFromBox();
      extractRows();
      currentMode = lastMode;
      break;
    case MODE_RENDER_SQUARE_PIXELS:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendSquarePixels();
      break;
    case MODE_RENDER_SCALED_SQUARE_PIXELS:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendScaledSquarePixels();
      break;
    case MODE_RENDER_SOLID_SQUARE_PIXELS:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendSolidSquarePixels();
      break;
    case MODE_RENDER_SCRIBBLE_PIXELS:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendScribblePixels();
      break;
    case MODE_RENDER_SAW_PIXELS:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendSawtoothPixels();
      break;
    case MODE_RENDER_CIRCLE_PIXELS:
      if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
        sendCircularPixels();
      break;
    case MODE_SET_POSITION:
      break;
      
    case MODE_DRAW_TESTPATTERN:
      sendTestPattern();
      break;
    case MODE_DRAW_TEST_PENWIDTH:
      sendTestPenWidth();
      break;
    case MODE_SET_POSITION_HOME:
      sendSetHomePosition();
      break;
    case MODE_START_ROVING:
      sendStartRove();
      break;
    case MODE_STOP_ROVING:
      sendStopRove();
      break;
    case MODE_SET_ROVE_AREA:
      sendRoveArea();
      break;
    case MODE_LOAD_SD_IMAGE:
      loadImageFromSD();
      break;
    case MODE_CHANGE_MACHINE_SIZE:
      sendNewMachineSize();
      break;
    case MODE_CHANGE_MACHINE_NAME:
      sendNewMachineName();
      break;
    case MODE_REQUEST_MACHINE_SIZE:
      sendRequestMachineSize();
      break;
    case MODE_RESET_MACHINE:
      sendResetMachine();
      break;
    default:
      break;
  }
}

void queueClicked()
{
  int relativeCoord = (mouseY-topEdgeOfQueue);
  int rowClicked = relativeCoord / queueRowHeight;
  
  if (rowClicked < 1) // its the header - start or stop queue
  {
    if (commandQueueRunning)
      commandQueueRunning = false;
    else
      commandQueueRunning = true;
  }
  else if (rowClicked > 1 && rowClicked < commandQueue.size()+2) // it's a command from the queue
  {
    int cmdNumber = rowClicked-2;
    if (commandQueueRunning)
    {
      // if its running, then clicking on a command will mark it as a pause point
    }
    else
    {
      // if it's not running, then clicking on a command row will remove it
      commandQueue.remove(cmdNumber);
    }
  }
}

void sendResetMachine()
{
  String command = CMD_RESETMACHINE + ",END";
  commandQueue.add(command);
}
void sendRequestMachineSize()
{
  String command = CMD_REQUESTMACHINESIZE + ",END";
  commandQueue.add(command);
}
void sendNewMachineSize()
{
  // ask for input to get the new machine size
  String command = CMD_CHANGEMACHINESIZE+","+newMachineWidth+","+newMachineHeight+",END";
  commandQueue.add(command);
}
void sendNewMachineName()
{
  // ask for input to get the new machine size
  String command = CMD_CHANGEMACHINENAME+","+newMachineName+",END";
  commandQueue.add(command);
}


void sendStartRove()
{
  String command = CMD_STARTROVE+",END";
  commandQueue.add(command);
}

void sendStopRove()
{
  String command = CMD_STOPROVE+",END";
  commandQueue.add(command);
}
void sendRoveArea()
{
  if (isRowsSpecified())
  {
    String command = CMD_SETROVEAREA+","+rowsVector1.x+","+rowsVector1.y+","+rowsVector2.x+","+rowsVector2.y+",END";
    commandQueue.add(command);
  }
}

void loadImageFromSD()
{
  String command = CMD_LOADMAGEFILE+","+filenameToLoadFromSD+",END";
  commandQueue.add(command);
}


void renderToFile()
{
  int outputWidth = machineWidth;
  int outputHeight = machineHeight;
  
  int imageWidth = bitmap.width;
  int imageHeight = bitmap.height;
  
  try
  {
    OutputStream out = createOutput("image.dat");
      
    int numOfPixels = 0;
    byte[] byteArray = "POLARGRAPH_IMAGE".getBytes();
    for (int i=0; i < byteArray.length; i++)
    {
      out.write(byteArray[i]);
    }
    byteArray = "V1.0            ".getBytes();
    for (int i=0; i < byteArray.length; i++)
    {
      out.write(byteArray[i]);
    }
    byteArray = "Marilyn         ".getBytes();
    for (int i=0; i < byteArray.length; i++)
    {
      out.write(byteArray[i]);
    }
    byteArray = (String.format("%08d", machineWidth)).getBytes();
    for (int i=0; i < byteArray.length; i++)
    {
      out.write(byteArray[i]);
    }
    byteArray = (String.format("%08d", machineHeight)).getBytes();
    for (int i=0; i < byteArray.length; i++)
    {
      out.write(byteArray[i]);
    }



    
    for (int row = 0; row < machineHeight; row++)
    {
      println("Processing image row " + row);
      for (int col = 0; col < machineWidth; col++)
      {
        if (col >= (int)imageOffset.x
          && col < (int)imageOffset.x+imageWidth
          && row >= (int)imageOffset.y
          && row < (int)imageOffset.y+ imageHeight)
        {
          numOfPixels++;
          int imgX = col - (int)imageOffset.x;
          int imgY = row - (int) imageOffset.y;
    
          color c = bitmap.pixels[imgY*imageWidth+imgX];
          int brightness = (int) red(c);
          byte ch = (byte) brightness;
          out.write(ch);
          println("Added pixel " + row + ", " + col + " (" + ch + "), pixel " + numOfPixels);
        }
        else
        {
          out.write((byte) BITMAP_BACKGROUND_COLOUR);
        }
      }
    }
    out.close();
  }
  catch (IOException ioe)
  {
    println("gosh, exception:" + ioe.getMessage());
  }
    
}


void sendMoveToPosition()
{
  String command = CMD_CHANGELENGTH+getALength()+","+getBLength()+",END";
  commandQueue.add(command);
}

void sendTestPattern()
{
  String command = CMD_TESTPATTERN+int(rowWidth)+",6,END";
  commandQueue.add(command);
}

void sendTestPenWidth()
{
  commandQueue.add(testPenWidthCommand+int(rowWidth)+testPenWidthParameters);
}

void sendSetPosition()
{
  String command = CMD_SETPOSITION+getALength()+","+getBLength()+",END";
  commandQueue.add(command);
}

void sendSetHomePosition()
{
  float distA = dist(0,0,machineWidth/2, pagePositionY);
  float distB = dist(machineWidth,0,machineWidth/2, pagePositionY);
  String command = CMD_SETPOSITION+inSteps(distA)+","+inSteps(distB)+",END";
  commandQueue.add(command);
}

void sendSawtoothPixels()
{
  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == "LTR")
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
    String command = CMD_CHANGEDRAWINGDIRECTION+"A," + drawDirection +",END";
    commandQueue.add(command);
  }
}

void sendCircularPixels()
{
  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == "LTR")
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
    String command = CMD_CHANGEDRAWINGDIRECTION+"A," + drawDirection +",END";
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
  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == "LTR")
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
    String command = CMD_CHANGEDRAWINGDIRECTION+"A," + drawDirection +",END";
    commandQueue.add(command);
  }
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

void sendSolidSquarePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");
  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == "LTR")
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
    String command = CMD_CHANGEDRAWINGDIRECTION+"A," + drawDirection +",END";
    commandQueue.add(command);
  }
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

void sendSquarePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");

  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == "LTR")
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
    String command = CMD_CHANGEDRAWINGDIRECTION+"A," + drawDirection +",END";
    commandQueue.add(command);
  }
  
  commandQueue.add(CMD_PENUP+"END");
  numberOfPixelsTotal = commandQueue.size();
  startPixelTimer();
}

void sendScribblePixels()
{
  commandQueue.add(CMD_PENDOWN+"END");

  for (List<PVector> row : pixelCentresForMachine)
  {
    if (drawDirection == "LTR")
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
    String command = CMD_CHANGEDRAWINGDIRECTION+"A," + drawDirection +",END";
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
    String command = CMD_CHANGELENGTH+","+int(startPoint.x)+","+int(startPoint.y)+",END";
    commandQueue.add(command);
    
    // draw long line
    command=CMD_CHANGELENGTH+","+int(endPoint.x)+","+int(endPoint.y)+",END";
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
    String command = CMD_CHANGELENGTH+","+int(startPoint.x)+","+int(startPoint.y)+",END";
    commandQueue.add(command);
    
    // draw long line
    command=CMD_CHANGELENGTH+","+int(endPoint.x)+","+int(endPoint.y)+",END";
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
  PVector coords = getNativeCoords(boxVector1);
  String command = CMD_GOTOCOORDS+inSteps(coords.x)+","+inSteps(coords.y)+",END";
  commandQueue.add(command);

  coords = getNativeCoords(boxVector2.x, boxVector1.y);
  command = CMD_GOTOCOORDS+inSteps(coords.x)+","+inSteps(coords.y)+",END";
  commandQueue.add(command);

  coords = getNativeCoords(boxVector2);
  command = CMD_GOTOCOORDS+inSteps(coords.x)+","+inSteps(coords.y)+",END";
  commandQueue.add(command);

  coords = getNativeCoords(boxVector1.x, boxVector2.y);
  command = CMD_GOTOCOORDS+inSteps(coords.x)+","+inSteps(coords.y)+",END";
  commandQueue.add(command);

  coords = getNativeCoords(boxVector1);
  command = CMD_GOTOCOORDS+inSteps(coords.x)+","+inSteps(coords.y)+",END";
  commandQueue.add(command);
}

void extractRowsFromBox()
{
  if (boxVector1 != null && boxVector2 != null)
  {
    List<List<PVector>> resultScr = new ArrayList<List<PVector>>();
    List<List<PVector>> resultMach = new ArrayList<List<PVector>>();
    
    for (int i = 0; i < rowSegmentsForMachine.length; i++)
    {
      List<PVector> rowListScr = new ArrayList<PVector>();
      List<PVector> rowListMach = new ArrayList<PVector>();
      for (int j = 0; j < rowSegmentsForMachine.length; j++)
      {
        int rowM = rowSegmentsForMachine[i] + (rowWidth/2);
        int colM = rowSegmentsForMachine[j] + (rowWidth/2);

        int rowS = rowSegmentsForScreen[i] + inMM(rowWidth/2.0);
        int colS = rowSegmentsForScreen[j] + inMM(rowWidth/2.0);
        
        PVector centreScr = getCartesian(colS, rowS);
        
        boolean pixelIsInsideBox = isPixelInsideBox(centreScr);
        
        if (pixelIsInsideBox)
        {
          boolean pixelIsChromaKey = isPixelChromaKey(centreScr);
          if (!pixelIsChromaKey)
          {
//            int density = getDensity(centreScr, inMM(rowWidth/2));
            int density = getDensity(centreScr, 10);
            centreScr.set(centreScr.x, centreScr.y, density);
            PVector centreMach = new PVector(colM, rowM, density);
            rowListScr.add(centreScr);
            rowListMach.add(centreMach);
          }
        }
      }
      if (!rowListMach.isEmpty())
      {
        resultMach.add(rowListMach);
        resultScr.add(rowListScr);
      }
    }
    
    pixelCentresForMachine = resultMach;
    pixelCentresForScreen = resultScr;
  }
}

List<List<PVector>> extractRowsFromBoxOpposite()
{
  List<List<PVector>> resultMach = new ArrayList<List<PVector>>();
  if (boxVector1 != null && boxVector2 != null)
  {
    
    for (int i = 0; i < rowSegmentsForMachine.length; i++)
    {
      List<PVector> rowListMach = new ArrayList<PVector>();
      for (int j = 0; j < rowSegmentsForMachine.length; j++)
      {
        int rowM = rowSegmentsForMachine[j] + (rowWidth/2);
        int colM = rowSegmentsForMachine[i] + (rowWidth/2);

        int rowS = rowSegmentsForScreen[j] + inMM(rowWidth/2.0);
        int colS = rowSegmentsForScreen[i] + inMM(rowWidth/2.0);
        
        PVector centreScr = getCartesian(colS, rowS);
        
        boolean pixelIsInsideBox = isPixelInsideBox(centreScr);
        
        if (pixelIsInsideBox)
        {
          int density = getDensity(centreScr, 10);
          centreScr.set(centreScr.x, centreScr.y, density);
          PVector centreMach = new PVector(colM, rowM, density);
          rowListMach.add(centreMach);
        }
      }
      if (!rowListMach.isEmpty())
      {
        resultMach.add(rowListMach);
      }
    }
  }
  return resultMach;
}

void extractRows()
{
  if (isRowsSpecified())
  {
    List<List<PVector>> resultScr = new ArrayList<List<PVector>>();
    List<List<PVector>> resultMach = new ArrayList<List<PVector>>();

    int startRow = int(rowsVector1.y);
    int endRow = int(rowsVector2.y);
    
    int startCol = int(rowsVector1.x);
    int endCol = int(rowsVector2.x);
    
    println("Start row: " + startRow +", end row: "+ endRow);
    println("Start col: " + startCol +", end col: "+ endCol);
    
    for (int i = 0; i < rowSegmentsForMachine.length; i++)
    {
      println("i:"+i+", rowSegments:" + rowSegmentsForMachine[i]);
      if (rowSegmentsForMachine[i] >= startRow && rowSegmentsForMachine[i] <= endRow)
      {
        println("row!!");
        List<PVector> rowListScr = new ArrayList<PVector>();
        List<PVector> rowListMach = new ArrayList<PVector>();
        for (int j = 0; j < rowSegmentsForMachine.length; j++)
        {
          if (rowSegmentsForMachine[j] >= startCol && rowSegmentsForMachine[j] <= endCol)
          {
            int row = rowSegmentsForMachine[i] + (rowWidth/2);
            int col = rowSegmentsForMachine[j] + (rowWidth/2);
            
            int rowForScreen = rowSegmentsForScreen[i] + inMM(rowWidth/2);
            int colForScreen = rowSegmentsForScreen[j] + inMM(rowWidth/2);
            
            PVector centreForScreen = getCartesian(colForScreen, rowForScreen);

            if (centreForScreen.x >= pagePositionX
              && centreForScreen.x <= pagePositionX + pageWidth
              && centreForScreen.y >= pagePositionY
              && centreForScreen.y <= pagePositionY+pageHeight)
            {
              int density = getDensity(centreForScreen, inMM(rowWidth/2));
              centreForScreen.set(centreForScreen.x, centreForScreen.y, density);
              PVector centreForMachine = new PVector(col, row, density);
              rowListScr.add(centreForScreen);
              rowListMach.add(centreForMachine);
            }
          }
        }
        resultScr.add(rowListScr);
        resultMach.add(rowListMach);
      }
    }
    
    pixelCentresForScreen = resultScr;
    pixelCentresForMachine = resultMach;
    
  }
}

boolean isPixelInsideBox(PVector vec)
{
  boolean result = false;
  if (boxVector1 != null && boxVector2 != null)
  {
    if (vec.x >= boxVector1.x
      && vec.x <= boxVector2.x
      && vec.y >= boxVector1.y
      && vec.y <= boxVector2.y)
    {
      result = true;
    }
  }
  return result;
}

boolean isRowsSpecified()
{
  if (rowsVector1 != null && rowsVector2 != null)
    return true;
  else
    return false;
}

void setRowsVector1()
{
  int roundedA = rounded(getALength())-rowWidth;
  int roundedB = rounded(getBLength())-rowWidth;
  PVector posInMachine = new PVector(roundedA, roundedB);
  rowsVector1 = posInMachine;
}
void setRowsVector2()
{
  int roundedA = rounded(getALength());
  int roundedB = rounded(getBLength());
  PVector posInMachine = new PVector(roundedA, roundedB);
  rowsVector2 = posInMachine;
}

boolean isBoxSpecified()
{
  if (boxVector1 != null && boxVector2 != null)
    return true;
  else
    return false;
}

void setBoxVector1()
{
  PVector posInMachine = new PVector(mouseX, mouseY);
  boxVector1 = posInMachine;
}
void setBoxVector2()
{
  PVector posInMachine = new PVector(mouseX, mouseY);
  boxVector2 = posInMachine;
}

void rebuildRows()
{
  rows = TOTAL_ROW_WIDTH / rowWidth;
  rowSegmentsForScreen = new int[rows];
  rowSegmentsForMachine = new int[rows];
  
  for (int i = 0; i < rows; i++)
  {
    int r = rowWidth * i;
    rowSegmentsForMachine[i] = r;
    rowSegmentsForScreen[i] = int(r / stepsPerMM);
    println("Machine Row:"+i+":"+r);
  }
}

void flipDirection()
{
  if (drawDirection.equals("LTR"))
    drawDirection = "RTL";
  else
    drawDirection = "LTR";
}

void reset()
{
  currentMode = MODE_BEGIN;
  commandQueue =  new ArrayList<String>();
}

void showText()
{
  fill(255);
  int tRow = 15;
  int textPositionX = 15;
  int textPositionY = 800+tRow;
  
  int tRowNo = 1;
  
  int calcALength = int(sqrt(pow(mouseX,2) + pow(mouseY,2)));
  int calcBLength = int(sqrt(pow(machineWidth-mouseX,2)+pow(mouseY,2)));
  
  text(mouseX + ", " + mouseY, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Pixel Length A: " + inMM(getALength()) + " (" + calcALength + ")", textPositionX, textPositionY+(tRow*tRowNo++));
  text("Pixel Length B: " + inMM(getBLength()) + " (" + calcBLength + ")", textPositionX, textPositionY+(tRow*tRowNo++));
  text("Steps Length A: " + getALength(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Steps Length B: " + getBLength(), textPositionX, textPositionY+(tRow*tRowNo++));
  
  String dbReady = "Drawbot is BUSY!";
  if (drawbotReady)
    dbReady = "READY!";

  text(dbReady, textPositionX, textPositionY+(tRow*tRowNo++));
    
  text(commandStatus, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent pen width: " + currentPenWidth, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Mode: " + currentMode, textPositionX, textPositionY+(tRow*tRowNo++));

  // middle side
  textPositionX = 300;
  textPositionY = 800+tRow;
  tRowNo = 1;
  
  text("Row size: " + rowWidth, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Row segments mach: " + rowSegmentsForMachine.length, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Row segments scr: " + rowSegmentsForScreen.length, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Box width: " + getBoxWidth(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Box height: " + getBoxHeight(), textPositionX, textPositionY+(tRow*tRowNo++));

  text("Box offset left: " + getBoxPosition().x, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Box offset top: " + getBoxPosition().y, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Available memory: " + machineAvailMem + " (min: " + machineMinAvailMem +", used: "+ machineUsedMem+")", textPositionX, textPositionY+(tRow*tRowNo++));

  text("Time cmd: " + getCurrentPixelTime() + ", total: " + getTimeSoFar(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Average time per cmd: " + getAveragePixelTime(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Time to go: " + getTimeRemainingMins() + " mins (" + getTimeRemainingSecs() + " secs)", textPositionX, textPositionY+(tRow*tRowNo++));

  text("Commands sent: " + getPixelsCompleted() + ", remaining: " + getPixelsRemaining(), textPositionX, textPositionY+(tRow*tRowNo++));

  text("Estimated complete: " + getEstimatedCompletionTime(), textPositionX, textPositionY+(tRow*tRowNo++));


  // right side
  textPositionX = 600;
  textPositionY = 800+tRow;
  tRowNo = 1;
  
  text("RowsVector1: " + rowsVector1, textPositionX, textPositionY+(tRow*tRowNo++));
  text("RowsVector2: " + rowsVector2, textPositionX, textPositionY+(tRow*tRowNo++));

  // far right side
  textPositionX = 900;
  textPositionY = 50;
  tRowNo = 1;

  int commandQueuePos = textPositionY+(tRow*tRowNo++);

  topEdgeOfQueue = commandQueuePos-queueRowHeight;
  leftEdgeOfQueue = textPositionX;
  rightEdgeOfQueue = textPositionX+300;
  bottomEdgeOfQueue = height;

  text("CommandQueue: " + commandQueueStatusText(), textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  text("Last command: " + ((commandHistory.isEmpty()) ? "-" : commandHistory.get(commandHistory.size()-1)), textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  text("Current command: " + lastCommand, textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  
  
  int queueNumber = commandQueue.size();
  for (String s : commandQueue)
  {
    text((queueNumber--)+". "+ s, textPositionX, commandQueuePos);
    commandQueuePos+=queueRowHeight;
  }
  
  

}

long getCurrentPixelTime()
{
  if (pixelTimerRunning)
    return new Date().getTime() - timeLastPixelStarted.getTime();
  else
    return 0L;
}
long getAveragePixelTime()
{
  if (pixelTimerRunning)
  {
    long msElapsed = timeLastPixelStarted.getTime() - timerStart.getTime();
    int pixelsCompleted = getPixelsCompleted();
    if (pixelsCompleted > 0)
      return msElapsed / pixelsCompleted;
    else
      return 0L;
  }
  else
    return 0L;
}
long getTimeSoFar()
{
  if (pixelTimerRunning)
    return new Date().getTime() - timerStart.getTime();
  else
    return 0L;
}
long getTimeRemaining()
{
  if (pixelTimerRunning)
    return getTotalEstimatedTime() - getTimeSoFar();
  else
    return 0L;
}
long getTotalEstimatedTime()
{
  if (pixelTimerRunning)
    return (getAveragePixelTime() * numberOfPixelsTotal);
  else
    return 0L;
}
long getTimeRemainingSecs()
{
  if (pixelTimerRunning)
    return getTimeRemaining() / 1000L;
  else
    return 0L;
}
long getTimeRemainingMins()
{
  if (pixelTimerRunning)
    return getTimeRemainingSecs()/60L;
  else
    return 0L;
}
String getEstimatedCompletionTime()
{
  if (pixelTimerRunning)
  {
    long totalTime = getTotalEstimatedTime()+timerStart.getTime();
    return sdf.format(totalTime);
  }
  else
    return "TIMER NOT RUNNING";
}

int getPixelsCompleted()
{
  if (pixelTimerRunning)
    return numberOfPixelsCompleted-1;
  else
    return 0;
}
int getPixelsRemaining()
{
  if (pixelTimerRunning)
    return numberOfPixelsTotal - getPixelsCompleted();
  else
    return 0;
}


String commandQueueStatusText()
{
  if (commandQueueRunning)
    return "RUNNING.";
  else
    return "PAUSED";
}

float getBoxWidth()
{
  if (boxVector1 != null && boxVector2 != null)
    return (boxVector2.x-boxVector1.x);
  else
    return 0;
}

float getBoxHeight()
{
  if (boxVector1 != null && boxVector2 != null)
    return (boxVector2.y-boxVector1.y);
  else
    return 0;
}

PVector getBoxPosition()
{
  if (boxVector1 != null)
    return boxVector1;
  else
    return new PVector();
}


int inSteps(int inMM) {
  float steps = inMM * stepsPerMM;
  int stepsInt = (int) steps;
  return stepsInt;
}

int inSteps(float inMM) {
  float steps = inMM * stepsPerMM;
  int stepsInt = (int) steps;
  return stepsInt;
}

int inMM(float steps) {
  float mm = steps / stepsPerMM;
  int mmInt = int(mm);
  return mmInt;
}

void serialEvent(Serial myPort) 
{ 
  // read the serial buffer:
  String incoming = myPort.readStringUntil('\n');
  myPort.clear();

  // if you got any bytes other than the linefeed:
  incoming = trim(incoming);
  println("incoming: " + incoming);
  
  if ("READY".equals(incoming))
    drawbotReady = true;
  else if (incoming.startsWith("SYNC"))
    readMachinePosition(incoming);
  else if (incoming.startsWith("PGNAME"))
    readMachineName(incoming);
  else if (incoming.startsWith("PGSIZE"))
    readMachineSize(incoming);
  else if (incoming.startsWith("ACK"))
    respondToAckCommand(incoming);
  else if ("RESEND".equals(incoming))
    resendLastCommand();
  else if ("DRAWING".equals(incoming))
    drawbotReady = false;
  else if (incoming.startsWith("MEMORY"))
    extractMemoryUsage(incoming);

}

void extractMemoryUsage(String mem)
{
  String[] splitted = split(mem, ",");
  if (splitted.length == 3)
  {
    machineAvailMem = Integer.parseInt(splitted[1]);
    machineUsedMem = MACHINE_SRAM - machineAvailMem;
    if (machineAvailMem < machineMinAvailMem)
      machineMinAvailMem = machineAvailMem;
  }
}

void readMachinePosition(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 4)
  {
    String currentAPos = splitted[1];
    String currentBPos = splitted[2];
    Float a = Float.valueOf(currentAPos).floatValue();
    Float b = Float.valueOf(currentBPos).floatValue();
    currentMachinePos.x = a;
    currentMachinePos.y = b;  
  }
}

void readMachineSize(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 4)
  {
    String mWidth = splitted[1];
    String mHeight = splitted[2];
    
    Integer intWidth = Integer.parseInt(mWidth);
    Integer intHeight = Integer.parseInt(mHeight);
    
    machineWidth = intWidth;
    machineHeight = intHeight;
  }
}

void readMachineName(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 3)
  {
    String name = splitted[1];
    
  }
}

void respondToAckCommand(String ack)
{
  String commandOnly = ack.substring(4);
  if (lastCommand.equals(commandOnly))
  {
    // that means the bot got the message!! huspag!!
    // signal the EXECUTION
    commandHistory.add(lastCommand);
    String command = "EXEC";
    lastCommand = "";
    println("Dispatching confirmation command: " + command);
    myPort.write(command);
  }
  else
  {
    // oh dear, the message got mangled!
    // try again!!!!
    if (lastCommand == null || lastCommand.equals(""))
    {
      println("Last command has been badly acknowledges, but there isn't one!!");
    }
    else
    {
      resendLastCommand();
    }
  }
}

void resendLastCommand()
{
  println("Re-sending command: " + lastCommand);
  myPort.write(lastCommand);
  drawbotReady = false;
}

void dispatchCommandQueue()
{
  if (isDrawbotReady() 
    && (!commandQueue.isEmpty() || !realtimeCommandQueue.isEmpty())
    && commandQueueRunning)
  {
    if (pixelTimerRunning)
    {
      timeLastPixelStarted = new Date();
      numberOfPixelsCompleted++;
    }

    if (!realtimeCommandQueue.isEmpty())
    {
      String command = realtimeCommandQueue.get(0);
      lastCommand = command;
      realtimeCommandQueue.remove(0);
      println("Dispatching PRIORITY command: " + command);
    }
    else
    {
      String command = commandQueue.get(0);
      lastCommand = command;
      commandQueue.remove(0);
      println("Dispatching command: " + command);
    }

    myPort.write(lastCommand);
    drawbotReady = false;
  }
  else if (commandQueue.isEmpty())
  {
    stopPixelTimer();
  }  
}

void startPixelTimer()
{
  timerStart = new Date();
  timeLastPixelStarted = timerStart;
  pixelTimerRunning = true;
}
void stopPixelTimer()
{
  pixelTimerRunning = false;
}

boolean isDrawbotReady()
{
  return drawbotReady;
}

Map<Integer, Integer> buildPanelButtons()
{
  Map<Integer, Integer> result = new HashMap<Integer, Integer>(30);
  result.put(0, MODE_BEGIN);
  result.put(1, MODE_SET_POSITION_HOME);
  result.put(2, MODE_SET_POSITION);
  result.put(3, MODE_DRAW_TO_POSITION);
  
  result.put(4, MODE_INPUT_BOX_TOP_LEFT);
  result.put(5, MODE_INPUT_BOX_BOT_RIGHT);

  result.put(6, MODE_INPUT_ROW_START);
  result.put(7, MODE_INPUT_ROW_END);


  result.put(8, MODE_DRAW_OUTLINE_BOX);
  result.put(9, MODE_DRAW_OUTLINE_BOX_ROWS);
  result.put(10, MODE_DRAW_SHADE_BOX_ROWS_PIXELS);

  result.put(11, MODE_DRAW_GRID);

  result.put(12, MODE_RENDER_SQUARE_PIXELS);
  result.put(13, MODE_RENDER_SCALED_SQUARE_PIXELS);
  result.put(14, MODE_RENDER_SOLID_SQUARE_PIXELS);
  result.put(15, MODE_RENDER_SCRIBBLE_PIXELS);

  result.put(16, MODE_DRAW_TEST_PENWIDTH);
  result.put(17, MODE_INPUT_SINGLE_PIXEL);

  result.put(18, INS_INC_ROWSIZE);
  result.put(19, INS_DEC_ROWSIZE);

  result.put(20, MODE_LOAD_SD_IMAGE);
  result.put(21, MODE_START_ROVING);
  result.put(22, MODE_STOP_ROVING);
  result.put(23, MODE_SET_ROVE_AREA);
  result.put(24, MODE_CHANGE_MACHINE_SIZE);
  result.put(25, MODE_CHANGE_MACHINE_NAME);
  result.put(26, MODE_REQUEST_MACHINE_SIZE);
  result.put(27, MODE_RESET_MACHINE);
  return result;
}

Map<Integer, String> buildButtonLabels()
{
  Map<Integer, String> result = new HashMap<Integer, String>(19);
  
  result.put(MODE_BEGIN, "Reset");
  result.put(MODE_INPUT_BOX_TOP_LEFT, "Box 1");
  result.put(MODE_INPUT_BOX_BOT_RIGHT, "Box 2");
  result.put(MODE_DRAW_OUTLINE_BOX, "Outline box");
  result.put(MODE_DRAW_OUTLINE_BOX_ROWS, "Outline rows");
  result.put(MODE_DRAW_SHADE_BOX_ROWS_PIXELS, "Outline pixels");

  result.put(MODE_DRAW_TO_POSITION, "Move to");
  result.put(MODE_RENDER_SQUARE_PIXELS, "Shade Sq");
  result.put(MODE_RENDER_SCALED_SQUARE_PIXELS, "Shade Scaled sq");
  result.put(MODE_RENDER_SAW_PIXELS, "Shade saw");
  result.put(MODE_RENDER_CIRCLE_PIXELS, "Shade circ");
  result.put(MODE_INPUT_ROW_START, "Row start");
  result.put(MODE_INPUT_ROW_END, "Row end");
  result.put(MODE_SET_POSITION, "Set pos");
  
  result.put(MODE_DRAW_GRID, "box grid");
  result.put(MODE_DRAW_TESTPATTERN, "test pattern");
  
  result.put(PLACE_IMAGE, "place image");
  result.put(LOAD_IMAGE, "load image");
  
  result.put(INS_INC_ROWSIZE, "Rowsize up");
  result.put(INS_DEC_ROWSIZE, "Rowsize down");
  result.put(MODE_SET_POSITION_HOME, "Set home");
  result.put(MODE_INPUT_SINGLE_PIXEL, "Choose pixel");
  result.put(MODE_DRAW_TEST_PENWIDTH, "Test pen widths");
  result.put(MODE_RENDER_SOLID_SQUARE_PIXELS, "Shade solid");
  result.put(MODE_RENDER_SCRIBBLE_PIXELS, "Scribble");

  result.put(MODE_LOAD_SD_IMAGE, "load image");
  result.put(MODE_START_ROVING, "start rove");
  result.put(MODE_STOP_ROVING, "stop rove");
  result.put(MODE_SET_ROVE_AREA, "set rove");
  result.put(MODE_CREATE_MACHINE_TEXT_BITMAP, "render as text");
  
  result.put(MODE_CHANGE_MACHINE_SIZE, "Change machine size");
  result.put(MODE_CHANGE_MACHINE_NAME, "Change machine name");
  result.put(MODE_REQUEST_MACHINE_SIZE, "Request machine details");
  result.put(MODE_RESET_MACHINE, "Reset machine");

  return result;
}

