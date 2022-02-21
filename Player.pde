import java.util.*;

class Player extends Entity
{
  private float lastShotTimestamp; // Represents the time (in milliseconds) when the last projectile was fired by the player
  private float lastHealth, maxHealth;
  private float greenBoostTintEffect; // Used in animating boosting of the health bar
  private boolean playTintEffect; // Used in animating boosting of the health bar
  
  Explosion deathExplosion;
  
  Player(float x, float y, float speed, float scale, float health)
  {
    super(x, y, speed, scale, health);
    
    this.lastShotTimestamp = 0;
    this.lastHealth = this.health;
    this.maxHealth = this.health;
    this.greenBoostTintEffect = 0;
    this.playTintEffect = false;
    
    this.entityTexture = loadImage("Assets/tank.png");
    this.missileTexture = loadImage("Assets/tank_missile.png");
  }
  
  // Method that resets the player to maximum health specified
  void ResetHealth(float health)
  {
    this.health = health;
    this.lastHealth = health;
    this.maxHealth = health;
    this.playTintEffect = true;
  }
  
  // Method for making sure the player doesn't leave the scene's bounds
  private void CheckPlayerBoundsCollision()
  {
    if (this.position.x + (this.scale / 2) > 1500)
      this.position.x = 1500 - (this.scale / 2);
    else if (this.position.x - (this.scale / 2) < 0)
      this.position.x = (this.scale / 2);
  }
  
  // Method for handling movement of the player
  private void Move(final boolean keysPressed[])
  {
    if (keysPressed[LEFT] || keysPressed['a'] || keysPressed['A'])
      this.velocity.x = -this.speed;
    else if (keysPressed[RIGHT] || keysPressed['d'] || keysPressed['D'])
      this.velocity.x = this.speed;
    else
      this.velocity.x = 0.0f;
  }
  
  // Method which checks if the player's collided with an enemy, if so then the enemy is destroyed and the player's health is decreased
  void CheckEnemyCollision(final ArrayList<Enemy> enemies, ArrayList<Explosion> explosions, float difficulty)
  {
    Iterator it = enemies.listIterator();
    
    while (it.hasNext())
    {
      Enemy enemy = (Enemy)it.next();
      
      if (this.position.x + (this.scale / 2) >= enemy.position.x - (enemy.scale / 2) &&
          this.position.x - (this.scale / 2) <= enemy.position.x + (enemy.scale / 2) &&
          this.position.y + (this.scale / 2) >= enemy.position.y - (enemy.scale / 2) &&
          this.position.y - (this.scale / 2) <= enemy.position.y + (enemy.scale / 2))
       {
         this.health -= 40 + (difficulty * 50); 
         explosions.add(new Explosion(enemy.GetPosition().x, enemy.GetPosition().y, 75));
         it.remove();
       }
    }
  }
  
  // Method that shoots a missile projectile in the direction of oncoming enemies
  void ShootMissileProjectile(final boolean keysPressed[])
  {
    final float projectileCooldown = 400.0f;
    if (keysPressed[' '] && (millis() - this.lastShotTimestamp >= projectileCooldown))
    {
      this.projectiles.add(new Missile(this.position.x, this.position.y + (this.scale / 2), 5, 100));
      this.lastShotTimestamp = millis();
    }
  }
  
  // Method that handles the animation of the health bar when decreasing
  void PlayHealthBarAnimation()
  {
    if (this.lastHealth > this.health)
    {
      if (this.lastHealth - (this.maxHealth / 100.0f) < this.health)
        this.lastHealth = this.health;
      else
        this.lastHealth -= (this.maxHealth / 100.0f); 
    }
    else if (this.lastHealth < this.health)
    {
      if (this.lastHealth + (this.maxHealth / 100.0f) > this.health)
        this.lastHealth = this.health;
      else
        this.lastHealth += (this.maxHealth / 100.0f);  
    }
  }
   
  // Method that tracks the largest amount of health the player had
  void UpdateMaximumHealth()
  {
    if (this.maxHealth < this.health)
      this.maxHealth = this.health;
  }
  
  // Method that animates the bar to indicate that it has been reset and boosted
  void PlayHeathBarResetAnimation()
  {
    if (this.playTintEffect && this.greenBoostTintEffect < 105)
      this.greenBoostTintEffect += 2.5f;
    else if (this.playTintEffect && this.greenBoostTintEffect == 105)
      this.playTintEffect = false;
    else if (!this.playTintEffect && this.greenBoostTintEffect > 0)
      this.greenBoostTintEffect -= 2.5f;
  }
  
  // Method for updating the player state e.g. position, health etc.
  void Update(final boolean keysPressed[], ArrayList<Enemy> enemies, ArrayList<Explosion> explosions, float difficulty)
  {
    // Update health bar state
    this.UpdateMaximumHealth();
    this.PlayHealthBarAnimation();
    this.PlayHeathBarResetAnimation();
    
    // Update the player state
    this.Move(keysPressed);
    this.ShootMissileProjectile(keysPressed);
    this.position.AddVector(this.velocity);
    
    for (Enemy enemy : enemies)
      this.CheckProjectileCollision(enemy.GetProjectiles(), explosions);
    
    // Do collision detections
    this.CheckPlayerBoundsCollision();
    this.CheckEnemyCollision(enemies, explosions, difficulty);
    
    // Update the projectiles shot by the player
    for (Missile missile : this.projectiles)
      missile.Update(); 
      
    // Destroy projectiles that have left scene bounds
    Iterator missileIt = this.projectiles.listIterator();
    while (missileIt.hasNext())
    {
      Missile missile = (Missile)missileIt.next();
      if(missile.GetPosition().y - (missile.GetSize().y / 2) >= 900)
        missileIt.remove();
    }
      
    // Update death explosion (if the player has been destroyed i.e the health is fully depleted)
    if (this.deathExplosion != null)
      this.deathExplosion.Update();
    
    // Exit game application if the player's health has fully depleted
    if (this.health <= 0 && this.deathExplosion == null)
      this.deathExplosion = new Explosion(this.position.x, this.position.y, 150);
    
    // Exit once death explosion animation has played
    if (this.deathExplosion != null && this.deathExplosion.GetOpacity() <= 0)
        exit();
  }
  
  // Override method for rendering the player
  @Override
  void Render()
  { 
    imageMode(CENTER);
    
    // Render the projectiles shot by the player
    for (Missile missile : this.projectiles)
      missile.Render(this.missileTexture); 
    
    // Render the player
    if (this.health > 0)
      image(this.entityTexture, this.position.x, this.position.y, this.scale, this.scale);
    
    // Render the health bar
    if ((this.health / this.maxHealth) * 100 >= 65) // Health bar is rendered as green
      fill(0, 150 + this.greenBoostTintEffect, 0);
    else if ((this.health / this.maxHealth) * 100 >= 40) // Health bar is rendered as yellow
      fill(255, 255, 0);
    else // Health bar is rendered as red
      fill(255, 0, 0);
    
    noStroke();
    rectMode(CORNER);
    rect(1525, 875, 50, -max((((this.lastHealth / this.maxHealth) * 100.0f) * 8.5f), 0.0f));
    
    // Draws the outer shell of the health bar
    noFill();
    stroke(0, 0, 225);
    strokeWeight(5);
    rect(1525, 25, 50, 850);
    
    // Render death explosion (if the player has been destroyed i.e the health is fully depleted)
    if (this.deathExplosion != null)
      this.deathExplosion.Render();
  }
  
  // Getter function that returned the maximum health of the player
  final float GetMaximumHealth() { return this.maxHealth; }
}
