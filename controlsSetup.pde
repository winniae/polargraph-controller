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
Set<String> getPanelNames()
{
  if (this.panelNames == null)
    this.panelNames = buildPanelNames();
  return this.panelNames;
}
List<String> getTabNames()
{
  if (this.tabNames == null)
    this.tabNames = buildTabNames();
  return this.tabNames;
}
Set<String> getControlNames()
{
  if (this.controlNames == null)
    this.controlNames = buildControlNames();
  return this.controlNames;
}
Map<String, List<Controller>> getControlsForPanels()
{
  if (this.controlsForPanels == null)
    this.controlsForPanels = buildControlsForPanels();
  return this.controlsForPanels;
}
Map<String, Controller> getAllControls()
{
  if (this.allControls == null)
    this.allControls = buildAllControls();
  return this.allControls;
}
Map<String, String> getControlLabels()
{
  if (this.controlLabels == null)
    this.controlLabels = buildControlLabels();
  return this.controlLabels;
}
Map<String, Set<Panel>> getPanelsForTabs()
{
  if (this.panelsForTabs == null)
    this.panelsForTabs = buildPanelsForTabs();
  return this.panelsForTabs;
}
Map<String, Panel> getPanels()
{
  if (this.panels == null)
    this.panels = buildPanels();
  return this.panels;
}


void hideAllControls()
{
  for (String key : allControls.keySet())
  {
    Controller c = allControls.get(key);
    c.hide();
  }
}

Map<String, Panel> buildPanels()
{
  Map<String, Panel> panels = new HashMap<String, Panel>();

  Rectangle panelOutline = new Rectangle(getMainPanelPosition(), new PVector((DEFAULT_CONTROL_SIZE.x+CONTROL_SPACING.x)*2, 300.0));
  Panel inputPanel = new Panel(PANEL_NAME_INPUT, panelOutline);
  inputPanel.setResizable(true);
  inputPanel.setOutlineColour(color(200,200,200));
  // get controls
  inputPanel.setControls(getControlsForPanels().get(PANEL_NAME_INPUT));
  // get control positions
  inputPanel.setControlPositions(buildControlPositionsForPanel(inputPanel));
  inputPanel.setControlSizes(buildControlSizesForPanel(inputPanel));
  panels.put(PANEL_NAME_INPUT, inputPanel);

//  Panel previewPanel = new Panel(PANEL_NAME_PREVIEW, panelOutline);
//  previewPanel.setOutlineColour(color(200,200,200));
//  // get controls
//  previewPanel.setResizable(true);
//  previewPanel.setControls(getControlsForPanels().get(PANEL_NAME_PREVIEW));
//  // get control positions
//  previewPanel.setControlPositions(buildControlPositionsForPanel(previewPanel));
//  previewPanel.setControlSizes(buildControlSizesForPanel(previewPanel));
//  panels.put(PANEL_NAME_PREVIEW, previewPanel);
  
  Panel detailsPanel = new Panel(PANEL_NAME_DETAILS, panelOutline);
  detailsPanel.setOutlineColour(color(200,200,200));
  // get controls
  detailsPanel.setResizable(true);
  detailsPanel.setControls(getControlsForPanels().get(PANEL_NAME_DETAILS));
  // get control positions
  detailsPanel.setControlPositions(buildControlPositionsForPanel(detailsPanel));
  detailsPanel.setControlSizes(buildControlSizesForPanel(detailsPanel));
  panels.put(PANEL_NAME_DETAILS, detailsPanel);

  Panel queuePanel = new Panel(PANEL_NAME_QUEUE, panelOutline);
  queuePanel.setOutlineColour(color(200,200,200));
  // get controls
  queuePanel.setResizable(true);
  queuePanel.setControls(getControlsForPanels().get(PANEL_NAME_QUEUE));
  // get control positions
  queuePanel.setControlPositions(buildControlPositionsForPanel(queuePanel));
  queuePanel.setControlSizes(buildControlSizesForPanel(queuePanel));
  panels.put(PANEL_NAME_QUEUE, queuePanel);

  panelOutline = new Rectangle(new PVector(getMainPanelPosition().x, getMainPanelPosition().y-(DEFAULT_CONTROL_SIZE.y+CONTROL_SPACING.y)), new PVector(DEFAULT_CONTROL_SIZE.x+CONTROL_SPACING.x, DEFAULT_CONTROL_SIZE.y+CONTROL_SPACING.y));
  Panel generalPanel = new Panel(PANEL_NAME_GENERAL, panelOutline);
  generalPanel.setResizable(false);
  generalPanel.setOutlineColour(color(200,200,200));
  // get controls
  generalPanel.setControls(getControlsForPanels().get(PANEL_NAME_GENERAL));
  // get control positions
  generalPanel.setControlPositions(buildControlPositionsForPanel(generalPanel));
  generalPanel.setControlSizes(buildControlSizesForPanel(generalPanel));
  panels.put(PANEL_NAME_GENERAL, generalPanel);
  
  return panels;
}

