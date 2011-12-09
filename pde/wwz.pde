// Words with Zombies - Gravity Hackathon Prototype

// Preload images
/* @pjs preload="img/player.jpg,img/zombie.jpg,img/background-ground.jpg"; */

// Attribs
////////////////////////////////////////////////////////////////////////////////////////////////////

// Game setup
int width     = 960;
int height    = 640;
int framerate = 15;

// Colours
color sky = #5BA0FA;
color ground = #07A91F;

// Game Elements
int deadZombies   = 0;
ArrayList zombies = new ArrayList();
Player player     = new Player();
ArrayList bullets = new ArrayList();

// Game state
boolean active = false;
int currentLevelNumber = 1;
Level currentLevel;
int nextZombieInterval = 0;

// Score counters
int totalScore = 0;
int levelScore = 0;
int totalKills = 0;
int levelKills = 0;

// Setup
////////////////////////////////////////////////////////////////////////////////////////////////////
void setup()
{
    size(width, height);
    frameRate(framerate);
    setupBackground();
    
    // Load current level
    getLevel(currentLevelNumber);
}

// Helper Functions
////////////////////////////////////////////////////////////////////////////////////////////////////

// Start and stop animation processing
void stop()
{
    var instance = Processing.getInstanceById("wwz");
    instance.noLoop();
}

void start()
{
    var instance = Processing.getInstanceById("wwz");
    instance.loop();
}

// Drawing
////////////////////////////////////////////////////////////////////////////////////////////////////

void setupBackground()
{    
    background(sky); // Draw the sky
  
    // Draw the ground
    fill(ground);
    noStroke();
    rect(0, height - 200, width, 200);
    
    // Render the score
    font = loadFont("serif"); 
    textFont(font);
    fill(0);
    textSize(20);
    textAlign(RIGHT);
    text("Score: " + totalScore + " Kills: " + totalKills + " ", width, 20);
}

// Game over
void gameOver()
{
    background(0);
    fill(255);
    
    font = loadFont("serif"); 
    textFont(font);
    textSize(50);
    textAlign(CENTER);
    text("GAME OVER", width / 2, height / 2);
    
    textSize(30);
    textAlign(CENTER);
    text("Final Score: " + totalScore + " Kills: " + totalKills, width / 2, (height / 2) + 40);
    
    textSize(20);
    textAlign(CENTER);
    text("(you suck)", width / 2, (height / 2) + 75);
}

// End of Level
void endOfLevel()
{
    background(0);
    fill(255);
    
    font = loadFont("serif"); 
    textFont(font);
    textSize(50);
    textAlign(CENTER);
    text("Level " + currentLevelNumber + " completed!", width / 2, height / 2);
    
    textSize(30);
    textAlign(CENTER);
    text("Score: " + levelScore + " (Total: " + totalScore + ") Kills: " + levelKills + " (Total: " + totalKills + ")", width / 2, (height / 2) + 40);
    
    textSize(20);
    textAlign(CENTER);
    text("Press any key to continue", width / 2, (height / 2) + 75);
}

// Completed the game!!
void completedGame()
{
    background(0);
    fill(255);
    
    font = loadFont("serif"); 
    textFont(font);
    textSize(50);
    textAlign(CENTER);
    text("You completed the game! Well done!", width / 2, height / 2);
    
    textSize(30);
    textAlign(CENTER);
    text("Final Score: " + totalScore + " Kills: " + totalKills, width / 2, (height / 2) + 40);
}

// Main Program Loop
////////////////////////////////////////////////////////////////////////////////////////////////////
void draw()
{
    // Don't run while game isn't active.
    if (!active) { return; }

    // If end of level
    if (currentLevel.isComplete())
    {
        active = false;
        
        stop(); // Stop the game
        
        endOfLevel();
        return;
    }

    // If Player is dead, then it's game over.
    if (player.isDead())
    {
        stop();        
        gameOver();
        return; 
    }
    
    // If interval is up, introduce another zombie.
    if (nextZombieInterval == 0)
    {
        updateNextZombieInterval();        
        Zombie z = currentLevel.getNextZombie();
                
        // If more zombies, add them.
        if (z != null) { zombies.add(z); }
    }
    
    // If no more zombies, and all zombies dead
    if (zombies.size() == deadZombies
        && !currentLevel.isMoreZombies()) { currentLevel.complete(); }
    
    if (currentLevel.isComplete()) { return; }
        
    // Redraw background
    setupBackground();
    
    // Draw the player
    player.run();
    
    // Draw current zombies 
    for (int i = 0; i < zombies.size(); i++) { zombies.get(i).run(); }
    
    // Draw all dead zombies
    //for (int i = 0; i < deadZombies.size(); i++) { deadZombies.get(i).draw(); }
    
    // Draw bullets
    for (int i = 0; i < bullets.size(); i++) { bullets.get(i).run(); }
    
    nextZombieInterval--;
}

