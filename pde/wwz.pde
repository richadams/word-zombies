// Words with Zombies - Gravity Hackathon Prototype

// Attribs
////////////////////////////////////////////////////////////////////////////////////////////////////
color sky = #5BA0FA;
color ground = #07A91F;

int width  = 960;
int height = 640;

int framerate = 15;

ArrayList deadZombies = new ArrayList();
Zombie currentZombie;
Player player = new Player();

// Is game active yet?
boolean active = false;

int currentLevelNumber = 1;
Level currentLevel;

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

// Sets up the background
void setupBackground()
{    
    background(sky); // Draw the sky
  
    // Draw the ground
    fill(ground);
    noStroke();
    rect(0, height - 200, width, 200);
}

// Game over
////////////////////////////////////////////////////////////////////////////////////////////////////
void gameOver()
{
    background(0);
    fill(255);
    
    font = loadFont("serif"); 
    textFont(font);
    textSize(50);
    textAlign(CENTER);
    text("GAME OVER", width / 2, height / 2);
    
    textSize(20);
    textAlign(CENTER);
    text("(you suck)", width / 2, (height / 2) + 55);
}

// Main Program Loop
////////////////////////////////////////////////////////////////////////////////////////////////////
void draw()
{
    // Don't run while game isn't active.
    if (!active) { return; }

    // If Player is dead, then it's game over.
    if (player.isDead())
    {
        // Stop the game
        var instance = Processing.getInstanceById('wwz');
        instance.noLoop();
        
        gameOver();
        return; 
    }

    // If there's no zombie or our zombie died, introduce a new one
    if (currentZombie == null 
        || currentZombie.isDead())
    {
        currentZombie = currentLevel.getNextZombie();
        //new Zombie(words[currentWord], 25);
        
        // If there are no more words, ?? level over?
    }
    
    // Redraw background
    setupBackground();
    
    // Draw the player
    player.run();
    
    // Draw current zombie    
    currentZombie.run();
    
    // Draw all dead zombies
    for (int i = 0; i < deadZombies.size(); i++) { deadZombies.get(i).draw(); }
}

// Capture keyboard events
////////////////////////////////////////////////////////////////////////////////////////////////////
void keyReleased() 
{
    if (str(key).toUpperCase() == "Q")
    { 
        // Kill current zombie
        currentZombie.kill();
    }
}


// Level Loading
////////////////////////////////////////////////////////////////////////////////////////////////////
void loadLevel(params)
{
    // Params are in form "WORD SPEED\n";
    
    // Create a new leve
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
    alert("Unable to load level data");
}

// Level
////////////////////////////////////////////////////////////////////////////////////////////////////
class Level
{
    ArrayList zombies = new ArrayList();
    
    int num;
    boolean complete = false;
    
    int currentZombie = 0;
    
    // ctor   
    Level(int levelNumber) 
    {
        num = levelNumber;
    }
    
    // Add a zombie
    void addZombie(Zombie z) 
    { 
        //alert("Adding zombie - " + z.getWord() + ", " + z.getSpeed());
        zombies.add(z); 
    }
    
    // Start the level
    void start()
    {
        zombie = getNextZombie();
        active = true;
    }
    
    // Member functions
    boolean isComplete() { return complete; }
    void complete() { complete = true; }
    Zombie getNextZombie()
    {
        // No more zombies!
        if (currentZombie == zombies.size)
        {
            complete();
            return null;
        }
        
        // Otherwise, return next zombie and increment counter
        Zombie z = zombies.get(currentZombie);
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

    // Empty ctor
    Player()
    {
        front = 120;
    }

    // Just redraw the player in place for now
    void run()
    {    
        fill(0);
        stroke(255);
        ellipse(40, height-300, 50, 50);        
    }
    
    // Member functions
    int getFront() { return front; }
    void kill() { dead = true; }
    boolean isDead() { return dead; }
}

// Zombie
////////////////////////////////////////////////////////////////////////////////////////////////////
class Zombie
{
    // Members
    float speed;
    String word;
    boolean dead = false;
    
    // Current coords of the zombie
    int x;
    int y;
    
    // So we can tweak values later
    int zWidth = 50;
    int zHeight = 50;
    
    // Ctor
    Zombie(String w, float s)
    {
        speed = s;
        word  = w;
        
        // Initial position
        x = width;
        y = height-300;
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
            fill(0);
            stroke(255);
            ellipse(x, y, zWidth, zHeight);
            
            // Draw the word above the zombie
            font = loadFont("serif"); 
            textFont(font);
            textSize(20);
            text(word, x - (zWidth / 2), y - zHeight); 
        }
        // Dead Zombie
        else
        {
            // Draw zombie              
            fill(255, 0, 0);
            stroke(255);
            ellipse(x, y, zWidth, zHeight);
        }
    }
    
    // Updates the position and state of a zombie object
    void update()
    {
        // Dead zombie can't update
        if (isDead()) { return; }
    
        // if goes off left side, then kill self.
        if (x <= 0) { kill(); }
    
        // If collides with player, then kill player
        if (x <= player.getFront()) { player.kill(); }
    
        x -= speed;      
    }    
    
    // Member funcs
    int getWidth() { return zWidth; }
    int getHeight() { return zHeight; }
    String getWord() { return word; }
    int getSpeed() { return speed; }
    
    // Zombie is killed
    void kill() 
    { 
        deadZombies.add(this);
        dead = true; 
        
        // Lower to ground
        y += 160;
        zHeight -= 20;
    }
    
    // Check if dead
    boolean isDead() { return dead; }
}