PVector getMainPanelPosition()
{
  return this.mainPanelPosition;
}

Map<String, Controller> buildAllControls()
{
  
  Map<String, Controller> map = new HashMap<String, Controller>();
  
  for (String controlName : getControlNames())
  {
    if (controlName.startsWith("button_"))
    {
      Button b = cp5.addButton(controlName, 0, 100, 100, 100, 100);
      b.setLabel(getControlLabels().get(controlName));
      b.hide();
      map.put(controlName, b);
//      println("Added button " + controlName);
    }
    else if (controlName.startsWith("toggle_"))
    {
      Toggle t = cp5.addToggle(controlName, false, 100, 100, 100, 100);
      t.setLabel(getControlLabels().get(controlName));
      t.hide();
      controlP5.Label l = t.captionLabel();
      l.style().marginTop = -17; //move upwards (relative to button size)
      l.style().marginLeft = 4; //move to the right
      map.put(controlName, t);
//      println("Added toggle " + controlName);
    }
    else if (controlName.startsWith("minitoggle_"))
    {
      Toggle t = cp5.addToggle(controlName, false, 100, 100, 100, 100);
      t.setLabel(getControlLabels().get(controlName));
      t.hide();
      controlP5.Label l = t.captionLabel();
      l.style().marginTop = -17; //move upwards (relative to button size)
      l.style().marginLeft = 4; //move to the right
      map.put(controlName, t);
//      println("Added minitoggle " + controlName);
    }
    else if (controlName.startsWith("numberbox_"))
    {
      Numberbox n = cp5.addNumberbox(controlName, 100, 100, 100, 100, 20);
      n.setLabel(getControlLabels().get(controlName));
      n.hide();
      n.setDecimalPrecision(0);
      controlP5.Label l = n.captionLabel();
      l.style().marginTop = -17; //move upwards (relative to button size)
      l.style().marginLeft = 40; //move to the right
      if (controlName.equals(MODE_CHANGE_SAMPLE_AREA))
      {
        n.setValue(getSampleArea());
        n.setMin(1);
        n.setMultiplier(1);
      }
      else if (controlName.equals(MODE_CHANGE_GRID_SIZE))
      {
        n.setValue(getGridSize());
        n.setMin(20);
        n.setMultiplier(5);
      }
      // change the control direction to left/right
      n.setDirection(Controller.VERTICAL);
      map.put(controlName, n);
//      println("Added numberbox " + controlName);
    }
  }
  
  initialiseMiniToggleValues(map);
  return map;
}

Map<String, Controller> initialiseMiniToggleValues(Map<String, Controller> map)
{
  for (String key : map.keySet())
  {
    if (MODE_SHOW_DENSITY_PREVIEW.equals(key))
    {
      Toggle t = (Toggle) map.get(key);
      t.setValue((displayingDensityPreview) ? 1 : 0);
    }
    if (MODE_SHOW_QUEUE_PREVIEW.equals(key))
    {
      Toggle t = (Toggle) map.get(key);
      t.setValue((displayingQueuePreview) ? 1 : 0);
    }
    if (MODE_SHOW_IMAGE.equals(key))
    {
      Toggle t = (Toggle) map.get(key);
      t.setValue((displayingImage) ? 1 : 0);
    }
    if (MODE_SHOW_VECTOR.equals(key))
    {
      Toggle t = (Toggle) map.get(key);
      t.setValue((displayingVector) ? 1 : 0);
    }
  }
  return map;
}




String getControlLabel(String butName)
{
  if (controlLabels.containsKey(butName))
    return controlLabels.get(butName);
  else
    return "";
}

