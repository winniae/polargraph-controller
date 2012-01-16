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
  Requires the excellent Geomerative library available from http://www.ricardmarxer.com/geomerative/.
  
  This is an application for controlling a polargraph machine, communicating using ASCII command language over a serial link.

  sandy.noble@gmail.com
  http://www.polargraph.co.uk/
  http://code.google.com/p/polargraph/
*/
void button_mode_begin()
{
  button_mode_clearQueue();
}
void numberbox_mode_changeGridSize(float value)
{
  setGridSize(value);
  if (isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
  }
}
void numberbox_mode_changeSampleArea(float value)
{
  setSampleArea(value);
  if (isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
  }
}
void minitoggle_mode_showImage(boolean flag)
{
  this.displayingImage = flag;
}
void minitoggle_mode_showVector(boolean flag)
{
  this.displayingVector = flag;
}
void minitoggle_mode_showDensityPreview(boolean flag)
{
  this.displayingDensityPreview = flag;
}
void minitoggle_mode_showQueuePreview(boolean flag)
{
  this.displayingQueuePreview = flag;
}
void minitoggle_mode_showGuides(boolean flag)
{
  this.displayingGuides = flag;
}
void unsetOtherToggles(String except)
{
  for (String name : getAllControls().keySet())
  {
    if (name.startsWith("toggle_"))
    {
      if (name.equals(except))
      {
//        println("not resetting this one.");
      }
      else
      {
        getAllControls().get(name).setValue(0);
      }
    }
  }
}
void toggle_mode_inputBoxTopLeft(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_INPUT_BOX_TOP_LEFT);
    setMode(MODE_INPUT_BOX_TOP_LEFT);
  }
  else
    currentMode = "";
}
void toggle_mode_inputBoxBotRight(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_INPUT_BOX_BOT_RIGHT);
    setMode(MODE_INPUT_BOX_BOT_RIGHT);
    // unset topleft
  }
  else
    currentMode = "";
}
void button_mode_drawOutlineBox()
{
  setMode(MODE_DRAW_OUTLINE_BOX);
  if (isBoxSpecified())
    sendOutlineOfBox();
}
void button_mode_drawOutlineBoxRows()
{
  if (isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendOutlineOfRows(pixels, DRAW_DIR_SE);
  }
}
void button_mode_drawShadeBoxRowsPixels()
{
  if (isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendOutlineOfPixels(pixels);
  }
}
void toggle_mode_drawToPosition(boolean flag)
{
  // unset other toggles
  if (flag)
  {
    unsetOtherToggles(MODE_DRAW_TO_POSITION);
    setMode(MODE_DRAW_TO_POSITION);
  }
}
void button_mode_renderSquarePixel()
{
  if (isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendSquarePixels(pixels);
  }
}
void button_mode_renderSawPixel()
{
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendSawtoothPixels();
}
void button_mode_renderCirclePixel()
{
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendCircularPixels();
}
void button_mode_renderVectors()
{
  sendVectorShapes();
}

void toggle_mode_setPosition(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_SET_POSITION);
    setMode(MODE_SET_POSITION);
  }
}
void button_mode_drawTestPattern()
{
  sendTestPattern();
}
void button_mode_incRowSize()
{
  gridSize+=5.0;
  getDisplayMachine().setGridSize(gridSize);
  if (isBoxSpecified())
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), getSampleArea());
}
void button_mode_decRowSize()
{
  gridSize-=5;
  getDisplayMachine().setGridSize(gridSize);
  if (isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), getSampleArea());
  }
}

void button_mode_drawGrid()
{
  if (isBoxSpecified())
  {
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendGridOfBox(pixels);
  }
}
void button_mode_loadImage()
{
  loadImageWithFileChooser();
}
void button_mode_loadVectorFile()
{
  loadVectorWithFileChooser();
}
void numberbox_mode_pixelBrightThreshold(float value)
{
  pixelExtractBrightThreshold = int(value+0.5);
}
void numberbox_mode_pixelDarkThreshold(float value)
{
  pixelExtractDarkThreshold = int(value+0.5);
}