// Capture keyboard events
////////////////////////////////////////////////////////////////////////////////////////////////////
void keyReleased() 
{
    // If in not active state
    if (!active)
    {
        // Start the next level
        currentLevelNumber++;
        getLevel(currentLevelNumber);
        return;
    }
    
    // Fire a bullet
    bullets.add(new Bullet(str(key)));
}

// Level Loading
////////////////////////////////////////////////////////////////////////////////////////////////////
void loadLevel(params)
{
    // Params are in form "WORD SPEED\n";
    
    // Create a new leveg
    currentLevel = new Level(currentLevelNumber);
    
    // Go over each line
    var words = params.split("\n");
    for (var i in words)
    {
        if (words[i] == "") { continue; }
        
        var segments = words[i].split(" ");
        Zombie z = new Zombie(segments[0], segments[1]);
        currentLevel.addZombie(z);
    }
    
    // Start the level
    currentLevel.start();
}

void loadLevelFailed()
{
    completedGame();
    stop();
}

// Level
////////////////////////////////////////////////////////////////////////////////////////////////////
class Level
{
    ArrayList levelZombies = new ArrayList();
    
    int num;
    boolean completed = false;
    
    int currentZombie = 0;
    
    // ctor   
    Level(int levelNumber) 
    {
        num = levelNumber;
    }
    
    // Add a zombie
    void addZombie(Zombie z) { levelZombies.add(z); }
    
    // Start the level
    void start()
    {
        // Clear previous zombies
        deadZombies = 0;
        zombies = new ArrayList();
        nextZombieInterval = 0;
        
        // Clear level score counters
        levelScore = 0; levelKills = 0;
                
        // Randomize zombies!
        var shuffled = levelZombies.toArray();        
        for (int i = 0; i < levelZombies.size(); i++)
        {
            int n = Math.floor(Math.random()*levelZombies.size());
            var tmp = shuffled[n];
            shuffled[n] = shuffled[i];
            shuffled[i] = tmp;
        }
        
        // This is horrible, fuck it.
        levelZombies = new ArrayList();
        for (int i = 0; i < shuffled.length; i++)
        {
            levelZombies.add(shuffled[i]);
        }
                
        // Get the next zombie and start the level
        active = true;
        
        // Restart the loop
        start();
    }
    
    // Member functions
    boolean isComplete() { return completed; }
    int totalZombies() { return levelZombies.size(); }
    void complete() 
    {
        completed = true; 
    }
    
    boolean isMoreZombies() { return (currentZombie != levelZombies.size()); }
    Zombie getNextZombie()
    {    
        // No more zombies!
        if (currentZombie == levelZombies.size()) { return null; }
        
        // Otherwise, return next zombie and increment counter
        Zombie z = levelZombies.get(currentZombie);
        currentZombie++;
        return z;
    }
}

// Player
////////////////////////////////////////////////////////////////////////////////////////////////////
class Player
{
    int front; // Front of player, for collision detection.
    boolean dead = false;

    int pWidth = 160;
    int pHeight = 200;
    int bulletHeight = 150; // from bottom
    
    int x = 50;
    int y = height - 250;

    // Empty ctor
    Player()
    {
        front = x + (pWidth / 2);
    }
   
    void run()
    {
        draw();  // Just redraw the player in place for now
    }
    
    void draw()
    {
        PImage p = loadImage("img/player.jpg");
        image(p,  x - (pWidth / 2), y - (pHeight / 2));
    }
    