Map<String, PVector> buildControlPositionsForPanel(Panel panel)
{
  Map<String, PVector> map = new HashMap<String, PVector>();
  String panelName = panel.getName();
  int col = 0;
  int row = 0;
  for (Controller controller : panel.getControls())
  {
    if (controller.name().startsWith("minitoggle_"))
    {
      PVector p = new PVector(col*(DEFAULT_CONTROL_SIZE.x+CONTROL_SPACING.x), row*(DEFAULT_CONTROL_SIZE.y+CONTROL_SPACING.y));
      map.put(controller.name(), p);
      row++;
      if (p.y + (DEFAULT_CONTROL_SIZE.y*2) >= panel.getOutline().getHeight())
      {
        row = 0;
        col++;
      }
    }
    else
    {
      PVector p = new PVector(col*(DEFAULT_CONTROL_SIZE.x+CONTROL_SPACING.x), row*(DEFAULT_CONTROL_SIZE.y+CONTROL_SPACING.y));
      map.put(controller.name(), p);
      row++;
      if (p.y + (DEFAULT_CONTROL_SIZE.y*2) >= panel.getOutline().getHeight())
      {
        row = 0;
        col++;
      }
    }
  }

  return map;
}
Map<String, PVector> buildControlSizesForPanel(Panel panel)
{
  Map<String, PVector> map = new HashMap<String, PVector>();
  String panelName = panel.getName();
  int col = 0;
  int row = 0;
  for (Controller controller : panel.getControls())
  {
    if (controller.name().startsWith("minitoggle_"))
    {
      PVector s = new PVector(DEFAULT_CONTROL_SIZE.y, DEFAULT_CONTROL_SIZE.y);
      map.put(controller.name(), s);
    }
    else
    {
      PVector s = new PVector(DEFAULT_CONTROL_SIZE.x, DEFAULT_CONTROL_SIZE.y);
      map.put(controller.name(), s);
    }
  }

  return map;
}


Map<String, List<Controller>> buildControlsForPanels()
{
  println("build controls for panels.");
  Map<String, List<Controller>> map = new HashMap<String, List<Controller>>();
  map.put(PANEL_NAME_INPUT, getControllersForControllerNames(getControlNamesForInputPanel()));
//  map.put(PANEL_NAME_PREVIEW, getControllersForControllerNames(getControlNamesForPreviewPanel()));
  map.put(PANEL_NAME_DETAILS, getControllersForControllerNames(getControlNamesForDetailPanel()));
  map.put(PANEL_NAME_QUEUE, getControllersForControllerNames(getControlNamesForQueuePanel()));
  map.put(PANEL_NAME_GENERAL, getControllersForControllerNames(getControlNamesForGeneralPanel()));
  return map;
}

List<Controller> getControllersForControllerNames(List<String> names)
{
  List<Controller> list = new ArrayList<Controller>();
  for (String name : names)
  {
    Controller c = getAllControls().get(name);
    if (c != null)
      list.add(c);
  }
  return list;
}

/* This creates a list of control names for the input panel. */
List<String> getControlNamesForInputPanel()
{
  List<String> controlNames = new ArrayList<String>();
  controlNames.add(MODE_CLEAR_QUEUE);
  controlNames.add(MODE_SET_POSITION_HOME);
  controlNames.add(MODE_SET_POSITION);
  controlNames.add(MODE_DRAW_TO_POSITION);
  controlNames.add(MODE_DRAW_DIRECT);
  controlNames.add(MODE_INPUT_BOX_TOP_LEFT);
  controlNames.add(MODE_INPUT_BOX_BOT_RIGHT);
  controlNames.add(MODE_CONVERT_BOX_TO_PICTUREFRAME);
  controlNames.add(MODE_SELECT_PICTUREFRAME);
  controlNames.add(MODE_LOAD_IMAGE);
  controlNames.add(MODE_MOVE_IMAGE);
  controlNames.add(MODE_FIT_IMAGE_TO_BOX);
  controlNames.add(MODE_RENDER_SQUARE_PIXELS);
  controlNames.add(MODE_RENDER_SCALED_SQUARE_PIXELS);
  controlNames.add(MODE_RENDER_SOLID_SQUARE_PIXELS);
  controlNames.add(MODE_RENDER_SCRIBBLE_PIXELS);
  controlNames.add(MODE_DRAW_TEST_PENWIDTH);
  controlNames.add(MODE_CHANGE_GRID_SIZE);
  controlNames.add(MODE_CHANGE_SAMPLE_AREA);
  controlNames.add(MODE_DRAW_GRID);
  controlNames.add(MODE_DRAW_OUTLINE_BOX);
  controlNames.add(MODE_DRAW_OUTLINE_BOX_ROWS);
  controlNames.add(MODE_DRAW_SHADE_BOX_ROWS_PIXELS);
  controlNames.add(MODE_SHOW_IMAGE);
  controlNames.add(MODE_SHOW_VECTOR);
  controlNames.add(MODE_SHOW_QUEUE_PREVIEW);
  controlNames.add(MODE_SHOW_DENSITY_PREVIEW);
  return controlNames;
}

