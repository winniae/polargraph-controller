/**
  Polargraph controller - written by Sandy Noble
  
  A lot of this is about the interface.
  
  
*/
import javax.swing.*;
import processing.serial.*;
import controlP5.*;
import java.awt.event.*;

ControlP5 cp5;

boolean drawbotReady = false;
boolean drawbotConnected = false;

final int MACHINE_SRAM = 2048;

Machine machine = new Machine(712, 980, 800.0, 95.0);
String newMachineName = "PGXXABCD";
PVector machinePosition = new PVector(130.0, 50.0);
float machineScaling = 1.0;
DisplayMachine displayMachine = null;

int homeALengthMM = 400;
int homeBLengthMM = 400;

final int A3_WIDTH = 297;
final int A3_HEIGHT = 420;

final int A2_WIDTH = 418;
final int A2_HEIGHT = 594;

final int A2_IMP_WIDTH = 450;
final int A2_IMP_HEIGHT = 640;

final int A1_WIDTH = 594;
final int A1_HEIGHT = 841;

int leftEdgeOfQueue = 800;
int rightEdgeOfQueue = 1100;
int topEdgeOfQueue = 0;
int bottomEdgeOfQueue = 0;
int queueRowHeight = 15;


Serial myPort;                       // The serial port
int[] serialInArray = new int[1];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive

final JFileChooser chooser = new JFileChooser();

SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy hh:mm:ss");

String commandStatus = "Waiting for a click.";

int sampleArea = 10;
float gridSize = 75.0;
float currentPenWidth = 1.2;
float penIncrement = 0.05;

float currentMachineMaxSpeed = 600.0;
float currentMachineAccel = 400.0;
float MACHINE_ACCEL_INCREMENT = 25.0;
float MACHINE_MAXSPEED_INCREMENT = 25.0;

List<String> commandQueue = new ArrayList<String>();
List<String> realtimeCommandQueue = new ArrayList<String>();
List<String> commandHistory = new ArrayList<String>();

String lastCommand = "";
String lastDrawingCommand = "";
Boolean commandQueueRunning = false;
static final int DRAW_DIR_NE = 1;
static final int DRAW_DIR_SE = 2;
static final int DRAW_DIR_SW = 3;
static final int DRAW_DIR_NW = 4;
static final int DRAW_DIR_N = 5;
static final int DRAW_DIR_E = 6;
static final int DRAW_DIR_S = 7;
static final int DRAW_DIR_W = 8;
static int drawDirection = DRAW_DIR_SE;

static final int DRAW_DIR_MODE_AUTO = 1;
static final int DRAW_DIR_MODE_PRESET = 2;
static final int DRAW_DIR_MODE_RANDOM = 3;
static int pixelDirectionMode = DRAW_DIR_MODE_PRESET;


PVector currentMachinePos = new PVector();
PVector currentCartesianMachinePos = new PVector();
int machineAvailMem = 0;
int machineUsedMem = 0;
int machineMinAvailMem = 2048;


//String testPenWidthCommand = "TESTPENWIDTHSCRIBBLE,";
String testPenWidthCommand = CMD_TESTPENWIDTHSQUARE;
float testPenWidthStartSize = 0.5;
float testPenWidthEndSize = 2.0;
float testPenWidthIncrementSize = 0.5;

int maxSegmentLength = 20;

