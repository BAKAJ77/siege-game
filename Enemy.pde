import java.util.*;

class Enemy extends Entity
{
  private float lastShotTime, attackDamage;
  private float shootingFrequency; // The frequency (in milliseconds) that enemies shoot missiles
  boolean destroyed;
  
  Enemy(float x, float y, float speed, float scale, float health, float shootingFrequency, float damage)
  {
    super(x, y, speed, scale, health); 
    this.shootingFrequency = shootingFrequency;
    this.lastShotTime = 0;
    this.destroyed = false;
    this.attackDamage = damage;
    
    this.entityTexture = loadImage("Assets/jet.png");
    this.missileTexture = loadImage("Assets/jet_missile.png");
  }
  
  // Moves the enemy upwards
  void Move()
  {
    this.velocity.y = -this.speed; 
  }
  
  // Method which handles the enemy shooting missiles at the player
  void ShootMissileProjectile(final Player player)
  {
    if ((millis() - this.lastShotTime) >= this.shootingFrequency && abs(this.position.x - player.position.x) <= this.scale)
    {
      this.projectiles.add(new Missile(this.position.x, this.position.y - (this.scale / 2), -5, this.attackDamage)); 
      this.lastShotTime = millis();
    }
  }
  
  // Updates the state of the enemy
  void Update(ArrayList<Missile> playerProjectiles, final Player player)
  {
    // Update state of missiles shot by enemy
    for (Missile missile : this.projectiles)
      missile.Update();
      
    // Destroy projectiles that have left scene bounds
    Iterator missileIt = this.projectiles.listIterator();
    while (missileIt.hasNext())
    {
      Missile missile = (Missile)missileIt.next();
      if(missile.GetPosition().y + (missile.GetSize().y / 2) <= 0)
        missileIt.remove();
    }
    
    // Do collision checks and update enemy position
    if (!this.destroyed)
    {
      this.Move();
      this.ShootMissileProjectile(player);
      this.CheckProjectileCollision(playerProjectiles, explosions);
      this.position.AddVector(this.velocity); 
    }
  }
  
  // Override method for rendering the enemy
  @Override
  void Render()
  {
    if (!this.destroyed)
    {
      imageMode(CENTER);
      image(this.entityTexture, this.position.x, this.position.y, this.scale, this.scale); 
    }
    
    // Render state of missiles shot by enemy
    for (Missile missile : this.projectiles)
      missile.Render(this.missileTexture);
  }
}