    // Member functions
    int getBulletHeight() { return y + (pHeight / 2) - bulletHeight; }
    int getX()            { return x; }
    int getY()            { return y; }
    int getFront()        { return front; }
    void kill()           { dead = true; }
    boolean isDead()      { return dead; }
}

// Zombie
////////////////////////////////////////////////////////////////////////////////////////////////////
class Zombie
{
    // Members
    float speed;
    String word;
    boolean dead = false;
    
    // Hit/NotHit
    String hit = "";
    String nothit = "";
    
    // Current coords of the zombie
    int x;
    int y;
    
    // So we can tweak values later
    int zWidth = 137;
    int zHeight = 200;
    
    int heightOffset = 0; // Random height offset to give 3d-ish appearance
    
    // Ctor
    Zombie(String w, float s)
    {
        speed = s;
        word  = w;
        nothit = word;
        
        heightOffset = (Math.random()*100) - 70;
        
        // Initial position
        x = width;
        y = height - (zHeight / 2) - 100 + heightOffset;
    }
    
    // Main activity loop for the zombie
    void run()
    {
        update();
        draw();
    }
    
    // Draws a zombie object
    void draw()
    {
        // Alive Zombie
        if (!dead)
        {  
            // Draw zombie
            PImage b = loadImage("img/zombie.jpg");
            image(b, x - (zWidth / 2), y - (zHeight / 2));
            
            // Draw the word above the zombie
            font = loadFont("monospace");
            fill(0); 
            textFont(font);
            textAlign(LEFT);
            textSize(50);
            text(hit, x - (textWidth(word) / 2), y - (zHeight / 2) - 15);
                        
            fill(255);
            text(nothit, x - (textWidth(word) / 2) + textWidth(hit) , y - (zHeight/2) - 15); 
        }
        // Dead Zombie
        else
        {
            // Draw dead zombie              
            fill(255, 0, 0);
            stroke(255);
            ellipse(x, y, 100, 10);
        }
    }
    
    // Updates the position and state of a zombie object
    void update()
    {
        // Dead zombie can't update
        if (dead) { return; }
    
        // if goes off left side, then kill self.
        if (x <= 0) { kill(); }
    
        // If collides with player, then kill player
        if (x <= player.getFront()) { player.kill(); }
    
        x -= speed;      
    }    
    
    // Attempt to "hit" zombie with key
    void tryToHit(k)
    {        
        // Is it a hit?
        if (nothit.indexOf(k) == 0)
        {
            hit += nothit.charAt(0);
            nothit = nothit.substring(1);
            
            totalScore++;
            levelScore++;
        
            // Determine if zombie should die
            if (nothit == "") 
            { 
                kill(); 
                totalScore += 10;
                levelScore += 10;
                totalKills++;
                levelKills++;
            }
            
            return true;
        }
        
        return false;
    }
    
    // Member funcs
    int getWidth() { return zWidth; }
    int getHeight() { return zHeight; }
    String getWord() { return word; }
    int getSpeed() { return speed; }
    int getX() { return x; }
    
    // Zombie is killed
    void kill() 
    { 
        deadZombies++;
        dead = true; 
        
        // Lower to ground
        y += 160;
        zHeight -= 20;
    }
    
    // Check if dead
    boolean isDead() { return dead; }
}

void updateNextZombieInterval()
{
    nextZombieInterval = Math.floor(Math.random() * (framerate * 2)) + (framerate * 1);
}

// Bullet
////////////////////////////////////////////////////////////////////////////////////////////////////
class Bullet
{
    int speed = 100;
    var key;
    int x;

    // ctor
    Bullet(String k) 
    {
        key = k;        
        x = player.getFront();
    }
    
    void draw()
    {         
        fill(0);
        stroke(0);
        ellipse(x, player.getBulletHeight(), 15, 5);
    }
    
    void run()
    {
        draw();
        x += speed;
       
        if (x >= width)
        {
            bullets.remove(0);
        }
        
        for ( int i = 0; i < zombies.size(); i++)
        {
            Zombie z = zombies.get(i);
            if (z.isDead()) { continue; }
            if (x >= z.getX())
            {
                if (z.tryToHit(key))
                {
                    bullets.remove(0);
                    break;
                }
            }
        }
    }
}