static final String MODE_BEGIN = "button_mode_begin";
static final String MODE_INPUT_BOX_TOP_LEFT = "button_mode_inputBoxTopLeft";
static final String MODE_INPUT_BOX_BOT_RIGHT = "button_mode_inputBoxBotRight";
static final String MODE_DRAW_OUTLINE_BOX = "button_mode_drawOutlineBox";
static final String MODE_DRAW_OUTLINE_BOX_ROWS = "button_mode_drawOutlineBoxRows";
static final String MODE_DRAW_SHADE_BOX_ROWS_PIXELS = "button_mode_drawShadeBoxRowsPixels";
static final String MODE_DRAW_TO_POSITION = "button_mode_drawToPosition";
static final String MODE_RENDER_SQUARE_PIXELS = "button_mode_renderSquarePixel";
static final String MODE_RENDER_SAW_PIXELS = "button_mode_renderSawPixel";
static final String MODE_RENDER_CIRCLE_PIXELS = "button_mode_renderCirclePixel";
static final String MODE_INPUT_ROW_START = "button_mode_inputRowStart";
static final String MODE_INPUT_ROW_END = "button_mode_inputRowEnd";
static final String MODE_SET_POSITION = "button_mode_setPosition";
static final String MODE_DRAW_TESTPATTERN = "button_mode_drawTestPattern";
static final String MODE_INC_ROW_SIZE = "button_mode_incRowSize";
static final String MODE_DEC_ROW_SIZE = "button_mode_decRowSize";
static final String MODE_DRAW_GRID = "button_mode_drawGrid";
static final String MODE_PLACE_IMAGE = "button_mode_placeImage";
static final String MODE_LOAD_IMAGE = "button_mode_loadImage";
static final String MODE_PAUSE_QUEUE = "button_mode_pauseQueue";
static final String MODE_RUN_QUEUE = "button_mode_runQueue";
static final String MODE_SET_POSITION_HOME = "button_mode_setPositionHome";
static final String MODE_INPUT_SINGLE_PIXEL = "button_mode_inputSinglePixel";
static final String MODE_DRAW_TEST_PENWIDTH = "button_mode_drawTestPenWidth";
static final String MODE_RENDER_SCALED_SQUARE_PIXELS = "button_mode_renderScaledSquarePixels";
static final String MODE_RENDER_SOLID_SQUARE_PIXELS = "button_mode_renderSolidSquarePixels";
static final String MODE_RENDER_SCRIBBLE_PIXELS = "button_mode_renderScribblePixels";
static final String MODE_CHANGE_MACHINE_SPEC = "button_mode_changeMachineSpec";
static final String MODE_REQUEST_MACHINE_SIZE = "button_mode_requestMachineSize";
static final String MODE_RESET_MACHINE = "button_mode_resetMachine";
static final String MODE_SAVE_PROPERTIES = "button_mode_saveProperties";
static final String MODE_INC_SAMPLE_AREA = "button_mode_incSampleArea";
static final String MODE_DEC_SAMPLE_AREA = "button_mode_decSampleArea";
static final String MODE_MOVE_IMAGE = "button_mode_moveImage";
static final String MODE_INPUT_IMAGE = "button_mode_inputImage";
static final String MODE_CONVERT_BOX_TO_PICTUREFRAME = "button_mode_convertBoxToPictureframe";
static final String MODE_SELECT_PICTUREFRAME = "button_mode_selectPictureframe";
static final String MODE_EXPORT_QUEUE = "button_mode_exportQueue";
static final String MODE_IMPORT_QUEUE = "button_mode_importQueue";
static final String MODE_CLEAR_QUEUE = "button_mode_clearQueue";
static final String MODE_FIT_IMAGE_TO_BOX = "button_mode_fitImageToBox";
static final String MODE_DRAW_DIRECT = "button_mode_drawDirect";
static final String MODE_RENDER_COMMAND_QUEUE = "button_mode_renderCommandQueue";

static String currentMode = MODE_BEGIN;
static String lastMode = MODE_BEGIN;

static PVector boxVector1 = null;
static PVector boxVector2 = null;

static PVector rowsVector1 = null;
static PVector rowsVector2 = null;

int numberOfPixelsTotal = 0;
int numberOfPixelsCompleted = 0;

Date timerStart = null;
Date timeLastPixelStarted = null;

boolean pixelTimerRunning = false;
boolean displayingSelectedCentres = true;
boolean displayingShadedCentres = false;
boolean displayingRowGridlines = false;
boolean displayingInfoTextOnInputPage = false;

boolean useSerialPortConnection = false;

static final char BITMAP_BACKGROUND_COLOUR = 0x0F;


// used in the preview page
static Integer pageColour = 100;

public boolean showingSummaryOverlay = true;
public boolean showingDialogBox = false;

public Integer windowWidth = 900;
public Integer windowHeight = 550;

public static Integer serialPortNumber = -1;


Properties props = null;
public static String propertiesFilename = "polargraph.properties.txt";

public static final String TAB_NAME_INPUT= "default";
public static final String TAB_LABEL_INPUT = "input";
public static final String TAB_NAME_PREVIEW = "tab_preview";
public static final String TAB_LABEL_PREVIEW = "Preview";
public static final String TAB_NAME_DETAILS = "tab_details";
public static final String TAB_LABEL_DETAILS = "Details";
public static final String TAB_NAME_QUEUE = "tab_queue";
public static final String TAB_LABEL_QUEUE = "Queue";

// Page states
public String currentTab = TAB_NAME_INPUT;


public static final String PANEL_NAME_INPUT = "panel_input";
public static final String PANEL_NAME_PREVIEW = "panel_preview";
public static final String PANEL_NAME_DETAILS = "panel_details";
public static final String PANEL_NAME_QUEUE = "panel_queue";

public static final String PANEL_NAME_GENERAL = "panel_general";

public final PVector DEFAULT_CONTROL_SIZE = new PVector(100.0, 20.0);
public final PVector CONTROL_SPACING = new PVector(2.0, 2.0);
public PVector mainPanelPosition = new PVector(10.0, 55.0);

public final Integer PANEL_MIN_HEIGHT = 400;

public Set<String> panelNames = null;
public List<String> tabNames = null;
public Set<String> controlNames = null;
public Map<String, List<Controller>> controlsForPanels = null;

public Map<String, Controller> allControls = null;
public Map<String, String> controlLabels = null;

