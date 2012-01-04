void button_mode_begin()
{
  button_mode_clearQueue();
}
void button_mode_inputBoxTopLeft()
{
  setMode(MODE_INPUT_BOX_TOP_LEFT);
}
void button_mode_inputBoxBotRight()
{
  setMode(MODE_INPUT_BOX_BOT_RIGHT);
}
void button_mode_drawOutlineBox()
{
  setMode(MODE_DRAW_OUTLINE_BOX);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendOutlineOfBox();
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
void button_mode_drawToPosition()
{
  setMode(MODE_DRAW_TO_POSITION);
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
void button_mode_setPosition()
{
  setMode(MODE_SET_POSITION);
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
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVector2(), getGridSize());
}
void button_mode_decRowSize()
{
  gridSize-=5;
  getDisplayMachine().setGridSize(gridSize);
  if (isBoxSpecified())
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVector2(), getGridSize());
}
void button_mode_drawGrid()
{
  setMode(MODE_DRAW_GRID);
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendGridOfBox();
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
void button_mode_incSampleArea()
{
  sampleArea+=1;
//  rebuildRows();
//  extractRowsFromBox();
//  extractRows();
}
void button_mode_decSampleArea()
{
//  if (sampleArea < 2)
//    sampleArea = inMM(rowWidth/2);
//  else
//    sampleArea-=1;
    
//  rebuildRows();
//  extractRowsFromBox();
//  extractRows();
}
void button_mode_moveImage()
{
  setMode(MODE_MOVE_IMAGE);
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
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//  {
//    sizeImageToFitBox();
//  }
//  extractRowsFromBox();
  println("fitted image to box.");
}
void button_mode_drawDirect()
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

