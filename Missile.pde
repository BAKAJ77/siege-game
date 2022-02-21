class Missile
{
  private Vector2 position, size;
  private float speed, damage;
  
  Missile(float x, float y, float speed, float damage)
  {
    this.position = new Vector2(x, y);
    this.size = new Vector2(15, 45); // The size is hard-coded
    this.speed = speed;
    this.damage = damage;
  }
  
  // Updates the state of the missile
  void Update()
  {
    this.position.y += speed;
  }
  
  // Method that renders the missile
  void Render(final PImage missileTexture)
  {
    imageMode(CENTER);
    image(missileTexture, this.position.x, this.position.y, this.size.x, this.size.y);
  }
  
  // Getter function that returns the position of the missile
  final Vector2 GetPosition() { return this.position; }
  
  // Getter function that returns the size of the missile
  final Vector2 GetSize() { return this.size; }
  
  // Getter function that returns the speed of the missile
  final float GetSpeed() { return this.speed; }
  
  // Getter function that returns the damage level of the missile
  final float GetDamage() { return this.damage; } 
}