List<String> getControlNamesForPreviewPanel()
{
  List<String> controlNames = new ArrayList<String>();
  controlNames.add(MODE_CLEAR_QUEUE);
  controlNames.add(MODE_SET_POSITION_HOME);
  controlNames.add(MODE_SET_POSITION);
  controlNames.add(MODE_DRAW_TO_POSITION);
  controlNames.add(MODE_INPUT_BOX_TOP_LEFT);
  controlNames.add(MODE_INPUT_BOX_BOT_RIGHT);
  controlNames.add(MODE_DRAW_OUTLINE_BOX);
  controlNames.add(MODE_MOVE_IMAGE);
  controlNames.add(MODE_RENDER_SQUARE_PIXELS);
  controlNames.add(MODE_RENDER_SCALED_SQUARE_PIXELS);
  controlNames.add(MODE_RENDER_SOLID_SQUARE_PIXELS);
  controlNames.add(MODE_RENDER_SCRIBBLE_PIXELS);
  controlNames.add(MODE_DRAW_TEST_PENWIDTH);
  controlNames.add(MODE_CHANGE_SAMPLE_AREA);
  controlNames.add(MODE_CHANGE_GRID_SIZE);
  return controlNames;
}

List<String> getControlNamesForDetailPanel()
{
  List<String> controlNames = new ArrayList<String>();
  controlNames.add(MODE_CHANGE_MACHINE_SPEC);
  controlNames.add(MODE_REQUEST_MACHINE_SIZE);
  controlNames.add(MODE_RESET_MACHINE);
  controlNames.add(MODE_CLEAR_QUEUE);
  controlNames.add(MODE_EXPORT_QUEUE);
  controlNames.add(MODE_IMPORT_QUEUE);
  return controlNames;
}

List<String> getControlNamesForQueuePanel()
{
  List<String> controlNames = new ArrayList<String>();
  controlNames.add(MODE_CLEAR_QUEUE);
  controlNames.add(MODE_EXPORT_QUEUE);
  controlNames.add(MODE_IMPORT_QUEUE);
  return controlNames;
}

List<String> getControlNamesForGeneralPanel()
{
  List<String> controlNames = new ArrayList<String>();
  controlNames.add(MODE_SAVE_PROPERTIES);
  return controlNames;
}



Map<String, String> buildControlLabels()
{
  Map<String, String> result = new HashMap<String, String>();

  result.put(MODE_BEGIN, "Reset queue");
  result.put(MODE_INPUT_BOX_TOP_LEFT, "Select TopLeft");
  result.put(MODE_INPUT_BOX_BOT_RIGHT, "Select BotRight");
  result.put(MODE_DRAW_OUTLINE_BOX, "Draw Outline box");
  result.put(MODE_DRAW_OUTLINE_BOX_ROWS, "Draw Outline rows");
  result.put(MODE_DRAW_SHADE_BOX_ROWS_PIXELS, "Draw Outline pixels");
  result.put(MODE_DRAW_TO_POSITION, "Move pen to point");
  result.put(MODE_DRAW_DIRECT, "Move direct");
  result.put(MODE_RENDER_SQUARE_PIXELS, "Shade Squarewave");
  result.put(MODE_RENDER_SCALED_SQUARE_PIXELS, "Shade Scaled Square");
  result.put(MODE_RENDER_SAW_PIXELS, "Shade sawtooth");
  result.put(MODE_RENDER_CIRCLE_PIXELS, "Shade circular");
  result.put(MODE_INPUT_ROW_START, "Select Row start");
  result.put(MODE_INPUT_ROW_END, "Select Row end");
  result.put(MODE_SET_POSITION, "Set pen position");
  result.put(MODE_DRAW_GRID, "Draw grid of box");
  result.put(MODE_DRAW_TESTPATTERN, "test pattern");
  result.put(MODE_PLACE_IMAGE, "place image");
  result.put(MODE_LOAD_IMAGE, "Load image file");
  result.put(MODE_INC_ROW_SIZE, "Rowsize up");
  result.put(MODE_DEC_ROW_SIZE, "Rowsize down");
  result.put(MODE_SET_POSITION_HOME, "Set home");
  result.put(MODE_INPUT_SINGLE_PIXEL, "Choose pixel");
  result.put(MODE_DRAW_TEST_PENWIDTH, "Test pen widths");
  result.put(MODE_RENDER_SOLID_SQUARE_PIXELS, "Shade solid");
  result.put(MODE_RENDER_SCRIBBLE_PIXELS, "Shade scribble");

  result.put(MODE_CHANGE_MACHINE_SPEC, "Upload machine spec");
  result.put(MODE_REQUEST_MACHINE_SIZE, "Download size spec");
  result.put(MODE_RESET_MACHINE, "Reset machine");
  result.put(MODE_SAVE_PROPERTIES, "Save properties");

  result.put(MODE_INC_SAMPLE_AREA, "Inc sample size");
  result.put(MODE_DEC_SAMPLE_AREA, "Dec sample size");

  result.put(MODE_MOVE_IMAGE, "Move image");
  result.put(MODE_CONVERT_BOX_TO_PICTUREFRAME, "Set frame");
  result.put(MODE_SELECT_PICTUREFRAME, "Select frame");

  result.put(MODE_CLEAR_QUEUE, "Clear queue");
  result.put(MODE_EXPORT_QUEUE, "Export queue");
  result.put(MODE_IMPORT_QUEUE, "Import queue");
  result.put(MODE_FIT_IMAGE_TO_BOX, "Resize image");

  result.put(MODE_RENDER_COMMAND_QUEUE, "Preview queue");

  result.put(MODE_CHANGE_GRID_SIZE, "Grid size");
  result.put(MODE_CHANGE_SAMPLE_AREA, "Sample area");
  
  result.put(MODE_SHOW_IMAGE, "Show image");
  result.put(MODE_SHOW_DENSITY_PREVIEW, "Show density preview");
  result.put(MODE_SHOW_QUEUE_PREVIEW, "Show Queue preview");
  result.put(MODE_SHOW_VECTOR, "Show Vector");
  
  return result;
}