public Map<String, Set<Panel>> panelsForTabs = null;
public Map<String, Panel> panels = null;

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
  loadFromPropertiesFile();
  
  this.cp5 = new ControlP5(this);
  initTabs();

  String[] serialPorts = Serial.list();
  println("Serial ports available on your machine:");
  println(serialPorts);

  if (getSerialPortNumber() >= 0)
  {
    println("About to connect to serial port in slot " + getSerialPortNumber());
    // Print a list of the serial ports, for debugging purposes:
    if (serialPorts.length > 0)
    {
      String portName = null;
      try 
      {
        portName = serialPorts[getSerialPortNumber()];
        myPort = new Serial(this, portName, 57600);
        //read bytes into a buffer until you get a linefeed (ASCII 10):
        myPort.bufferUntil('\n');
        useSerialPortConnection = true;
        println("Successfully connected to port " + portName);
      }
      catch (Exception e)
      {
        println("Attempting to connect to serial port " 
        + portName + " in slot " + getSerialPortNumber() 
        + " caused an exception: " + e.getMessage());
      }
    }
    else
    {
      println("No serial ports found.");
      useSerialPortConnection = false;
    }
  }
  else
  {
    useSerialPortConnection = false;
  }

  currentMode = MODE_BEGIN;
  preLoadCommandQueue();
  size(windowWidth, windowHeight);
  changeTab(TAB_NAME_INPUT, TAB_NAME_INPUT);

  addWindowResizeListener();
}
void addWindowResizeListener()
{
  frame.addComponentListener(new ComponentAdapter() 
    {
      public void componentResized(ComponentEvent event) 
      {
        if (event.getSource()==frame) 
        {
  	  windowResized();
        }
      }
    }
  ); 
}  

void preLoadCommandQueue()
{
  commandQueue.add(CMD_CHANGEPENWIDTH+currentPenWidth+",END");
  commandQueue.add(CMD_SETMOTORSPEED+currentMachineMaxSpeed+",END");
  commandQueue.add(CMD_SETMOTORACCEL+currentMachineAccel+",END");
  
}

