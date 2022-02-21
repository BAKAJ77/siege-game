class Vector2
{
  float x, y;
  
  Vector2(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
  
  // Method for adding two vectors
  void AddVector(final Vector2 other)
  {
     this.x += other.x;
     this.y += other.y;
  }
  
  // Method for subtracting two vectors
  void SubtractVector(final Vector2 other)
  {
    this.x -= other.x;
    this.y -= other.y;
  }
  
  // Method for multiplying two vectors
  void MultiplyVector(final Vector2 other)
  {
    this.x *= other.x;
    this.y *= other.y;
  }
  
  void MultiplyVectorByScalar(float scalar)
  {
    this.x *= scalar;
    this.y *= scalar;
  }
  
  // Function that returns the length of the vector
  float GetLength() { return sqrt(pow(this.x, 2) + pow(this.y, 2)); }
}
