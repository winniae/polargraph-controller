/**
  Polargraph controller - written by Sandy Noble
  
  A lot of this is about the interface.
  
  
*/
import javax.swing.*;
import processing.serial.*;
//import controlP5.*;
import java.awt.event.KeyEvent;

//ControlP5 controlP5;

boolean drawbotReady = false;

String newMachineName = "PGXXABCD";

final int MACHINE_SRAM = 2048;
float stepsPerRev = 800.00;
float mmPerRev = 95; // 84 for kitters

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

int pageWidth = A3_WIDTH;
int pageHeight = A3_HEIGHT;

int pagePositionX = (machineWidth/2) - (pageWidth/2);
int pagePositionY = 120;

PVector imageOffset = new PVector(pagePositionX, pagePositionY);

PVector pictureFrameSize = new PVector(400.0, 400.0);
PVector pictureFrameOffset = new PVector((machineWidth/2) - (pictureFrameSize.x/2), (pageHeight/2)+pagePositionY - (pictureFrameSize.y/2));

int panelPositionX = machineWidth + 10;
int panelPositionY = 10;

int panelWidth = 100;
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

final JFileChooser chooser = new JFileChooser();

PImage bitmap;

SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy hh:mm:ss");

String commandStatus = "Waiting for a click.";

int sampleArea = 10;
int rowWidth = 75;
float currentPenWidth = 1.2;
float penIncrement = 0.05;
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
static final int MODE_SAVE_PROPERTIES = 39;
static final int MODE_INC_SAMPLE_AREA = 40;
static final int MODE_DEC_SAMPLE_AREA = 41;
static final int MODE_MOVE_IMAGE = 42;
static final int MODE_INPUT_IMAGE = 43;
static final int MODE_CONVERT_BOX_TO_PICTUREFRAME = 44;
static final int MODE_SELECT_PICTUREFRAME = 45;
static final int MODE_EXPORT_QUEUE = 46;
static final int MODE_IMPORT_QUEUE = 47;
static final int MODE_CLEAR_QUEUE = 48;


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
static final String CMD_GOTOCOORDS = "C17,";
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
float testPenWidthStartSize = 0.5;
float testPenWidthEndSize = 2.0;
float testPenWidthIncrementSize = 0.5;

Map<Integer, String> buttonLabels = buildButtonLabels();

Map<Integer, Map<Integer, Integer>> panels = buildPanels();

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
boolean displayingInfoTextOnInputPage = true;

static final char BITMAP_BACKGROUND_COLOUR = 0x0F;

static final String filenameToLoadFromSD = "Marilyn         ";

// used in the preview page
static Integer pageColour = 100;

// Page states
public static final int PAGE_IMAGE = 1;
public static final int PAGE_PREVIEW = 2;
public static final int PAGE_COMMAND_QUEUE = 3;
public static final int PAGE_LOAD_IMAGE = 4;
public static final int PAGE_DETAILS = 5;
public static final int DEFAULT_PAGE = PAGE_IMAGE;
public int currentPage = DEFAULT_PAGE;

public boolean showingSummaryOverlay = true;
public boolean showingDialogBox = false;

public Integer windowWidth = 900;
public Integer windowHeight = 550;

public static Integer serialPort = 0;


Properties props = null;
public static String propertiesFilename = "polargraph.properties.txt";

//public static String bitmapFilename = "monalisa2_l5.png";
//public static String bitmapFilename = "monalisa2_l3+4.png";
//public static String bitmapFilename = "monalisa2_l2.png";
//public static String bitmapFilename = "monalisa2_l1a.png";
//public static String bitmapFilename = "liberty2.jpg";
//public static String bitmapFilename = "earth2_400.jpg";
//public static String bitmapFilename = "mars1_400.jpg";
//public static String bitmapFilename = "moon2_400.jpg";
public static String bitmapFilename = "Marilyn1.jpg";
//public static String bitmapFilename = "portrait_330.jpg";


void setup()
{
  println("Running polargraph controller");
  frame.setResizable(true);
  try 
  { 
    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); 
  } 
  catch (Exception e) 
  { 
    e.printStackTrace();   
  }   
  println("About to load properties.");
  loadFromPropertiesFile();
  println("Loaded properties.  Looking up serial port.");