void button_mode_pauseQueue()
{
}
void button_mode_runQueue()
{
}
void button_mode_clearQueue()
{
  resetQueue();
}
void button_mode_setPositionHome()
{
  sendSetHomePosition();
}
void button_mode_drawTestPenWidth()
{
  sendTestPenWidth();
}
void button_mode_renderScaledSquarePixels()
{
  if (isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendScaledSquarePixels(pixels);
  }
}
void button_mode_renderSolidSquarePixels()
{
  if (isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendSolidSquarePixels(pixels);
  }
}
void button_mode_renderScribblePixels()
{
  if (isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendScribblePixels(pixels);
  }
}
void button_mode_changeMachineSpec()
{
  sendMachineSpec();
}
void button_mode_requestMachineSize()
{
  sendRequestMachineSize();
}
void button_mode_resetMachine()
{
  sendResetMachine();
}
void button_mode_saveProperties()
{
  savePropertiesFile();
  // clear old properties.
  props = null;
  loadFromPropertiesFile();
}
void toggle_mode_moveImage(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_MOVE_IMAGE);
    setMode(MODE_MOVE_IMAGE);
  }
  else
  {
    setMode("");
  }
}
void button_mode_convertBoxToPictureframe()
{
  setPictureFrameDimensionsToBox();
}
void button_mode_selectPictureframe()
{
  setBoxToPictureframeDimensions();
}
void button_mode_exportQueue()
{
  exportQueueToFile();
}
void button_mode_importQueue()
{
  importQueueFromFile();
}
void button_mode_fitImageToBox()
{
  sizeImageToFitBox();
  if (isBoxSpecified())
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), getSampleArea());
  println("fitted image to box.");
}
void toggle_mode_drawDirect(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_DRAW_DIRECT);
    setMode(MODE_DRAW_DIRECT);
  }
}

void numberbox_mode_changeMachineWidth(float value)
{
  clearBoxVectors();
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getSize().x = steps;
}
void numberbox_mode_changeMachineHeight(float value)
{
  clearBoxVectors();
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getSize().y = steps;
}
void numberbox_mode_changeMMPerRev(float value)
{
  clearBoxVectors();
  getDisplayMachine().setMMPerRev(value);
}
void numberbox_mode_changeStepsPerRev(float value)
{
  clearBoxVectors();
  getDisplayMachine().setStepsPerRev(value);
}
void numberbox_mode_changePageWidth(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().setWidth(steps);
}
void numberbox_mode_changePageHeight(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().setHeight(steps);
}
void numberbox_mode_changePageOffsetX(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().getTopLeft().x = steps;
}
void numberbox_mode_changePageOffsetY(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().getTopLeft().y = steps;
}
void button_mode_changePageOffsetXCentre()
{
  float pageWidth = getDisplayMachine().getPage().getWidth();
  float machineWidth = getDisplayMachine().getSize().x;
  float diff = (machineWidth - pageWidth) / 2.0;
  getDisplayMachine().getPage().getTopLeft().x = diff;
  initialiseNumberboxValues(getAllControls());
}

void numberbox_mode_changeHomePointX(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getHomePoint().x = steps;
}
void numberbox_mode_changeHomePointY(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getHomePoint().y = steps;
}
void button_mode_changeHomePointXCentre()
{
  float halfWay = getDisplayMachine().getSize().x / 2.0;
  getHomePoint().x = halfWay;
  getHomePoint().y = getDisplayMachine().getPage().getTop();
  initialiseNumberboxValues(getAllControls());
}


void numberbox_mode_changePenWidth(float value)
{
  currentPenWidth =  Math.round(value*100.0)/100.0;
}
void button_mode_sendPenWidth()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  
  df.applyPattern("###.##");
  realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
}  

void numberbox_mode_changePenTestStartWidth(float value)
{
  testPenWidthStartSize = Math.round(value*100.0)/100.0;
}
void numberbox_mode_changePenTestEndWidth(float value)
{
  testPenWidthEndSize = Math.round(value*100.0)/100.0;
}
void numberbox_mode_changePenTestIncrementSize(float value)
{
  testPenWidthIncrementSize = Math.round(value*100.0)/100.0;
}

void numberbox_mode_changeMachineMaxSpeed(float value)
{
  currentMachineMaxSpeed =  Math.round(value*100.0)/100.0;
}
void numberbox_mode_changeMachineAcceleration(float value)
{
  currentMachineAccel =  Math.round(value*100.0)/100.0;
}
void button_mode_sendMachineSpeed()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  

  df.applyPattern("###.##");
  realtimeCommandQueue.add(CMD_SETMOTORSPEED+df.format(currentMachineMaxSpeed)+",END");

  df.applyPattern("###.##");
  realtimeCommandQueue.add(CMD_SETMOTORACCEL+df.format(currentMachineAccel)+",END");
}




void setMode(String m)
{
  lastMode = currentMode;
  currentMode = m;
}
void revertToLastMode()
{
  currentMode = lastMode;
}

