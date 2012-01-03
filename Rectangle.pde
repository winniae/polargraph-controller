class Rectangle
{
  public PVector position = null;
  public PVector size = null;
  
  public Rectangle(float px, float py, float width, float height)
  {
    this.position = new PVector(px, py);
    this.size = new PVector(width, height);
  }
  public Rectangle(PVector position, PVector size)
  {
    this.position = position;
    this.size = size;
  }
  
  public float getWidth()
  {
    return this.size.x;
  }
  public float getHeight()
  {
    return this.size.y;
  }
  public void setHeight(float h)
  {
    this.size.y = h;
  }
  public PVector getPosition()
  {
    return this.position;
  }
  public PVector getSize()
  {
    return this.size;
  }
  public PVector getTopLeft()
  {
    return getPosition();
  }
  public PVector getBotRight()
  {
    return PVector.add(this.position, this.size);
  }
  public float getLeft()
  {
    return getPosition().x;
  }
  public float getRight()
  {
    return getPosition().x + getSize().x;
  }
  public float getTop()
  {
    return getPosition().y;
  }
  public float getBottom()
  {
    return getPosition().y + getSize().y;
  }
  
  public void setPosition(float x, float y)
  {
    if (this.position == null)
      this.position = new PVector(x, y);
    else
    {
      this.position.x = x;
      this.position.y = y;
    }
  }
  
  public Boolean surrounds(PVector p)
  {
    if (p.x >= this.getLeft()
    && p.x < this.getRight()
    && p.y >= this.getTop()
    && p.y < this.getBottom())
      return true;
    else
      return false;
  }
  
}