//  controlP5 = new ControlP5(this);
  // Print a list of the serial ports, for debugging purposes:
  println(Serial.list());
  
  String portName = null;
  try 
  {
    portName = Serial.list()[serialPort];
  }
  catch (ArrayIndexOutOfBoundsException oobe)
  {
    portName = Serial.list()[0];
  }

  myPort = new Serial(this, portName, 57600);
  //read bytes into a buffer until you get a linefeed (ASCII 10):
  myPort.bufferUntil('\n');

  rebuildRows();  
  
  currentMode = MODE_BEGIN;
  
  //commandQueue.add(CMD_CHANGEPENWIDTH+currentPenWidth+",END");

  frame.setSize(machineWidth*2+panelWidth+20, 1020);
  size(windowWidth, windowHeight);
}

Float centreImagePos()
{
  Float imagePosX = (new Float(machineWidth)/2.0) - (new Float(bitmap.width) / 2.0);
  println("imagePosX:"+imagePosX);
  return imagePosX;
}

boolean imageIsLoaded()
{
  if (bitmap == null)
    return false;
  else
    return true;
}


void draw()
{
  switch(getCurrentPage())
  {
    case PAGE_IMAGE: 
      // draw image page
      drawImagePage();
      break;
    case PAGE_PREVIEW:
      // draw preview page
      drawImagePreviewPage();
      break;
    case PAGE_COMMAND_QUEUE:
      // draw command queue
      drawCommandQueuePage();
      break;
    case PAGE_LOAD_IMAGE:
      // draw image loading page
      drawImageLoadPage();
      break;
    case PAGE_DETAILS:
      // draw details page
      drawDetailsPage();
      break;
    default:
      drawDetailsPage();
    break;
  }
  if (isShowingSummaryOverlay())
  {
    drawSummaryOverlay();
  }
  if (isShowingDialogBox())
  {
    drawDialogBox();
  }

  if (drawbotReady)
  {
    dispatchCommandQueue();
  }
  
}

Integer getCurrentPage()
{
  return this.currentPage;
}

boolean isShowingSummaryOverlay()
{
  return this.showingSummaryOverlay;
}
void drawSummaryOverlay()
{
}
boolean isShowingDialogBox()
{
  return false;
}
void drawDialogBox()
{
  
}


void drawImagePage()
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
  
  drawMoveImageOutline();
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
  
  showPanel();
  
  showGroupBox();

  showCurrentMachinePosition();
  
  fill(255);
  stroke(255);
  textSize(25);
  text("INPUT", 30, 30);
  
  fill(0);
  textSize(20);
  text("DENSITY PREVIEW (F2)   DETAILS (F3)   COMMAND QUEUE (F4)", 115, 30);
  
  if (displayingInfoTextOnInputPage)
    showText(30,45);
  showCommandQueue(panelPositionX+panelWidth+5, 20);
}  

void drawImagePreviewPage()
{
  cursor(ARROW);
  
  strokeWeight(1);
  background(100);
  noFill();
//  showPictureFrame();
  drawMoveImageOutline();
  
  stroke(150);
  showPanel();
  showPreviewMachine();
  
//  showCurrentMachinePosition();

  fill(0);
  textSize(20);
  text("INPUT (F1)", 30, 30);

  fill(255);
  stroke(255);
  textSize(25);
  text("DENSITY PREVIEW", 130, 30);
  
  fill(0);
  textSize(20);
  text("DETAILS (F3)   COMMAND QUEUE (F4)", 355, 30);

  if (displayingInfoTextOnInputPage)
    showText(30,45);
  showCommandQueue(panelPositionX+panelWidth+5, 20);

}

void drawDetailsPage()
{
  cursor(ARROW);
  // machine outline
  fill(100);
  stroke(150);
  rect(0, 0, machineWidth, machineHeight); // machine
  rect(pagePositionX, pagePositionY, pageWidth, pageHeight); // page
  noStroke();

  showPanel();

  fill(0);
  textSize(20);
  text("INPUT (F1)   DENSITY PREVIEW (F2)", 30, 30);

  fill(255);
  stroke(255);
  textSize(25);
  text("DETAILS", 365, 30);
  
  fill(0);
  textSize(20);
  text("COMMAND QUEUE (F4)", 470, 30);

  showText(30,45);
  fill(100);
  noStroke();
  rect(panelPositionX+panelWidth+5, 0, width, height);
  showCommandQueue(panelPositionX+panelWidth+5, 20);

}


void drawCommandQueuePage()
{
  cursor(ARROW);

  // machine outline
  fill(100);
  rect(0, 0, machineWidth, machineHeight); // machine
  showingSummaryOverlay = false;
  showPanel();
  
  fill(0);
  textSize(20);
  text("INPUT (F1)   DENSITY PREVIEW (F2)  DETAILS (F3)", 30, 30);

  fill(255);
  stroke(255);
  textSize(25);
  text("COMMAND QUEUE", 494, 30);

  fill(100);
  noStroke();
  rect(panelPositionX+panelWidth+5, 0, width, height);
  
  showCommandQueue(40, 60);
}

