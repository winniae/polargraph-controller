void mode_begin()
{
  mode_clearQueue();
}
void mode_inputBoxTopLeft()
{
  setMode(MODE_INPUT_BOX_TOP_LEFT);
}
void mode_inputBoxBotRight()
{
  setMode(MODE_INPUT_BOX_BOT_RIGHT);
}
void mode_drawOutlineBox()
{
  setMode(MODE_DRAW_OUTLINE_BOX);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendOutlineOfBox();
}
void mode_drawOutlineBoxRows()
{
  setMode(MODE_DRAW_OUTLINE_BOX_ROWS);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendOutlineOfRows();
}
void mode_drawShadeBoxRowsPixels()
{
  setMode(MODE_DRAW_SHADE_BOX_ROWS_PIXELS);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendOutlineOfPixels();
}
void mode_drawToPosition()
{
  setMode(MODE_DRAW_TO_POSITION);
}
void mode_renderSquarePixel()
{
  setMode(MODE_RENDER_SQUARE_PIXELS);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendSquarePixels();
}
void mode_renderSawPixel()
{
  setMode(MODE_RENDER_SAW_PIXELS);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendSawtoothPixels();
}
void mode_renderCirclePixel()
{
  setMode(MODE_RENDER_CIRCLE_PIXELS);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendCircularPixels();
}
void mode_inputRowStart()
{
  setMode(MODE_INPUT_ROW_START);
}
void mode_inputRowEnd()
{
  setMode(MODE_INPUT_ROW_END);
}
void mode_setPosition()
{
  setMode(MODE_SET_POSITION);
}
void mode_drawTestPattern()
{
  setMode(MODE_DRAW_TESTPATTERN);
  sendTestPattern();
}
void mode_incRowSize()
{
  rowWidth+=5;
  rebuildRows();
  extractRowsFromBox();
  extractRows();
}
void mode_decRowSize()
{
  rowWidth-=5;
  rebuildRows();
  extractRowsFromBox();
  extractRows();
}
void mode_drawGrid()
{
  setMode(MODE_DRAW_GRID);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendGridOfBox();
}
void mode_loadImage()
{
  setMode(MODE_LOAD_IMAGE);
//  loadImageWithFileChooser();
}
void mode_pauseQueue()
{
  setMode(MODE_PAUSE_QUEUE);
}
void mode_runQueue()
{
  setMode(MODE_RUN_QUEUE);
}
void mode_clearQueue()
{
  setMode(MODE_CLEAR_QUEUE);
  resetQueue();
}
void mode_setPositionHome()
{
  setMode(MODE_SET_POSITION_HOME);
  sendSetHomePosition();
}
void mode_drawTestPenWidth()
{
  setMode(MODE_DRAW_TEST_PENWIDTH);
  sendTestPenWidth();
}
void mode_renderScaledSquarePixels()
{
  setMode(MODE_RENDER_SCALED_SQUARE_PIXELS);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendScaledSquarePixels();
}
void mode_renderSolidSquarePixels()
{
  setMode(MODE_RENDER_SOLID_SQUARE_PIXELS);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendSolidSquarePixels();
}
void mode_renderScribblePixels()
{
  setMode(MODE_RENDER_SCRIBBLE_PIXELS);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
    sendScribblePixels();
}
void mode_changeMachineSpec()
{
  setMode(MODE_CHANGE_MACHINE_SPEC);
  sendMachineSpec();
}
void mode_requestMachineSize()
{
  setMode(MODE_REQUEST_MACHINE_SIZE);
  sendRequestMachineSize();
}
void mode_resetMachine()
{
  setMode(MODE_RESET_MACHINE);
  sendResetMachine();
}
void mode_saveProperties()
{
  setMode(MODE_SAVE_PROPERTIES);
  savePropertiesFile();
  // clear old properties.
  props = null;
  loadFromPropertiesFile();
}
void mode_incSampleArea()
{
  sampleArea+=1;
  rebuildRows();
  extractRowsFromBox();
  extractRows();
}
void mode_decSampleArea()
{
//  if (sampleArea < 2)
//    sampleArea = inMM(rowWidth/2);
//  else
//    sampleArea-=1;
    
  rebuildRows();
  extractRowsFromBox();
  extractRows();
}
void mode_moveImage()
{
  setMode(MODE_MOVE_IMAGE);
}
void mode_convertBoxToPictureframe()
{
  setMode(MODE_CONVERT_BOX_TO_PICTUREFRAME);
  setPictureFrameDimensionsToBox();
}
void mode_selectPictureframe()
{
  setMode(MODE_SELECT_PICTUREFRAME);
  setBoxToPictureframeDimensions();
}
void mode_exportQueue()
{
  setMode(MODE_EXPORT_QUEUE);
  exportQueueToFile();
}
void mode_importQueue()
{
  setMode(MODE_IMPORT_QUEUE);
  importQueueFromFile();
}
void mode_fitImageToBox()
{
  setMode(MODE_FIT_IMAGE_TO_BOX);
  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
  {
    sizeImageToFitBox();
  }
  extractRowsFromBox();
  println("fitted image to box.");
}
void mode_drawDirect()
{
  setMode(MODE_DRAW_DIRECT);
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