void windowResized()
{
  for (String key : getPanels().keySet())
  {
    Panel p = getPanels().get(key);
    p.setHeight(frame.getHeight() - p.getOutline().getTop() - (DEFAULT_CONTROL_SIZE.y*2));
  }
  
}
void draw()
{
  if (getCurrentTab() == TAB_NAME_INPUT)
  {
    drawImagePage();
  }
  else if (getCurrentTab() == TAB_NAME_PREVIEW)
  {
    drawImagePreviewPage();
  }
  else if (getCurrentTab() == TAB_NAME_QUEUE)
  {
    drawCommandQueuePage();
  }
  else if (getCurrentTab() == TAB_NAME_DETAILS)
  {
    drawDetailsPage();
  }
  else
  {
    drawDetailsPage();
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

String getCurrentTab()
{
  return this.currentTab;
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



Panel getPanel(String panelName)
{
  return getPanels().get(panelName);
}

void drawImagePage()
{
  strokeWeight(1);
  background(100);
  noFill();
  drawMoveImageOutline();
  stroke(255, 150, 255, 100);
  strokeWeight(3);
  stroke(150);
  noFill();
  getDisplayMachine().draw();
  stroke(255, 0, 0);
  showSelectedCentres(new PVector(0,0));
 
  for (Panel panel : getPanelsForTab(TAB_NAME_INPUT))
  {
    panel.draw();
  }

  showGroupBox();
  showCurrentMachinePosition();
  if (displayingInfoTextOnInputPage)
    showText(250,45);
  drawStatusText(245, 12);

  showCommandQueue((int) getDisplayMachine().getOutline().getRight()+6, 20);
}

void drawMachineOutline()
{
  rect(machinePosition.x,machinePosition.y, machinePosition.x+getMachine().getWidth(), machinePosition.y+getMachine().getHeight());
}
void drawImagePreviewPage()
{
  cursor(ARROW);
  
  strokeWeight(1);
  background(100);
  noFill();
//  showPictureFrame();
  drawMoveImageOutline();
  
  // draw machine outline
//  getDisplayMachine().draw();

  for (Panel panel : getPanelsForTab(TAB_NAME_PREVIEW))
  {
    panel.draw();
  }
  
//  showCurrentMachinePosition();
  if (displayingInfoTextOnInputPage)
    showText(250,45);
  drawStatusText(245, 12);
  showCommandQueue((int) getDisplayMachine().getOutline().getRight()+6, 20);

}

void drawDetailsPage()
{
  background(100);
  cursor(ARROW);
  for (Panel panel : getPanelsForTab(TAB_NAME_DETAILS))
  {
    panel.draw();
  }
  drawStatusText(245, 12);

  int right = 0;
  for (Panel panel : getPanelsForTab(TAB_NAME_DETAILS))
  {
    panel.draw();
    float r = panel.getOutline().getRight();
    if (r > right)
      right = (int) r;
  }
  showCommandQueue(right, (int)mainPanelPosition.y);

}


void drawCommandQueuePage()
{
  cursor(ARROW);
  background(100);

  // machine outline
  fill(100);
  drawMachineOutline();
  showingSummaryOverlay = false;
  
  previewQueue();

  
  int right = 0;
  for (Panel panel : getPanelsForTab(TAB_NAME_QUEUE))
  {
    
    panel.draw();
    float r = panel.getOutline().getRight();
    if (r > right)
      right = (int) r;
  }
  showCommandQueue(right, (int)mainPanelPosition.y);
  
  drawStatusText(245, 12);
  
}

void drawImageLoadPage()
{
  drawImagePage();
}

void drawMoveImageOutline()
{
//  if (MODE_MOVE_IMAGE == currentMode)
//  {
//    Float imgX = mouseX - (new Float(bitmap.width)/2);
//    Float imgY = mouseY - (new Float(bitmap.height)/2);
//    fill(200,200,0,50);
//    rect(imgX, imgY, bitmap.width, bitmap.height);
//    
//    noFill();
////    imageOffset.x = imgX;
////    imageOffset.y = imgY;
//  }
}

void showPictureFrame()
{
  stroke (255, 255, 0);
  ellipse(getMachine().getPictureFrame().getLeft(), getMachine().getPictureFrame().getTop(), 10, 10);

  stroke (255, 128, 0);
  ellipse(getMachine().getPictureFrame().getRight(), getMachine().getPictureFrame().getTop(), 10, 10);

  stroke (255, 0, 255);
  ellipse(getMachine().getPictureFrame().getRight(), getMachine().getPictureFrame().getBottom(), 10, 10);

  stroke (255, 0, 128);
  ellipse(getMachine().getPictureFrame().getLeft(), getMachine().getPictureFrame().getBottom(), 10, 10);
  
  stroke(255);
}

void showCurrentMachinePosition()
{
  noStroke();
  fill(255,0,255,150);
  PVector pgCoord = getMachine().asCartesianCoords(currentMachinePos);
  ellipse(pgCoord.x, pgCoord.y, 20, 20);

  // also show cartesian position if reported
  fill(255,255,0,150);
  ellipse(currentCartesianMachinePos.x, currentCartesianMachinePos.y, 15, 15);

  noFill();
}

void showGroupBox()
{
  if (boxVector1 != null && boxVector2 != null)
  {
    noFill();
    stroke(255,0,0);
    strokeWeight(1);
    PVector topLeft = getDisplayMachine().scaleToScreen(boxVector1);
    PVector botRight = getDisplayMachine().scaleToScreen(boxVector2);
    rect(topLeft.x, topLeft.y, botRight.x-topLeft.x, botRight.y-topLeft.y);
  }
}


void showSelectedCentres(PVector offset)
{
  if (displayingSelectedCentres)
  {
//    int spotSize = 3;
//    if (pixelCentresForScreen != null)
//    {
//      for (List<PVector> row : pixelCentresForScreen)
//      {
//        for (PVector v : row)
//        {
//          ellipse(offset.x+v.x, offset.y+v.y, spotSize, spotSize);
//        }
//      }
//    }
  }
}

void showShadedCentres(PVector offset)
{
  if (displayingShadedCentres)
  {
//    int spotSize = getMachine().inMM(rowWidth);
//    if (pixelCentresForScreen != null)
//    {
//      for (List<PVector> row : pixelCentresForScreen)
//      {
//        for (PVector v : row)
//        {
//          fill(v.z);
//          ellipse(offset.x+v.x, offset.y+v.y, spotSize, spotSize);
//        }
//      }
//    }
  }
  noFill();
}



PVector getCartesian(int lenA, int lenB)
{
  int calcX = int((pow(getMachine().getWidth(), 2) - pow(lenB, 2) + pow(lenA, 2)) / (getMachine().getWidth()*2));
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
  float bLine = dist(x, y, getMachine().getWidth(), 0);
  
  PVector result = new PVector(aLine, bLine);
  return result;
}


int rounded(float lineLength)
{
  return rounded((int) lineLength);
}
int rounded(int lineLength)
{
//  int lowLine = rowSegmentsForMachine[0];
//  int highLine = lowLine;
//  int result = lowLine + (rowWidth / 2);
//  
//  for (int i = 0; i < (rowSegmentsForMachine.length-1); i++)
//  {
//    lowLine = rowSegmentsForMachine[i];
//    highLine = rowSegmentsForMachine[i+1];
//    
//    if (lineLength >= lowLine 
//    && lineLength <= highLine)
//    {
//      result = lowLine + (rowWidth / 2);
//    }
//  }
//  
//  return result;
  return lineLength;
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
            getMachine().setImageFilename(file.getPath());
//            getMachine().setImage(loadImage(bitmapFilename));
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
  if (filename.endsWith ("jpg") || filename.endsWith ("jpeg") || filename.endsWith ("png")
  || filename.endsWith ("JPG") || filename.endsWith ("JPEG") || filename.endsWith ("PNG"))
    return true;
  else
    return false;
}

void setPictureFrameDimensionsToBox()
{
  if (boxVector1 != null && boxVector2 != null)
  {
    getDisplayMachine().setPictureFrame(new Rectangle(this.boxVector1, this.boxVector2));
    this.rowsVector1 = null;
    this.rowsVector2 = null;
  }
}
void setBoxToPictureframeDimensions()
{
  this.boxVector1 = getDisplayMachine().getPictureFrame().getTopLeft();
  this.boxVector2 = getDisplayMachine().getPictureFrame().getBotRight();
  if (isBoxSpecified())
    getDisplayMachine().getPixelsPositionsFromArea(getBoxVector1(), getBoxVector2(), getGridSize());
}

float getGridSize()
{
  return this.gridSize;
}

void controlEvent(ControlEvent controlEvent) 
{
  if (controlEvent.isTab()) 
  {
    if (controlEvent.tab().name() == getCurrentTab())
    {
      // already here.
      println("Already here.");
    }
    else
    {
      changeTab(currentTab, controlEvent.tab().name());
    }
  }
}

void changeTab(String from, String to)
{
  // hide old panels
  currentTab = to;
  for (Panel panel : getPanelsForTab(currentTab))
  {
    for (Controller c : panel.getControls())
    {
      c.moveTo(currentTab);
      c.show();
    }
  }
  
}



boolean mouseOverMachine()
{
  boolean result = false;
  if (isMachineClickable())
  {
    if (getDisplayMachine().getOutline().surrounds(getMouseVector()))
      result = true;
    else
      result = false;
  }
  return result;
}


boolean isMachineClickable()
{
  if (getCurrentTab() == TAB_NAME_INPUT)
  {
    return true;
  }
  else if (getCurrentTab() == TAB_NAME_PREVIEW)
  {
    return true;
  }
  else if (getCurrentTab() == TAB_NAME_QUEUE)
  {
    return false;
  }
  else if (getCurrentTab() == TAB_NAME_DETAILS)
  {
    return false;
  }
  else
  {
    return false;
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
  boolean result = false;
  for (Panel panel : getPanelsForTab(currentTab))
  {
    if (panel.getOutline().surrounds(getMouseVector()))
      result = true;
  }
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


void zoomOutFromMachine(float inc)
{
  if (machineScaling > inc)
  {
    machineScaling = machineScaling - inc;
    machineScaling =  Math.round(machineScaling*100.0)/100.0;
  }
//  getDisplayMachine().setScaledImage(null);
}

public final float MAX_ZOOM = 2.0;
void zoomInToMachine(float inc)
{
  if (machineScaling <= (MAX_ZOOM - inc))
  {
    machineScaling = machineScaling + inc;
    machineScaling =  Math.round(machineScaling*100.0)/100.0;
  }
//  getDisplayMachine().setScaledImage(null);
}
float getZoomIncrement()
{
  return 0.1;
}

void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == java.awt.event.KeyEvent.VK_PAGE_UP)
    {
      zoomInToMachine(getZoomIncrement());
    }
    else if (keyCode == java.awt.event.KeyEvent.VK_PAGE_DOWN)
    {
      zoomOutFromMachine(getZoomIncrement());
    }
    else if (keyCode == DOWN)
    {
      getDisplayMachine().getOffset().y = getDisplayMachine().getOffset().y + 10;
    }
    else if (keyCode == UP)
    {
      getDisplayMachine().getOffset().y = getDisplayMachine().getOffset().y - 10;
    }
    else if (keyCode == RIGHT)
    {
      getDisplayMachine().getOffset().x = getDisplayMachine().getOffset().x + 10;
    }
    else if (keyCode == LEFT)
    {
      getDisplayMachine().getOffset().x = getDisplayMachine().getOffset().x - 10;
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
  {
    currentMachineMaxSpeed = currentMachineMaxSpeed+MACHINE_MAXSPEED_INCREMENT;
    currentMachineMaxSpeed =  Math.round(currentMachineMaxSpeed*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_SETMOTORSPEED+df.format(currentMachineMaxSpeed)+",END");
  }
  else if (key == '-')
  {
    currentMachineMaxSpeed = currentMachineMaxSpeed+(0.0 - MACHINE_MAXSPEED_INCREMENT);
    currentMachineMaxSpeed =  Math.round(currentMachineMaxSpeed*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_SETMOTORSPEED+df.format(currentMachineMaxSpeed)+",END");
  }
  else if (key == '*')
  {
    currentMachineAccel = currentMachineAccel+MACHINE_ACCEL_INCREMENT;
    currentMachineAccel =  Math.round(currentMachineAccel*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_SETMOTORACCEL+df.format(currentMachineAccel)+",END");
  }
  else if (key == '/')
  {
    currentMachineAccel = currentMachineAccel+(0.0 - MACHINE_ACCEL_INCREMENT);
    currentMachineAccel =  Math.round(currentMachineAccel*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_SETMOTORACCEL+df.format(currentMachineAccel)+",END");
  }
  else if (key == ']')
  {
    currentPenWidth = currentPenWidth+penIncrement;
    currentPenWidth =  Math.round(currentPenWidth*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
  }
  else if (key == '[')
  {
    currentPenWidth = currentPenWidth-penIncrement;
    currentPenWidth =  Math.round(currentPenWidth*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
  }
  else if (key == '#' )
  {
    realtimeCommandQueue.add(CMD_PENUP+"END");
  }
  else if (key == '~')
  {
    realtimeCommandQueue.add(CMD_PENDOWN+"END");
  }
  else if (key == '<' || key == ',')
  {
    if (this.maxSegmentLength > 4)
      this.maxSegmentLength--;
  }
  else if (key == '>' || key == '.')
  {
    this.maxSegmentLength++;
  }
}
  
void mouseClicked()
{
  if (mouseOverPanel())
  { // changing mode
//    panelClicked();
  }
  else if (mouseOverQueue())
  {// stopping or starting 
    println("queue clicked.");
    queueClicked();
  }
  else if (mouseOverMachine())
  { // picking coords
    machineClicked();
  }
}

void machineClicked()
{
  if (currentMode.equals(MODE_BEGIN))
  {
    currentMode = MODE_INPUT_BOX_TOP_LEFT;
  }
  else if (currentMode.equals(MODE_INPUT_BOX_TOP_LEFT))
  {
    PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
    setBoxVector1(pos);
    if (isBoxSpecified())
    {
      getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVector2(), getGridSize());
    }
      
    currentMode = MODE_INPUT_BOX_BOT_RIGHT;
  }
  else if (currentMode.equals(MODE_INPUT_BOX_BOT_RIGHT))
  {
    PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
    setBoxVector2(pos);
    if (isBoxSpecified())
      getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVector2(), getGridSize());
  }
  else if (currentMode.equals(MODE_SET_POSITION))
    sendSetPosition();
  else if (currentMode.equals(MODE_DRAW_DIRECT))
    sendMoveToPosition(true);
  else if (currentMode.equals(MODE_DRAW_TO_POSITION))
    sendMoveToPosition(false);
  else if (currentMode.equals(MODE_MOVE_IMAGE))
  {
    float ix = mouseX - (new Float(getMachine().getImageFrame().getWidth())/2);
    float iy = mouseY - (new Float(getMachine().getImageFrame().getHeight())/2);
    getMachine().getImageFrame().setPosition(ix, iy);
    if (isBoxSpecified())
      getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVector2(), getGridSize());
  }
}  
 

boolean isPreviewable(String command)
{
  if ((command.startsWith(CMD_CHANGELENGTHDIRECT) || command.startsWith(CMD_CHANGELENGTH)))
  {
    return true;
  }
  else
  {
    return false;
  }
}

/**
  This will comb the command queue and attempt to draw a picture of what it contains.
  Coordinates here are in pixels.
*/
void previewQueue()
{
//  
//  PVector startPoint = null;
//  
//  List<String> fullList = new ArrayList<String>();
//  if (!commandHistory.isEmpty())
//  {
//    Integer commandPosition = commandHistory.size()-1;
//    String lastCommand = "";
//    while (commandPosition>=0)
//    {
//      lastCommand = commandHistory.get(commandPosition);
//      if (isPreviewable(lastCommand))
//      {
//        fullList.add(lastCommand);
//        break;
//      }
//      commandPosition--;
//    }
//  }
//
//  for (String command : commandQueue)
//  {
//    if ((command.startsWith(CMD_CHANGELENGTHDIRECT) || command.startsWith(CMD_CHANGELENGTH)))
//    {
//      fullList.add(command);
//    }
//  }
//  
//  for (String command : fullList)
//  {
//    String[] splitted = split(command, ",");
//    String aLenStr = splitted[1];
//    String bLenStr = splitted[2];
//    int aLen = getMachine().inMM(Integer.parseInt(aLenStr));
//    int bLen = getMachine().inMM(Integer.parseInt(bLenStr));
//    PVector endPoint = getCartesian(aLen, bLen);
//    
//    if (startPoint == null)
//    {
//      noStroke();
//      fill(255,0,255,150);
//      startPoint = getMachine().asCartesian(currentMachinePos);
//      ellipse(startPoint.x, startPoint.y, 20, 20);
//      noFill();
//    }
//    
//    stroke(255);
//    line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
//    startPoint = endPoint;
//  }
//  
//
//  if (startPoint != null)
//  {
//    noStroke();
//    fill(200,0,0,128);
//    ellipse(startPoint.x, startPoint.y, 15,15);
//    noFill();
//  }
//  
}

void sizeImageToFitBox()
{
  float boxWidth = boxVector2.x - boxVector1.x;
  float boxHeight = boxVector2.y - boxVector2.y;
  PVector boxSize = new PVector(boxWidth, boxHeight);
  
  Rectangle r = new Rectangle(boxVector1, boxSize);
  getMachine().setImageFrame(r);
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
  int totalCommands = commandQueue.size()+realtimeCommandQueue.size();
  
  if (rowClicked < 1) // its the header - start or stop queue
  {
    if (commandQueueRunning)
      commandQueueRunning = false;
    else
      commandQueueRunning = true;
  }
  else if (rowClicked > 2 && rowClicked < totalCommands+3) // it's a command from the queue
  {
    int cmdNumber = rowClicked-2;
    if (commandQueueRunning)
    {
      // if its running, then clicking on a command will mark it as a pause point
    }
    else
    {
      // if it's not running, then clicking on a command row will remove it
      if (!realtimeCommandQueue.isEmpty())
      {
        if (cmdNumber <= realtimeCommandQueue.size())
          realtimeCommandQueue.remove(cmdNumber-1);
        else  
        {
          cmdNumber-=(realtimeCommandQueue.size()+1);
          commandQueue.remove(cmdNumber);
        }        
      }
      else
      {
        commandQueue.remove(cmdNumber-1);
      }
    }
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
//  int roundedA = rounded(getALength())-rowWidth;
//  int roundedB = rounded(getBLength())-rowWidth;
//  PVector posInMachine = new PVector(roundedA, roundedB);
//  rowsVector1 = posInMachine;
}
void setRowsVector2()
{
//  int roundedA = rounded(getALength());
//  int roundedB = rounded(getBLength());
//  PVector posInMachine = new PVector(roundedA, roundedB);
//  rowsVector2 = posInMachine;
}

boolean isBoxSpecified()
{
  if (boxVector1 != null && boxVector2 != null)
    return true;
  else
    return false;
}

void setBoxVector1(PVector vec)
{
  boxVector1 = vec;
}
void setBoxVector2(PVector vec)
{
  boxVector2 = vec;
}
PVector getBoxVector1()
{
  return this.boxVector1;
}
PVector getBoxVector2()
{
  return this.boxVector2;
}


void flipDirection()
{
  switch (drawDirection)
  {
    case DRAW_DIR_SE:  
      drawDirection = DRAW_DIR_NW; 
      break;
    case DRAW_DIR_SW:  
      drawDirection = DRAW_DIR_NE; 
      break;
    case DRAW_DIR_NW:  
      drawDirection = DRAW_DIR_SE; 
      break;
    case DRAW_DIR_NE:
      drawDirection = DRAW_DIR_SW; 
      break;
  }
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
  rect(xPosOrigin, yPosOrigin, 200, 400);
  
  
  textSize(12);
  fill(255);
  int tRow = 15;
  int textPositionX = xPosOrigin+4;
  int textPositionY = yPosOrigin+4;
  
  int tRowNo = 1;
  PVector screenCoordsCart = getMouseVector();
 
  text("Cursor position: " + mouseX + ", " + mouseY, textPositionX, textPositionY+(tRow*tRowNo++));
  
//  text("Pixel Length A: " + dist(getDisplayMachine().getLeft(), getDisplayMachine().getTop(), screenCoordsCart.x, screenCoordsCart.y), textPositionX, textPositionY+(tRow*tRowNo++));
//  text("Pixel Length B: " + dist(getDisplayMachine().getRight(), getDisplayMachine().getTop(), screenCoordsCart.x, screenCoordsCart.y), textPositionX, textPositionY+(tRow*tRowNo++));
//
  
  text("MM Per Step: " + getMachine().getMMPerStep(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Steps Per MM: " + getMachine().getStepsPerMM() ,textPositionX, textPositionY+(tRow*tRowNo++));

  if (getDisplayMachine().getOutline().surrounds(screenCoordsCart))
  {
    PVector posOnMachineCartesianInMM = getDisplayMachine().scaleToDisplayMachine(screenCoordsCart);
    text("Machine x/y mm: " + posOnMachineCartesianInMM.x+","+posOnMachineCartesianInMM.y, textPositionX, textPositionY+(tRow*tRowNo++));
    
    PVector posOnMachineNativeInMM = getDisplayMachine().convertToNative(posOnMachineCartesianInMM);
    text("Machine a/b mm: " + posOnMachineNativeInMM.x+","+posOnMachineNativeInMM.y, textPositionX, textPositionY+(tRow*tRowNo++));
  
    PVector posOnMachineNativeInSteps = getDisplayMachine().inSteps(posOnMachineNativeInMM);
    text("Machine a/b steps: " + posOnMachineNativeInSteps.x+","+posOnMachineNativeInSteps.y, textPositionX, textPositionY+(tRow*tRowNo++));
  }
  else
  {
    text("Machine x/y mm: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
    text("Machine a/b mm: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
    text("Machine a/b steps: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
  }
  


  drawStatusText(textPositionX, textPositionY+(tRow*tRowNo++));  
    
  text(commandStatus, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Mode: " + currentMode, textPositionX, textPositionY+(tRow*tRowNo++));

  // middle side
//  textPositionX = textPositionX+200;
//  textPositionY = yPosOrigin;
//  tRowNo = 1;
  
  text("Row size: " + getGridSize(), textPositionX, textPositionY+(tRow*tRowNo++));
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
  text("Max line segment length: " + getMaxSegmentLength(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Zoom: " + machineScaling, textPositionX, textPositionY+(tRow*tRowNo++));

  tRowNo++;
  text("Machine settings:", textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent pen width: " + currentPenWidth, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent speed: " + currentMachineMaxSpeed, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent accel: " + currentMachineAccel, textPositionX, textPositionY+(tRow*tRowNo++));

}

void drawStatusText(int x, int y)
{
  String drawbotStatus = null;
  
  if (useSerialPortConnection)
  {
    if (isDrawbotConnected())
    {
      if (drawbotReady)
      {
        fill(0, 200, 0);
        drawbotStatus = "Polargraph READY!";
      }
      else
      {
        fill(200, 200, 0);
        drawbotStatus = "BUSY: " + lastCommand;
      }  
    }
    else
    {
      fill(255, 0, 0);
      drawbotStatus = "Polargraph is not connected.";
    }  
  }
  else
  {
    fill(255, 0, 0);
    drawbotStatus = "No serial connection.";
  }
  
  text(drawbotStatus, x, y);
  fill(255);
}

void setCommandQueueFont()
{
  textSize(12);
  fill(255);
}  
void showCommandQueue(int xPos, int yPos)
{
  setCommandQueueFont();
  int tRow = 15;
  int textPositionX = xPos;
  int textPositionY = yPos;
  int tRowNo = 1;

  int commandQueuePos = textPositionY+(tRow*tRowNo++);

  topEdgeOfQueue = commandQueuePos-queueRowHeight;
  leftEdgeOfQueue = textPositionX;
  rightEdgeOfQueue = textPositionX+300;
  bottomEdgeOfQueue = height;
  
  drawCommandQueueStatus(textPositionX, commandQueuePos, 14);
  commandQueuePos+=queueRowHeight;
  text("Last command: " + ((commandHistory.isEmpty()) ? "-" : commandHistory.get(commandHistory.size()-1)), textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  text("Current command: " + lastCommand, textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  
  fill(128,255,255);
  int queueNumber = commandQueue.size()+realtimeCommandQueue.size();
  for (String s : realtimeCommandQueue)
  {
    text((queueNumber--)+". "+ s, textPositionX, commandQueuePos);
    commandQueuePos+=queueRowHeight;
  }
  
  fill(255);
  for (String s : commandQueue)
  {
    text((queueNumber--)+". "+ s, textPositionX, commandQueuePos);
    commandQueuePos+=queueRowHeight;
  }
}

void drawCommandQueueStatus(int x, int y, int tSize)
{
  String queueStatus = null;
  textSize(tSize);
  if (commandQueueRunning)
  {
    queueStatus = "QUEUE RUNNING - click to pause";
    fill(0, 200, 0);
  }
  else
  {
    queueStatus = "QUEUE PAUSED - click to start";
    fill(255, 0, 0);
  }

  text("CommandQueue: " + queueStatus, x, y);
  setCommandQueueFont();
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



public Machine getMachine()
{
  return this.machine;
}
public DisplayMachine getDisplayMachine()
{
  if (displayMachine == null)
    displayMachine = new DisplayMachine(getMachine(), machinePosition, machineScaling);
    
  displayMachine.setOffset(machinePosition);
  displayMachine.setScale(machineScaling);
  return displayMachine;
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
  else if (incoming.startsWith("CARTESIAN"))
    readCartesianMachinePosition(incoming);
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

  if (drawbotReady)
    drawbotConnected = true;
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
void readCartesianMachinePosition(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 4)
  {
    String currentAPos = splitted[1];
    String currentBPos = splitted[2];
    Float a = Float.valueOf(currentAPos).floatValue();
    Float b = Float.valueOf(currentBPos).floatValue();
    currentCartesianMachinePos.x = a;
    currentCartesianMachinePos.y = b;  
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
    
    getMachine().setSize(intWidth, intHeight);
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
      println("Apparently the last command has been badly acknowledged, but there isn't one!!");
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
boolean isDrawbotConnected()
{
  return drawbotConnected;
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
      {
        println("saving.");
        savePropertiesFile();
        println("saved.");
      }
      
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
      catch (Exception e) {println(e.getMessage());};
    }
  }
  return props;
}

void loadFromPropertiesFile()
{
  getMachine().loadDefinitionFromProperties(getProperties());
  
  // pen size
  this.currentPenWidth = getFloatProperty("machine.pen.size", 1.0);

  this.currentMachineMaxSpeed = getFloatProperty("machine.motors.maxSpeed", 600.0);
  this.currentMachineAccel = getFloatProperty("machine.motors.accel", 400.0);
  
  // serial port
  this.serialPortNumber = getIntProperty("controller.machine.serialport", 0);

  // row size
  this.gridSize = getFloatProperty("controller.grid.size", 100.0);
  this.sampleArea = getIntProperty("controller.pixel.samplearea", 2);
  // initial screen size
  this.windowWidth = getIntProperty("controller.window.width", 800);
  this.windowHeight = getIntProperty("controller.window.height", 550);

  this.testPenWidthStartSize = getFloatProperty("controller.testPenWidth.startSize", 0.5);
  this.testPenWidthEndSize = getFloatProperty("controller.testPenWidth.endSize", 2.0);
  this.testPenWidthIncrementSize = getFloatProperty("controller.testPenWidth.incrementSize", 0.5);
  
  this.maxSegmentLength = getIntProperty("controller.maxSegmentLength", 20);
  
  
  println("Finished loading configuration from properties file.");
}

void savePropertiesFile()
{
  Properties props = new Properties();
  
  props = getMachine().loadDefinitionIntoProperties(props);
  
  // pen size
  props.setProperty("machine.pen.size", new Float(currentPenWidth).toString());
  // serial port
  props.setProperty("controller.machine.serialport", getSerialPortNumber().toString());

  // row size
  props.setProperty("controller.grid.size", new Float(gridSize).toString());
  props.setProperty("controller.pixel.samplearea", new Integer(sampleArea).toString());
  // initial screen size
  props.setProperty("controller.window.width", new Integer(width).toString());
  props.setProperty("controller.window.height", new Integer(height).toString());

  props.setProperty("controller.testPenWidth.startSize", new Float(testPenWidthStartSize).toString());
  props.setProperty("controller.testPenWidth.endSize", new Float(testPenWidthEndSize).toString());
  props.setProperty("controller.testPenWidth.incrementSize", new Float(testPenWidthIncrementSize).toString());
  
  props.setProperty("controller.maxSegmentLength", new Integer(getMaxSegmentLength()).toString());
  
  props.setProperty("machine.motors.maxSpeed", new Float(currentMachineMaxSpeed).toString());
  props.setProperty("machine.motors.accel", new Float(currentMachineAccel).toString());
  
 
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
      catch (Exception e2) {println("what now!"+e2.getMessage());}
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

Integer getSerialPortNumber()
{
  return this.serialPortNumber;
}
  
void initProperties()
{
  getProperties();
}