void drawImageLoadPage()
{
  drawImagePage();
}

void drawMoveImageOutline()
{
  if (MODE_MOVE_IMAGE == currentMode)
  {
    Float imgX = mouseX - (new Float(bitmap.width)/2);
    Float imgY = mouseY - (new Float(bitmap.height)/2);
    fill(200,200,0,50);
    rect(imgX, imgY, bitmap.width, bitmap.height);
    
    noFill();
//    imageOffset.x = imgX;
//    imageOffset.y = imgY;
  }
}

void showPictureFrame()
{
  stroke (255, 255, 0);
  ellipse(pictureFrameOffset.x, pictureFrameOffset.y, 10, 10);

  stroke (255, 128, 0);
  ellipse(pictureFrameOffset.x + pictureFrameSize.x, pictureFrameOffset.y, 10, 10);

  stroke (255, 0, 255);
  ellipse(pictureFrameOffset.x + pictureFrameSize.x, pictureFrameOffset.y+pictureFrameSize.y, 10, 10);

  stroke (255, 0, 128);
  ellipse(pictureFrameOffset.x, pictureFrameOffset.y+pictureFrameSize.y, 10, 10);

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
    noFill();
    stroke(255,0,0);
    rect(boxVector1.x, boxVector1.y, boxVector2.x-boxVector1.x, boxVector2.y-boxVector1.y);
  }
}

void showPanel()
{
  stroke(150);
  fill(100);
  rect(panelPositionX, panelPositionY, panelWidth, panelHeight);
  noFill();
  
  Map<Integer, Integer> panelButtons = panels.get(getCurrentPage());
  for (int i = 0; i < noOfButtons; i++)
  {
    if (panelButtons.containsKey(i))
    {
      Integer mode = panelButtons.get(i);
      if (currentMode == mode)
        stroke(255);
      else
        stroke(150);
      noFill();
      rect(panelPositionX+2, panelPositionY+(i*buttonHeight)+2, panelWidth-4,  buttonHeight-4);
      stroke(255);
      fill(255);
      text(buttonLabels.get(mode), panelPositionX+6, panelPositionY+(i*buttonHeight)+20);
    }
    noFill();
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
  stroke(150);
  rect(0, 0, machineWidth, machineHeight); // machine
  fill(pageColour);
  rect(pagePositionX, pagePositionY, pageWidth, pageHeight); // page
  noStroke();
  
  showShadedCentres(new PVector(0, 0));
  
}

void showMask()
{
  noStroke();

  fill(100,100,100,150);
  rect(0, 0, width, pagePositionY); // top box
  rect(0, pagePositionY, pagePositionX, pageHeight); // left box
  rect(pagePositionX+pageWidth, pagePositionY, width, pageHeight); // right box
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

void loadImageWithFileChooser()
{


  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() {
      JFileChooser fc = new JFileChooser();
      
      fc.setDialogTitle("Choose a file...");

      int returned = fc.showOpenDialog(frame);
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        // see if it's an image
        if (isAcceptableImageFormat(file))
        {
          PImage img = loadImage(file.getPath());
          if (img != null) 
          {
            bitmapFilename = file.getPath();
            bitmap = loadImage(bitmapFilename);
            img = null;
          }
        }
        else 
        {
          println("Not acceptable file format (" + file.getPath() + ")");
        }
      }
    }
  });
}

boolean isAcceptableImageFormat(File file)
{
  String filename = file.getName();
  if (filename.endsWith ("jpg") || filename.endsWith ("jpeg") || filename.endsWith ("png"))
    return true;
  else
    return false;
}

void setPictureFrameDimensionsToBox()
{
  this.pictureFrameOffset = this.boxVector1;
  this.pictureFrameSize = PVector.sub(this.boxVector2, this.boxVector1);
  this.rowsVector1 = null;
  this.rowsVector2 = null;
}
void setBoxToPictureframeDimensions()
{
  this.boxVector1 = pictureFrameOffset;
  PVector botRight = PVector.add(pictureFrameOffset, pictureFrameSize);
  this.boxVector2 = botRight;
  this.rowsVector1 = null;
  this.rowsVector2 = null;
  extractRowsFromBox();
}


