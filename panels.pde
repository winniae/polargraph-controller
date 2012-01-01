


void showPanel()
{
  strokeWeight(2);
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
  rect(0, 0, getMachine().getWidth(), getMachine().getHeight()); // machine
  fill(pageColour);
  rect(getMachine().getPage().getLeft(), 
        getMachine().getPage().getTop(), 
        getMachine().getPage().getWidth(), 
        getMachine().getPage().getHeight()); // page
  noStroke();
  
  showShadedCentres(new PVector(0, 0));
  
}



Map<Integer, Map<Integer, Integer>> buildPanels()
{
  Map<Integer, Map<Integer, Integer>> panelMap = new HashMap<Integer, Map<Integer, Integer>>(5);
  
  Map<Integer, Integer> inputPanel = new HashMap<Integer, Integer>(30);
  inputPanel.put(0, MODE_BEGIN);
  inputPanel.put(1, MODE_SET_POSITION_HOME);
  inputPanel.put(2, MODE_SET_POSITION);
  inputPanel.put(3, MODE_DRAW_TO_POSITION);
  inputPanel.put(4, MODE_DRAW_DIRECT);
  
  inputPanel.put(5, MODE_INPUT_BOX_TOP_LEFT);
  inputPanel.put(6, MODE_INPUT_BOX_BOT_RIGHT);

  inputPanel.put(7, MODE_CONVERT_BOX_TO_PICTUREFRAME);
  inputPanel.put(8, MODE_SELECT_PICTUREFRAME);

  inputPanel.put(9, LOAD_IMAGE);
  inputPanel.put(10, MODE_MOVE_IMAGE);
  inputPanel.put(11, MODE_FIT_IMAGE_TO_BOX);
  
  inputPanel.put(13, MODE_RENDER_SQUARE_PIXELS);
  inputPanel.put(14, MODE_RENDER_SCALED_SQUARE_PIXELS);
  inputPanel.put(15, MODE_RENDER_SOLID_SQUARE_PIXELS);
  inputPanel.put(16, MODE_RENDER_SCRIBBLE_PIXELS);

  inputPanel.put(17, MODE_DRAW_TEST_PENWIDTH);
//  inputPanel.put(17, MODE_DRAW_TESTPATTERN);

  inputPanel.put(19, INS_INC_ROWSIZE);
  inputPanel.put(20, INS_DEC_ROWSIZE);


  inputPanel.put(22, MODE_DRAW_GRID);
  inputPanel.put(23, MODE_DRAW_OUTLINE_BOX);
  inputPanel.put(24, MODE_DRAW_OUTLINE_BOX_ROWS);
  inputPanel.put(25, MODE_DRAW_SHADE_BOX_ROWS_PIXELS);

//  inputPanel.put(23, MODE_INPUT_ROW_START);
//  inputPanel.put(24, MODE_INPUT_ROW_END);
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
  detailsPanel.put(14, MODE_CHANGE_MACHINE_SPEC);
  detailsPanel.put(16, MODE_REQUEST_MACHINE_SIZE);
  detailsPanel.put(17, MODE_RESET_MACHINE);
  detailsPanel.put(18, MODE_SAVE_PROPERTIES);
  
  panelMap.put(PAGE_DETAILS, detailsPanel);

  Map<Integer, Integer> queuePanel = new HashMap<Integer, Integer>(30);
  queuePanel.put(0, MODE_BEGIN);
  queuePanel.put(5, MODE_RENDER_COMMAND_QUEUE);
  queuePanel.put(6, MODE_EXPORT_QUEUE);
  queuePanel.put(7, MODE_IMPORT_QUEUE);
  
  panelMap.put(PAGE_COMMAND_QUEUE, queuePanel);
  
  return panelMap;
}

Map<Integer, String> buildButtonLabels()
{
  Map<Integer, String> result = new HashMap<Integer, String>(19);
  
  result.put(MODE_BEGIN, "Reset queue");
  result.put(MODE_INPUT_BOX_TOP_LEFT, "Select TopLeft");
  result.put(MODE_INPUT_BOX_BOT_RIGHT, "Select BotRight");
  result.put(MODE_DRAW_OUTLINE_BOX, "Draw Outline box");
  result.put(MODE_DRAW_OUTLINE_BOX_ROWS, "Draw Outline rows");
  result.put(MODE_DRAW_SHADE_BOX_ROWS_PIXELS, "Draw Outline pixels");

  result.put(MODE_DRAW_TO_POSITION, "Move pen to point");
  result.put(MODE_DRAW_DIRECT, "Move direct");
  result.put(MODE_RENDER_SQUARE_PIXELS, "Shade Squarewave");
  result.put(MODE_RENDER_SCALED_SQUARE_PIXELS, "Shade Scaled Squarewave");
  result.put(MODE_RENDER_SAW_PIXELS, "Shade sawtooth");
  result.put(MODE_RENDER_CIRCLE_PIXELS, "Shade circular");
  result.put(MODE_INPUT_ROW_START, "Select Row start");
  result.put(MODE_INPUT_ROW_END, "Select Row end");
  result.put(MODE_SET_POSITION, "Set pen position");
  
  result.put(MODE_DRAW_GRID, "Draw grid of box");
  result.put(MODE_DRAW_TESTPATTERN, "test pattern");
  
  result.put(PLACE_IMAGE, "place image");
  result.put(LOAD_IMAGE, "Load image file");
  
  result.put(INS_INC_ROWSIZE, "Rowsize up");
  result.put(INS_DEC_ROWSIZE, "Rowsize down");
  result.put(MODE_SET_POSITION_HOME, "Set home");
  result.put(MODE_INPUT_SINGLE_PIXEL, "Choose pixel");
  result.put(MODE_DRAW_TEST_PENWIDTH, "Test pen widths");
  result.put(MODE_RENDER_SOLID_SQUARE_PIXELS, "Shade solid");
  result.put(MODE_RENDER_SCRIBBLE_PIXELS, "Shade scribble");

  result.put(MODE_LOAD_SD_IMAGE, "upload image (SD)");
  result.put(MODE_START_ROVING, "start rove");
  result.put(MODE_STOP_ROVING, "stop rove");
  result.put(MODE_SET_ROVE_AREA, "set rove area");
  result.put(MODE_CREATE_MACHINE_TEXT_BITMAP, "render as text");
  
  result.put(MODE_CHANGE_MACHINE_SPEC, "Upload machine spec");
  result.put(MODE_REQUEST_MACHINE_SIZE, "Download size spec");
  result.put(MODE_RESET_MACHINE, "Reset machine");
  result.put(MODE_SAVE_PROPERTIES, "Save properties");
  
  result.put(MODE_INC_SAMPLE_AREA, "Inc sample size");
  result.put(MODE_DEC_SAMPLE_AREA, "Dec sample size");

  result.put(MODE_MOVE_IMAGE, "Move image");
  result.put(MODE_CONVERT_BOX_TO_PICTUREFRAME, "Set frame");
  result.put(MODE_SELECT_PICTUREFRAME, "Select frame");
  
  result.put(MODE_EXPORT_QUEUE, "Export queue");
  result.put(MODE_IMPORT_QUEUE, "Import queue");
  result.put(MODE_FIT_IMAGE_TO_BOX, "Resize image");
  
  result.put(MODE_RENDER_COMMAND_QUEUE, "Preview queue");

  return result;
}

