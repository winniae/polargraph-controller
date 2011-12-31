class DisplayMachine extends Machine
{
  private Scaler scaler = null;
  private PVector machineOffset = null;
  
  public DisplayMachine(Machine m, PVector offset, float scaling)
  {
    super.machineSize = m.machineSize;
    
    super.page = m.page;
    super.imageFrame = m.imageFrame;
    super.pictureFrame = m.pictureFrame;
    
    super.stepsPerRev = m.stepsPerRev;
    super.mmPerRev = m.mmPerRev;
      
    super.mmPerStep = m.mmPerStep;
    super.stepsPerMM = m.stepsPerMM;
    super.maxLength = m.maxLength;
    super.gridSize = m.gridSize;
    
    this.machineOffset = offset;
    this.scaler = new Scaler(scaling, super.getMMPerStep());
  }
}