boolean mouseOverMachine()
{
  boolean result = false;
  if (isMachineClickable())
  {
    if (mouseX > machineWidth 
      || mouseY > machineHeight)
      result = false;
    else
      result = true;
  }
  return result;
}
boolean isMachineClickable()
{
  switch(getCurrentPage())
  {
    case PAGE_IMAGE:
      return true;
    case PAGE_PREVIEW:
      return true;
    case PAGE_COMMAND_QUEUE:
      return false;
    case PAGE_LOAD_IMAGE:
      return true;
    case PAGE_DETAILS:
      return true;
    default:
      return true;
  }
}
boolean isPanelClickable()
{
  return true;
}
boolean isQueueClickable()
{
  return true;
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
  
  if (getCurrentPanel().containsKey(overButton))
    return getCurrentPanel().get(overButton);
  else  
    return null;
}

Map<Integer, Integer> getCurrentPanel()
{
  return panels.get(getCurrentPage());
}


void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == java.awt.event.KeyEvent.VK_F1)
    {
      currentPage = PAGE_IMAGE;
    }
    else if (keyCode == java.awt.event.KeyEvent.VK_F2)
    {
      currentPage = PAGE_PREVIEW;
    }
    else if (keyCode == java.awt.event.KeyEvent.VK_F3)
    {
      currentPage = PAGE_DETAILS;
    }
    else if (keyCode == java.awt.event.KeyEvent.VK_F4)
    {
      currentPage = PAGE_COMMAND_QUEUE;
    }
  }
  else if (key == 'g' || key == 'G')
    displayingRowGridlines = (displayingRowGridlines) ? false : true;
  else if (key == 'p' || key == 'P')
    displayingShadedCentres = (displayingShadedCentres) ? false : true;
  else if (key == 's' || key == 'S')
    displayingSelectedCentres = (displayingSelectedCentres) ? false : true;
  else if (key == 'i' || key == 'I')
    displayingInfoTextOnInputPage = (displayingInfoTextOnInputPage) ? false : true;
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
    currentPenWidth = currentPenWidth+penIncrement;
    currentPenWidth =  Math.round(currentPenWidth*100.0)/100.0;
    DecimalFormat df = new DecimalFormat("###.##");
    realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
  }
  else if (key == '[')
  {
    currentPenWidth = currentPenWidth-penIncrement;
    currentPenWidth =  Math.round(currentPenWidth*100.0)/100.0;
    DecimalFormat df = new DecimalFormat("###.##");
    realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
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
    println("queue clicked.");
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
    case MODE_MOVE_IMAGE:
      imageOffset.x = mouseX - (new Float(bitmap.width)/2);
      imageOffset.y = mouseY - (new Float(bitmap.height)/2);
      extractRowsFromBox();
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
      resetQueue();
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
    case MODE_INC_SAMPLE_AREA:
      sampleArea+=1;
      rebuildRows();
      extractRowsFromBox();
      extractRows();
      currentMode = lastMode;
      break;
    case MODE_DEC_SAMPLE_AREA:
      if (sampleArea < 2)
        sampleArea = inMM(rowWidth/2);
      else
        sampleArea-=1;
        
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
    case MODE_SAVE_PROPERTIES:
      savePropertiesFile();
      // clear old properties.
      props = null;
      loadFromPropertiesFile();
      break;
    case LOAD_IMAGE:
      loadImageWithFileChooser();
      println("Loaded image: " + bitmapFilename);
      break;
    case MODE_CONVERT_BOX_TO_PICTUREFRAME:
      setPictureFrameDimensionsToBox();
      break;
    case MODE_SELECT_PICTUREFRAME:
      setBoxToPictureframeDimensions();
      break;
    case MODE_EXPORT_QUEUE:
      exportQueueToFile();
      break;
    case MODE_IMPORT_QUEUE:
      importQueueFromFile();
      break;
    default:
      break;
  }
}

