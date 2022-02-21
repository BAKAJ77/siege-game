class Explosion
{
  private Vector2 position;
  private float maxScale, currentScale, opacity;
  
  Explosion(float x, float y, float scale)
  {
    this.position = new Vector2(x, y);
    this.maxScale = scale;
    this.currentScale = 0;
    this.opacity = 255.0f;
  }
  
  // Updates the explosion animation state
  void Update()
  {
     if (this.currentScale < this.maxScale)
       this.currentScale += 6.0f;
     else
     {
       this.currentScale += 4.0f;
       this.opacity -= 8.0f; 
     }
  }
  
  // Renders the explosion
  void Render()
  {
    noStroke();
    fill(255, 255 * max((this.opacity / 255.0f), 0.0f), 0, this.opacity);
    ellipse(this.position.x, this.position.y, this.currentScale, this.currentScale);
  }
  
  // Getter function that returns the current opacity of the explosion
  final float GetOpacity() { return this.opacity; }
}
