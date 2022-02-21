import java.util.*;

abstract class Entity
{
  PImage entityTexture, missileTexture;
  protected Vector2 position, velocity;
  protected float scale, speed, health;
  protected ArrayList<Missile> projectiles;
  
  Entity(float x, float y, float speed, float scale, float health)
  {
    this.position = new Vector2(x, y);
    this.velocity = new Vector2(0, 0);
    this.speed = speed;
    this.scale = scale;
    this.health = health;
    
    this.projectiles = new ArrayList<Missile>();
    this.entityTexture = null;
    this.missileTexture = null;
  }
  
  // Modifies the value for the health member variable
  void SetHealth(float health) { this.health = health; }
  
  // Checks if the entity collided with a opposing projectile, if so then their health is deducted and the projectile is destroyed
  void CheckProjectileCollision(ArrayList<Missile> projectiles, ArrayList<Explosion> explosions)
  {
    Iterator it = projectiles.listIterator();

    while (it.hasNext())
    {
      Missile missile = (Missile)it.next();
      
      if (this.position.x + (this.scale / 2) >= missile.GetPosition().x - (missile.GetSize().x / 2) &&
          this.position.x - (this.scale / 2) <= missile.GetPosition().x + (missile.GetSize().x / 2) &&
          this.position.y + (this.scale / 2) >= missile.GetPosition().y - (missile.GetSize().y / 2) &&
          this.position.y - (this.scale / 2) <= missile.GetPosition().y + (missile.GetSize().y / 2))
       {
         this.health -= missile.GetDamage();
         explosions.add(new Explosion(missile.GetPosition().x, missile.GetPosition().y, 30));
         it.remove();
       }
    }
  }
  
  // Method for rendering the entity (has to be implemented by deriving classes)
  abstract void Render();
  
  // Getter function for accessing the position of the entity
  final Vector2 GetPosition() { return this.position; }
  
  // Getter function for accessing the velocity of the entity
  final Vector2 GetVelocity() { return this.velocity; }
  
  // Getter function for accessing the scale of the entity
  final float GetScale() { return this.scale; }
  
  // Getter function for accessing the maximum speed of the entity
  final float GetMaxSpeed() { return this.speed; }
  
  // Getter function for accessing the current health of the entity
  final float GetHealth() { return this.health; }
  
  // Getter function for accessing the array list of projectiles shot by the entity
  final ArrayList<Missile> GetProjectiles() { return this.projectiles; }
}