void exportQueueToFile()
{
  if (!commandQueue.isEmpty())
  {
    String savePath = selectOutput();  // Opens file chooser
    if (savePath == null) 
    {
      // If a file was not selected
      println("No output file was selected...");
    } 
    else 
    {
      // If a file was selected, print path to folder
      println("Output file: " + savePath);
      String[] rtList = (String[]) realtimeCommandQueue.toArray(new String[0]);
      saveStrings(savePath, rtList);
      String[] list = (String[]) commandQueue.toArray(new String[0]);
      saveStrings(savePath, list);
      println("Completed queue export, " + list.length + " commands exported.");
    }  
  }
}
void importQueueFromFile()
{
  commandQueue.clear();
  String loadPath = selectInput();
  if (loadPath == null)
  {
    // nothing selected
    println("No input file was selected.");
  }
  else
  {
    println("Input file: " + loadPath);
    String commands[] = loadStrings(loadPath);
//    List<String> list = Arrays
    commandQueue.addAll(Arrays.asList(commands));
    println("Completed queue import, " + commandQueue.size() + " commands found.");
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
  else if (rowClicked > 2 && rowClicked < commandQueue.size()+3) // it's a command from the queue
  {
    int cmdNumber = rowClicked-3;
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
  String command = CMD_CHANGEMACHINESIZE+","+machineWidth+","+machineHeight+",END";
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
  DecimalFormat df = new DecimalFormat("##0.##");
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
  String changeDir = CMD_CHANGEDRAWINGDIRECTION+"A," + drawDirection +",END";
  commandQueue.add(changeDir);

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
  String command = CMD_CHANGELENGTH+inSteps(coords.x)+","+inSteps(coords.y)+",END";
  commandQueue.add(command);

  coords = getNativeCoords(boxVector2.x, boxVector1.y);
  command = CMD_CHANGELENGTH+inSteps(coords.x)+","+inSteps(coords.y)+",END";
  commandQueue.add(command);

  coords = getNativeCoords(boxVector2);
  command = CMD_CHANGELENGTH+inSteps(coords.x)+","+inSteps(coords.y)+",END";
  commandQueue.add(command);

  coords = getNativeCoords(boxVector1.x, boxVector2.y);
  command = CMD_CHANGELENGTH+inSteps(coords.x)+","+inSteps(coords.y)+",END";
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
            int density = getDensity(centreScr, sampleArea);
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

void resetQueue()
{
  currentMode = MODE_BEGIN;
  commandQueue.clear();
  realtimeCommandQueue.clear();
}

void showText(int xPosOrigin, int yPosOrigin)
{
  noStroke();
  fill(0, 0, 0, 80);
  rect(xPosOrigin-4, yPosOrigin-4, xPosOrigin+250, yPosOrigin+350);
  
  
  textSize(12);
  fill(255);
  int tRow = 15;
  int textPositionX = xPosOrigin;
  int textPositionY = yPosOrigin;
  
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
//  textPositionX = textPositionX+200;
//  textPositionY = yPosOrigin;
//  tRowNo = 1;
  
  text("Row size: " + rowWidth, textPositionX, textPositionY+(tRow*tRowNo++));
//  text("Row segments mach: " + rowSegmentsForMachine.length, textPositionX, textPositionY+(tRow*tRowNo++));
//  text("Row segments scr: " + rowSegmentsForScreen.length, textPositionX, textPositionY+(tRow*tRowNo++));
  
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
//  text("RowsVector1: " + rowsVector1, textPositionX, textPositionY+(tRow*tRowNo++));
//  text("RowsVector2: " + rowsVector2, textPositionX, textPositionY+(tRow*tRowNo++));

  text("Pixel sample area: " + sampleArea, textPositionX, textPositionY+(tRow*tRowNo++));

}

void showCommandQueue(int xPos, int yPos)
{
  textSize(12);
  fill(255);
  int tRow = 15;
  int textPositionX = xPos;
  int textPositionY = yPos;
  int tRowNo = 1;

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
    return "RUNNING - click to pause";
  else
    return "PAUSED - click to start";
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

Map<Integer, Map<Integer, Integer>> buildPanels()
{
  Map<Integer, Map<Integer, Integer>> panelMap = new HashMap<Integer, Map<Integer, Integer>>(5);
  
  Map<Integer, Integer> inputPanel = new HashMap<Integer, Integer>(30);
  inputPanel.put(0, MODE_BEGIN);
  inputPanel.put(1, MODE_SET_POSITION_HOME);
  inputPanel.put(2, MODE_SET_POSITION);
  inputPanel.put(3, MODE_DRAW_TO_POSITION);
  
  inputPanel.put(4, MODE_INPUT_BOX_TOP_LEFT);
  inputPanel.put(5, MODE_INPUT_BOX_BOT_RIGHT);

  inputPanel.put(6, MODE_CONVERT_BOX_TO_PICTUREFRAME);
  inputPanel.put(7, MODE_SELECT_PICTUREFRAME);

  inputPanel.put(8, MODE_DRAW_OUTLINE_BOX);
//  inputPanel.put(9, MODE_DRAW_OUTLINE_BOX_ROWS);
//  inputPanel.put(10, MODE_DRAW_SHADE_BOX_ROWS_PIXELS);

  inputPanel.put(10, LOAD_IMAGE);
  inputPanel.put(11, MODE_MOVE_IMAGE);
  inputPanel.put(12, MODE_RENDER_SQUARE_PIXELS);
  inputPanel.put(13, MODE_RENDER_SCALED_SQUARE_PIXELS);
  inputPanel.put(14, MODE_RENDER_SOLID_SQUARE_PIXELS);
  inputPanel.put(15, MODE_RENDER_SCRIBBLE_PIXELS);

  inputPanel.put(16, MODE_DRAW_TEST_PENWIDTH);

  inputPanel.put(18, INS_INC_ROWSIZE);
  inputPanel.put(19, INS_DEC_ROWSIZE);

//  inputPanel.put(20, MODE_LOAD_SD_IMAGE);
//  inputPanel.put(21, MODE_START_ROVING);
//  inputPanel.put(22, MODE_STOP_ROVING);
//  inputPanel.put(23, MODE_SET_ROVE_AREA);
//  inputPanel.put(24, MODE_CHANGE_MACHINE_SIZE);
//  inputPanel.put(25, MODE_CHANGE_MACHINE_NAME);
//  inputPanel.put(26, MODE_REQUEST_MACHINE_SIZE);
//  inputPanel.put(27, MODE_RESET_MACHINE);
//  inputPanel.put(28, MODE_SAVE_PROPERTIES);
  panelMap.put(PAGE_IMAGE, inputPanel);

  Map<Integer, Integer> previewPanel = new HashMap<Integer, Integer>(30);
  previewPanel.put(0, MODE_BEGIN);
  previewPanel.put(1, MODE_SET_POSITION_HOME);
  previewPanel.put(2, MODE_SET_POSITION);
  previewPanel.put(3, MODE_DRAW_TO_POSITION);
  previewPanel.put(4, MODE_INPUT_BOX_TOP_LEFT);
  previewPanel.put(5, MODE_INPUT_BOX_BOT_RIGHT);
  previewPanel.put(8, MODE_DRAW_OUTLINE_BOX);
  previewPanel.put(9, MODE_INC_SAMPLE_AREA);
  previewPanel.put(10, MODE_DEC_SAMPLE_AREA);
  previewPanel.put(11, MODE_MOVE_IMAGE);
  previewPanel.put(12, MODE_RENDER_SQUARE_PIXELS);
  previewPanel.put(13, MODE_RENDER_SCALED_SQUARE_PIXELS);
  previewPanel.put(14, MODE_RENDER_SOLID_SQUARE_PIXELS);
  previewPanel.put(15, MODE_RENDER_SCRIBBLE_PIXELS);
  previewPanel.put(16, MODE_DRAW_TEST_PENWIDTH);
  previewPanel.put(18, INS_INC_ROWSIZE);
  previewPanel.put(19, INS_DEC_ROWSIZE);

  panelMap.put(PAGE_PREVIEW, previewPanel);
  
  ////   
  Map<Integer, Integer> detailsPanel = new HashMap<Integer, Integer>(30);
//  detailsPanel.put(0, MODE_BEGIN);
//  detailsPanel.put(1, MODE_SET_POSITION_HOME);
//  detailsPanel.put(2, MODE_SET_POSITION);
//  detailsPanel.put(3, MODE_DRAW_TO_POSITION);
//  
//  detailsPanel.put(4, MODE_INPUT_BOX_TOP_LEFT);
//  detailsPanel.put(5, MODE_INPUT_BOX_BOT_RIGHT);
//
//  detailsPanel.put(6, MODE_DRAW_TEST_PENWIDTH);
//  detailsPanel.put(7, MODE_INPUT_SINGLE_PIXEL);
//
//  detailsPanel.put(8, INS_INC_ROWSIZE);
//  detailsPanel.put(9, INS_DEC_ROWSIZE);

//  detailsPanel.put(10, MODE_LOAD_SD_IMAGE);
//  detailsPanel.put(11, MODE_START_ROVING);
//  detailsPanel.put(12, MODE_STOP_ROVING);
//  detailsPanel.put(13, MODE_SET_ROVE_AREA);
  detailsPanel.put(14, MODE_CHANGE_MACHINE_SIZE);
//  detailsPanel.put(15, MODE_CHANGE_MACHINE_NAME);
  detailsPanel.put(16, MODE_REQUEST_MACHINE_SIZE);
  detailsPanel.put(17, MODE_RESET_MACHINE);
  detailsPanel.put(18, MODE_SAVE_PROPERTIES);
  
  panelMap.put(PAGE_DETAILS, detailsPanel);

  Map<Integer, Integer> queuePanel = new HashMap<Integer, Integer>(30);
  queuePanel.put(0, MODE_BEGIN);
  queuePanel.put(6, MODE_EXPORT_QUEUE);
  queuePanel.put(7, MODE_IMPORT_QUEUE);
  
  panelMap.put(PAGE_COMMAND_QUEUE, queuePanel);
  
  return panelMap;
}

Map<Integer, String> buildButtonLabels()
{
  Map<Integer, String> result = new HashMap<Integer, String>(19);
  
  result.put(MODE_BEGIN, "Reset queue");
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
  result.put(MODE_RENDER_SCRIBBLE_PIXELS, "Shade Scribble");

  result.put(MODE_LOAD_SD_IMAGE, "upload image (SD)");
  result.put(MODE_START_ROVING, "start rove");
  result.put(MODE_STOP_ROVING, "stop rove");
  result.put(MODE_SET_ROVE_AREA, "set rove area");
  result.put(MODE_CREATE_MACHINE_TEXT_BITMAP, "render as text");
  
  result.put(MODE_CHANGE_MACHINE_SIZE, "Upload size");
  result.put(MODE_CHANGE_MACHINE_NAME, "Upload name");
  result.put(MODE_REQUEST_MACHINE_SIZE, "Download size");
  result.put(MODE_RESET_MACHINE, "Reset machine");
  result.put(MODE_SAVE_PROPERTIES, "Save properties");
  
  result.put(MODE_INC_SAMPLE_AREA, "Inc sample size");
  result.put(MODE_DEC_SAMPLE_AREA, "Dec sample size");

  result.put(MODE_MOVE_IMAGE, "Place image");
  result.put(MODE_CONVERT_BOX_TO_PICTUREFRAME, "Save selection");
  result.put(MODE_SELECT_PICTUREFRAME, "Select frame");
  
  result.put(MODE_EXPORT_QUEUE, "Export queue");
  result.put(MODE_IMPORT_QUEUE, "Import queue");

  return result;
}

Properties getProperties()
{
  if (props == null)
  {
    FileInputStream propertiesFileStream = null;
    try
    {
      props = new Properties();
      String fileToLoad = sketchPath(propertiesFilename);
      
      File propertiesFile = new File(fileToLoad);
      if (!propertiesFile.exists())
        savePropertiesFile();
      
      propertiesFileStream = new FileInputStream(propertiesFile);
      props.load(propertiesFileStream);
      println("Successfully loaded properties file " + fileToLoad);
    }
    catch (IOException e)
    {
      println("Couldn't read the properties file - will attempt to create one.");
      println(e.getMessage());
    }
    finally
    {
      try { propertiesFileStream.close();}
      catch (Exception e) {};
    }
  }
  return props;
}

void loadFromPropertiesFile()
{
  this.machineWidth = getIntProperty("machine.width", 600);
  // machine.height
  this.machineHeight = getIntProperty("machine.height", 800);
  // pen size
  this.currentPenWidth = getFloatProperty("machine.pen.size", 1.0);
  // serial port
  this.serialPort = getIntProperty("controller.machine.serialport", 0);

  // row size
  this.rowWidth = getIntProperty("controller.row.size", 100);
  this.sampleArea = getIntProperty("controller.pixel.samplearea", 2);
  // initial screen size
  this.windowWidth = getIntProperty("controller.window.width", 800);
  this.windowHeight = getIntProperty("controller.window.height", 550);
  // image filename
  this.bitmapFilename = getStringProperty("controller.image.filename", "portrait_330.jpg");
  
  bitmap = loadImage(bitmapFilename);
  
  
  // image position
  Float offsetX = getFloatProperty("controller.image.position.x", 0.0);
  Float offsetY = getFloatProperty("controller.image.position.y", 0.0);
  this.imageOffset = new PVector(offsetX, offsetY);

  // page size
  this.pageWidth = getIntProperty("controller.page.width", A3_WIDTH);
  this.pageHeight = getIntProperty("controller.page.height", A3_HEIGHT);
  
  // page position
  this.pagePositionX = getIntProperty("controller.page.position.x", 100);
  this.pagePositionY = getIntProperty("controller.page.position.y", 120);

  // picture frame size
  Float pfsx = getFloatProperty("controller.pictureframe.width", 200.0);
  Float pfsy = getFloatProperty("controller.pictureframe.height", 200.0);
  this.pictureFrameSize = new PVector(pfsx, pfsy);
  
  // picture frame position
  Float pftlx = getFloatProperty("controller.pictureframe.position.x", 200.0);
  Float pftly = getFloatProperty("controller.pictureframe.position.y", 200.0);
  this.pictureFrameOffset = new PVector(pftlx, pftly);
  
  this.stepsPerRev = getFloatProperty("machine.motors.stepsPerRev", 800.0);
  this.mmPerRev = getFloatProperty("machine.motors.mmPerRev", 84);
  this.mmPerStep = mmPerRev / stepsPerRev;
  this.stepsPerMM = stepsPerRev / mmPerRev;  
  
  this.testPenWidthStartSize = getFloatProperty("controller.testPenWidth.startSize", 0.5);
  this.testPenWidthEndSize = getFloatProperty("controller.testPenWidth.endSize", 2.0);
  this.testPenWidthIncrementSize = getFloatProperty("controller.testPenWidth.incrementSize", 0.5);
  
  
  println("Finished loading configuration from properties file.");
}

void savePropertiesFile()
{
  Properties props = new Properties();
  
  // Put keys into properties file:
  // machine width
  props.setProperty("machine.width", new Integer(machineWidth).toString());
  // machine.height
  props.setProperty("machine.height", new Integer(machineHeight).toString());
  // pen size
  props.setProperty("machine.pen.size", new Float(currentPenWidth).toString());
  // serial port
  props.setProperty("controller.machine.serialport", new Integer(serialPort).toString());

  // row size
  props.setProperty("controller.row.size", new Integer(rowWidth).toString());
  props.setProperty("controller.pixel.samplearea", new Integer(sampleArea).toString());
  // initial screen size
  props.setProperty("controller.window.width", new Integer(width).toString());
  props.setProperty("controller.window.height", new Integer(height).toString());
  // image filename
  props.setProperty("controller.image.filename", bitmapFilename);
  // image position
  props.setProperty("controller.image.position.x", new Float(imageOffset.x).toString());
  props.setProperty("controller.image.position.y", new Float(imageOffset.y).toString());

  // page size
  props.setProperty("controller.page.width", new Integer(pageWidth).toString());
  props.setProperty("controller.page.height", new Integer(pageHeight).toString());
  
  // page position
  props.setProperty("controller.page.position.x", new Integer(pagePositionX).toString());
  props.setProperty("controller.page.position.y", new Integer(pagePositionY).toString());

  // picture frame size
  props.setProperty("controller.pictureframe.width", new Float(pictureFrameSize.x).toString());
  props.setProperty("controller.pictureframe.height", new Float(pictureFrameSize.y).toString());
  // picture frame position
  props.setProperty("controller.pictureframe.position.x", new Float(pictureFrameOffset.x).toString());
  props.setProperty("controller.pictureframe.position.y", new Float(pictureFrameOffset.y).toString());
  props.setProperty("controller.machine.serialport", serialPort.toString());
  
  props.setProperty("machine.motors.stepsPerRev", new Float(stepsPerRev).toString());
  props.setProperty("machine.motors.mmPerRev", new Float(mmPerRev).toString());
  
  props.setProperty("controller.testPenWidth.startSize", new Float(testPenWidthStartSize).toString());
  props.setProperty("controller.testPenWidth.endSize", new Float(testPenWidthEndSize).toString());
  props.setProperty("controller.testPenWidth.incrementSize", new Float(testPenWidthIncrementSize).toString());
  
  
 
  FileOutputStream propertiesOutput = null;

  try
  {
    //save the properties to a file
    File propertiesFile = new File(sketchPath(propertiesFilename));
    if (propertiesFile.exists())
    {
      propertiesOutput = new FileOutputStream(propertiesFile);
      Properties oldProps = new Properties();
      FileInputStream propertiesFileStream = new FileInputStream(propertiesFile);
      oldProps.load(propertiesFileStream);
      oldProps.putAll(props);
      oldProps.store(propertiesOutput,"   ***  Polargraph properties file   ***  ");
      println("Saved settings.");
    }
    else
    { // create it
      propertiesFile.createNewFile();
      propertiesOutput = new FileOutputStream(propertiesFile);
      props.store(propertiesOutput,"   ***  Polargraph properties file   ***  ");
      println("Created file.");
    }
  }
  catch (Exception e)
  {
    println("Exception occurred while creating new properties file: " + e.getMessage());
  }
  finally
  {
    if (propertiesOutput != null)
    {
      try
      {
        propertiesOutput.close();
      }
      catch (Exception e2) {}
    }
  }
}

boolean getBooleanProperty(String id, boolean defState) 
{
  return boolean(getProperties().getProperty(id,""+defState));
}
 
int getIntProperty(String id, int defVal) 
{
  return int(getProperties().getProperty(id,""+defVal)); 
}
 
float getFloatProperty(String id, float defVal) 
{
  return float(getProperties().getProperty(id,""+defVal)); 
}
String getStringProperty(String id, String defVal)
{
  return getProperties().getProperty(id, defVal);
}
  
void initProperties()
{
  getProperties();
}

