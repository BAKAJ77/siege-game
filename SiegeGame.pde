import processing.opengl.*;
import java.util.*;

///////////////////////// Globals //////////////////////////

final int maxEnemies = 4;
float previousExplosionTime = 0.0f; // This is for the despawn line explosion effect animation
int difficulty = 0, currentScore = 0, lastScoreMilestone = 0, spawnExplosionIndex = -1;

Player player;
ArrayList<Enemy> enemies;
ArrayList<Explosion> explosions;
PImage backgroundTexture;

boolean pressedKeys[];

/////////////////////// Main methods ///////////////////////

// Called only once to setup objects
void setup()
{
  size(1600, 900, OPENGL); // Setup the window size and enable OpenGL rendering (game runs smoother with it)
  pressedKeys = new boolean[256]; // This array is for recording which keys are currently being pressed
  enemies = new ArrayList<Enemy>();
  explosions = new ArrayList<Explosion>();
  backgroundTexture = loadImage("Assets/background.jpg");
  
  player = new Player(400, 100, 15.0f, 100, 100);
}

// Called 60 times per second for updating/rendering objects
void draw()
{
  // Boost game difficulty and player's health for every 500 points they score
  BoostGameDifficulty();
  
  // Clear screen and handle spawning/despawning of enemies
  background(0);
  SpawnEnemies(maxEnemies);
  DespawnEnemies();
  
  // Render the background texture
  imageMode(CORNER);
  image(backgroundTexture, 0, 0, 1600, 900);
  
  // Update and render the enemies
  for (Enemy enemy : enemies)
  {
    enemy.Update(player.GetProjectiles(), player);
    enemy.Render();
  }
  
  // Update and render the player
  player.Update(pressedKeys, enemies, explosions, difficulty);
  player.Render();
  
  // Render the explosion animation (this only occurs if a enemy collides with the despawn line)
  PlayLineExplosionAnimation();
  
  // Update and render the explosions
  Iterator explosionIt = explosions.listIterator();
  while (explosionIt.hasNext())
  {
    Explosion explosion = (Explosion)explosionIt.next();
    
    explosion.Update();
    explosion.Render();
    
    if (explosion.GetOpacity() <= 0)
      explosionIt.remove();
  }
  
  // Render the current score and level
  RenderGameText();
}

// Called when a key is pressed
void keyPressed()
{
  if (key == CODED)
    pressedKeys[keyCode] = true;
  else
    pressedKeys[key] = true;
}

// Called when a key is released
void keyReleased()
{
  if (key == CODED)
    pressedKeys[keyCode] = false;
  else
    pressedKeys[key] = false; 
}

////////////////////////////////////////////////////////////

// Method for spawning new enemies if there is less than 4 on the scene
void SpawnEnemies(int maxEnemiesAlive)
{
  while (true)
  {
    if (enemies.size() < maxEnemiesAlive)
    {
      float xPosition = random(100, 1400);
      boolean positionValid = true;
      
      // Make sure enemies aren't spawned too close to each other
      for (Enemy enemy : enemies)
      {
        if (abs(enemy.GetPosition().x - xPosition) <= enemy.GetScale() * 2.0f)
        {
          positionValid = false;
          break;
        }
      }
      
      if (positionValid)
        enemies.add(new Enemy(xPosition, 950, 0.5f + (difficulty * 0.05f), 100, 100 + (difficulty * 25), max(2000 - (difficulty * 250), 250), 40 + (difficulty * 50)));
    }
    else
      break;
  }
}

// Method for despawning enemies in the scene
void DespawnEnemies()
{
  Iterator enemyIt = enemies.listIterator();
  while (enemyIt.hasNext())
  {
    Enemy enemy = (Enemy)enemyIt.next();
    
    // Despawn the enemy if it reaches despawn line
    if ((enemy.GetPosition().y - (enemy.GetScale() / 2)) <= 0)
    {
      enemyIt.remove(); 
      player.SetHealth(player.GetHealth() - (difficulty * 500)); // These line explosions damage the player
      
      if (spawnExplosionIndex < 0) // Start the line explosion animation
        spawnExplosionIndex = 0;
    }
    else if (enemy.GetHealth() <= 0 && !enemy.destroyed) // Mark the enemy as destroyed if it's health has fully depleted
    {
      explosions.add(new Explosion(enemy.GetPosition().x, enemy.GetPosition().y, 75));
      enemy.destroyed = true;
      currentScore += 50;
    }
    
    // Remove the enemy from the list if the enemy and the projectiles shot by the enemy have been destroyed 
    if (enemy.destroyed && enemy.GetProjectiles().isEmpty())
      enemyIt.remove();
  }
}

// Method that plays an animation where a line of explosions are detonated behind the player when the enemy reaches the despawn point
void PlayLineExplosionAnimation()
{
  float explosionBoundX = 1600.0f;
  float explosionPosX = spawnExplosionIndex * 50.0f;
  final float explosionWaitTime = 25.0f;
  
  // The animation is only played if the explosion spawn index is larger than -1 (this offers the flexibility to start and stop the animation when we want)
  if (explosionPosX <= explosionBoundX && (millis() - previousExplosionTime >= explosionWaitTime) && spawnExplosionIndex > -1)
  {
    explosions.add(new Explosion(explosionPosX, 0, 125));
    previousExplosionTime = millis();
    spawnExplosionIndex++;
  }
  else if (explosionPosX > explosionBoundX)
    spawnExplosionIndex = -1;
}

// Method that boosts the health of the player and increases the game difficulty every 500 points that are scored
void BoostGameDifficulty()
{
  if (currentScore % 1000 == 0 && currentScore > lastScoreMilestone)
  {
    player.ResetHealth(player.GetMaximumHealth() * 1.5f); // Double the max health of the player
    lastScoreMilestone = currentScore;
    difficulty++;
  }
  else if (currentScore % 500 == 0 && currentScore > lastScoreMilestone)
  {
    // Double the current health of the player
    if (player.GetHealth() == player.GetMaximumHealth())
      player.ResetHealth(player.GetHealth() * 1.5f);
    else
    {
      if (player.GetHealth() * 2.0f > player.GetMaximumHealth())
        player.ResetHealth(player.GetHealth() * 2.0f); 
      else
        player.SetHealth(player.GetHealth() * 1.5f); 
    }
      
    lastScoreMilestone = currentScore;
  }
}

// Method for rendering the score and level text
void RenderGameText()
{
  fill(0, 0, 255);
  
  textSize(50);
  text("LEVEL: " + (difficulty + 1), 25, 825);
  text("SCORE: " + currentScore, 25, 875);
}

////////////////////////////////////////////////////////////