Set<String> buildControlNames()
{
  Set<String> result = new HashSet<String>();
  result.add(MODE_BEGIN);
  result.add(MODE_INPUT_BOX_TOP_LEFT);
  result.add(MODE_INPUT_BOX_BOT_RIGHT);
  result.add(MODE_DRAW_OUTLINE_BOX);
  result.add(MODE_DRAW_OUTLINE_BOX_ROWS);
  result.add(MODE_DRAW_SHADE_BOX_ROWS_PIXELS);
  result.add(MODE_DRAW_TO_POSITION);
  result.add(MODE_DRAW_DIRECT);
  result.add(MODE_RENDER_SQUARE_PIXELS);
  result.add(MODE_RENDER_SCALED_SQUARE_PIXELS);
  result.add(MODE_RENDER_SAW_PIXELS);
  result.add(MODE_RENDER_CIRCLE_PIXELS);
  result.add(MODE_INPUT_ROW_START);
  result.add(MODE_INPUT_ROW_END);
  result.add(MODE_SET_POSITION);
  result.add(MODE_DRAW_GRID);
  result.add(MODE_DRAW_TESTPATTERN);
  result.add(MODE_PLACE_IMAGE);
  result.add(MODE_LOAD_IMAGE);
  result.add(MODE_INC_ROW_SIZE);
  result.add(MODE_DEC_ROW_SIZE);
  result.add(MODE_SET_POSITION_HOME);
  result.add(MODE_INPUT_SINGLE_PIXEL);
  result.add(MODE_DRAW_TEST_PENWIDTH);
  result.add(MODE_RENDER_SOLID_SQUARE_PIXELS);
  result.add(MODE_RENDER_SCRIBBLE_PIXELS);
  result.add(MODE_CHANGE_MACHINE_SPEC);
  result.add(MODE_REQUEST_MACHINE_SIZE);
  result.add(MODE_RESET_MACHINE);
  result.add(MODE_SAVE_PROPERTIES);
  result.add(MODE_INC_SAMPLE_AREA);
  result.add(MODE_DEC_SAMPLE_AREA);
  result.add(MODE_MOVE_IMAGE);
  result.add(MODE_CONVERT_BOX_TO_PICTUREFRAME);
  result.add(MODE_SELECT_PICTUREFRAME);
  result.add(MODE_CLEAR_QUEUE);
  result.add(MODE_EXPORT_QUEUE);
  result.add(MODE_IMPORT_QUEUE);
  result.add(MODE_FIT_IMAGE_TO_BOX);
  result.add(MODE_RENDER_COMMAND_QUEUE);
  
  result.add(MODE_CHANGE_GRID_SIZE);
  result.add(MODE_CHANGE_SAMPLE_AREA);
  
  result.add(MODE_SHOW_IMAGE);
  result.add(MODE_SHOW_DENSITY_PREVIEW);
  result.add(MODE_SHOW_VECTOR);
  result.add(MODE_SHOW_QUEUE_PREVIEW);
  
  return result;
}

