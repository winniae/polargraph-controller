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
  setMode(MODE_DRAW_OUTLINE_BOX_ROWS);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendOutlineOfRows();
}
void button_mode_drawShadeBoxRowsPixels()
{
  setMode(MODE_DRAW_SHADE_BOX_ROWS_PIXELS);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendOutlineOfPixels();
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
  setMode(MODE_RENDER_SQUARE_PIXELS);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendSquarePixels();
}
void button_mode_renderSawPixel()
{
  setMode(MODE_RENDER_SAW_PIXELS);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendSawtoothPixels();
}
void button_mode_renderCirclePixel()
{
  setMode(MODE_RENDER_CIRCLE_PIXELS);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendCircularPixels();
}
void button_mode_inputRowStart()
{
  setMode(MODE_INPUT_ROW_START);
}
void button_mode_inputRowEnd()
{
  setMode(MODE_INPUT_ROW_END);
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
  setMode(MODE_DRAW_TESTPATTERN);
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
  setMode(MODE_DRAW_GRID);
  if (isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), getSampleArea());
    sendGridOfBox();
  }
}
void button_mode_loadImage()
{
  setMode(MODE_LOAD_IMAGE);
//  loadImageWithFileChooser();
}
void button_mode_pauseQueue()
{
  setMode(MODE_PAUSE_QUEUE);
}
void button_mode_runQueue()
{
  setMode(MODE_RUN_QUEUE);
}
void button_mode_clearQueue()
{
  setMode(MODE_CLEAR_QUEUE);
  resetQueue();
}
void button_mode_setPositionHome()
{
  setMode(MODE_SET_POSITION_HOME);
  sendSetHomePosition();
}
void button_mode_drawTestPenWidth()
{
  setMode(MODE_DRAW_TEST_PENWIDTH);
  sendTestPenWidth();
}
void button_mode_renderScaledSquarePixels()
{
  setMode(MODE_RENDER_SCALED_SQUARE_PIXELS);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendScaledSquarePixels();
}
void button_mode_renderSolidSquarePixels()
{
  setMode(MODE_RENDER_SOLID_SQUARE_PIXELS);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendSolidSquarePixels();
}
void button_mode_renderScribblePixels()
{
  setMode(MODE_RENDER_SCRIBBLE_PIXELS);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendScribblePixels();
}
void button_mode_changeMachineSpec()
{
  setMode(MODE_CHANGE_MACHINE_SPEC);
  sendMachineSpec();
}
void button_mode_requestMachineSize()
{
  setMode(MODE_REQUEST_MACHINE_SIZE);
  sendRequestMachineSize();
}
void button_mode_resetMachine()
{
  setMode(MODE_RESET_MACHINE);
  sendResetMachine();
}
void button_mode_saveProperties()
{
  setMode(MODE_SAVE_PROPERTIES);
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
}
void button_mode_convertBoxToPictureframe()
{
  setMode(MODE_CONVERT_BOX_TO_PICTUREFRAME);
  setPictureFrameDimensionsToBox();
}
void button_mode_selectPictureframe()
{
  setMode(MODE_SELECT_PICTUREFRAME);
  setBoxToPictureframeDimensions();
}
void button_mode_exportQueue()
{
  setMode(MODE_EXPORT_QUEUE);
  exportQueueToFile();
}
void button_mode_importQueue()
{
  setMode(MODE_IMPORT_QUEUE);
  importQueueFromFile();
}
void button_mode_fitImageToBox()
{
  setMode(MODE_FIT_IMAGE_TO_BOX);
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

void setMode(String m)
{
  lastMode = currentMode;
  currentMode = m;
}
void revertToLastMode()
{
  currentMode = lastMode;
}

