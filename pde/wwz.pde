// Words with Zombies - Gravity Hackathon Prototype

// Preload images
/* @pjs preload="img/player.png,img/zombie.png,img/dead-zombie.png,img/background-ground.png,img/background-sky.jpg,img/icons/ammo.png,img/icons/ammo-black.png,img/icons/ammo-empty.png,img/icons/zombie.png,img/background-game-over.jpg"; */

// Attribs
////////////////////////////////////////////////////////////////////////////////////////////////////

// Game Setup
int width     = 768;
int height    = 640;
int framerate = 15;

// Colors
color red                = #ff0000;
color letterBlockBG      = #FFAE56;
color letterBlockBGHit   = #FF0000;
color letterBlockOutline = #000000;

// Game Elements
int deadZombies   = 0;
ArrayList zombies = new ArrayList();
Player player     = new Player();
ArrayList bullets = new ArrayList();

// Game Settings
int backgroundSpeed = 1;
int bulletSpeed     = 100;

// Game State
int currentState = GameState.MENU;
Level currentLevel;
int currentLevelNumber = 1;
int nextZombieInterval = 0;
int backgroundOffset   = 0; 
int backgroundLimit    = height - 2000;
int ammoRemaining      = 0;
int zombiesRemaining   = 0;

// Score counters
int totalScore = 0;
int levelScore = 0;
int totalKills = 0;
int levelKills = 0;

// Messages
int messageWidth  = 600;
int messageHeight = 200;

// Images
PImage imgBackgroundSky    = loadImage("img/background-sky.jpg");
PImage imgBackgroundGround = loadImage("img/background-ground.png");
PImage imgAmmoIcon         = loadImage("img/icons/ammo.png");
PImage imgAmmoIconBlack    = loadImage("img/icons/ammo-black.png");
PImage imgAmmoEmptyIcon    = loadImage("img/icons/ammo-empty.png");
PImage imgZombieIcon       = loadImage("img/icons/zombie.png");
PImage imgBackgroundOver   = loadImage("img/background-game-over.jpg"); 

// Audio
var audioMenu     = new Audio("./audio/menu.mp3");    
var audioBullet   = new Audio("./audio/bullet.wav");
var audioGameOver = new Audio("./audio/scream.mp3");

// Fonts
//var fontNormal    = loadFont("./fonts/DejaVuSans-20.vlw");
//var fontPopup     = loadFont("./fonts/DejaVuSansCondensed-20.vlw");
//var fontPopupBold = loadFont("./fonts/DejaVuSansCondensed-Bold-20.vlw");
//var fontBlocks    = loadFont("./fonts/DejaVuSerifCondensed-30.vlw");

// Setup
////////////////////////////////////////////////////////////////////////////////////////////////////
void setup()
{
    size(width, height);
    frameRate(framerate);
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
    // Draw the sky    
    image(imgBackgroundSky, 0, backgroundOffset);

    // Draw the ground
    image(imgBackgroundGround, 0, height - 216);

    // Score bar
    stroke(0);
    strokeWeight(1);
    fill(0);
    rect(0, 0, width, 24);

    // Render the level
    textFont(loadFont("Serif"));
    fill(255);
    textSize(15);
    textAlign(LEFT);
    text(" Level: " + currentLevelNumber, 0, 18);

    // Render the score
    textFont(loadFont("Serif"));
    fill(255);
    textSize(15);
    textAlign(RIGHT);
    text("$" + totalScore + " (Kills: " + totalKills + ") ", width, 18);
    
    // Render current ammo
    if (ammoRemaining == 0)
    {
        image(imgAmmoEmptyIcon, (width / 2) - 20, 2);
        fill(red);
    }
    else
    {
        image(imgAmmoIcon, (width / 2) - 20, 2);
        fill(255);
    }
    textAlign(LEFT);
    textFont(loadFont("serifbold"))
    text(str(ammoRemaining), ((width / 2) + 5), 18);
    
    // Render zombies reamining
    image(imgZombieIcon, (width / 2) + 10 + textWidth(str(ammoRemaining)), 2);
    fill(255);
    textAlign(LEFT);
    textFont(loadFont("serifbold"))
    text(str(zombiesRemaining), ((width / 2) + textWidth(str(ammoRemaining)) + 35), 18);
}

// Show intro
void showIntro()
{
    audioMenu.play();

    background(0);
    fill(255);

    font = loadFont("serif");
    textFont(font);
    textSize(50);
    textAlign(CENTER);
    text("WORDS WITH ZOMBIES", width / 2, height / 2);

    textSize(20);
    textAlign(CENTER);
    text("Tap screen to start!", width / 2, (height / 2) + 75);
}

void drawMessageArea()
{
    // Drop Shadow
    fill(0);
    rect((width / 2) - (messageWidth / 2) + 5, (height / 2) - (messageHeight /2) + 5, messageWidth, messageHeight);
    
    fill(255);
    rect((width / 2) - (messageWidth / 2), (height / 2) - (messageHeight /2), messageWidth, messageHeight);
}

// Game over
void gameOver()
{
    audioGameOver.play();

    image(imgBackgroundOver, 0, 0);
    
    fill(0);

    font = loadFont("serif");
    textFont(font);
    textSize(50);
    textAlign(CENTER);
    text("GAME OVER", width / 2, height / 2);

    textSize(30);
    textAlign(CENTER);
    text("Final Score: " + totalScore + " Kills: " + totalKills, width / 2, (height / 2) + 40);
}

// Start Level
void levelStartScreen()
{
    drawMessageArea();

    fill(0);
    font = loadFont("serif");
    textFont(font);
    textSize(50);
    textAlign(CENTER);
        
    text("Level " + currentLevelNumber + ", Ready?", width / 2, height / 2 - 40);

    textSize(22);
    textAlign(LEFT);
    image(imgAmmoIconBlack, width / 2 - (messageWidth / 2) + 75, (height / 2) - 17);
    text("You've been given " + currentLevel.getExtraAmmo() + " bullets.", width / 2 - (messageWidth / 2) + 100, (height / 2));
    image(imgZombieIcon, width / 2 - (messageWidth / 2) + 75, (height / 2) + 8);
    text("There are " + currentLevel.totalZombies() + " zombies to 'take care' of.", width / 2 - (messageWidth / 2) + 100, (height / 2) + 25);

    textSize(20);
    textAlign(CENTER);
    text("Tap screen to begin!", width / 2, (height / 2) + 75);
}

// End of Level
void endOfLevel()
{
    drawMessageArea();

    fill(0);
    font = loadFont("serif");
    textFont(font);
    textSize(50);
    textAlign(CENTER);
    
    if (currentState == GameState.END_LEVEL_ALL_DEAD)
    {
        text("You killed all the zombies!", width/2, height/2 - 50);
    }
    else if (currentState == GameState.END_LEVEL_DAYLIGHT)
    {
        text("You survived until daylight!", width/2, height/2 - 50);
    }
        
    text("Level " + currentLevelNumber + " completed!", width / 2, height / 2);

    textSize(30);
    textAlign(CENTER);
    text("Score: " + levelScore + " (Total: " + totalScore + ") Kills: " + levelKills + " (Total: " + totalKills + ")", width / 2, (height / 2) + 40);

    textSize(20);
    textAlign(CENTER);
    text("Tap to continue", width / 2, (height / 2) + 75);
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
    // If menu
    if (currentState == GameState.MENU)
    {
        stop();
        showIntro();
        return;
    }
    
    // If level loaded
    if (currentState == GameState.LEVEL_LOADED)
    {
        stop();
        levelStartScreen();
        return;
    }

    // If end of level
    if (currentState == GameState.END_LEVEL_ALL_DEAD
        || currentState == GameState.END_LEVEL_DAYLIGHT)
    {
        stop();
        endOfLevel();
        return;
    }

    // If game over
    if (currentState == GameState.GAME_OVER)
    {
        stop();
        gameOver();
        return;
    }

    // Don't run rest while game isn't active.
    if (currentState != GameState.IN_GAME) { return; }

    // If background is at limit, level is over
    if (backgroundOffset <= backgroundLimit)
    {
        currentState = GameState.END_LEVEL_DAYLIGHT;
        currentLevel.complete();
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
        && !currentLevel.isMoreZombies()) 
    { 
        currentState = GameState.END_LEVEL_ALL_DEAD;
        currentLevel.complete(); 
    }

    // Redraw background
    setupBackground();

    // Draw the player
    player.run();

    // Draw current zombies
    for (int i = 0; i < zombies.size(); i++) { zombies.get(i).run(); }

    // Draw bullets
    for (int i = 0; i < bullets.size(); i++) { bullets.get(i).run(); }

    nextZombieInterval--;
    backgroundOffset -= backgroundSpeed;
}

// Capture Events
////////////////////////////////////////////////////////////////////////////////////////////////////
void keyReleased()
{
    // Action depends on state
    switch (currentState)
    {
        case GameState.IN_GAME:
            if (ammoRemaining == 0) { return; }
            bullets.add(new Bullet(str(key))); // Fire a bullet
            break;
    }
}

// aka Touch event
void mouseReleased()
{
    // Action depends on state
    switch (currentState)
    {
        case GameState.END_LEVEL_ALL_DEAD:
        case GameState.END_LEVEL_DAYLIGHT:
            currentLevelNumber++; // Increment level, cascade to next option
        case GameState.MENU:
            getLevel(currentLevelNumber);
            break;
       case GameState.LEVEL_LOADED:
            currentLevel.startLevel();
            break;
    }
}

// Level Loading
////////////////////////////////////////////////////////////////////////////////////////////////////
void loadLevel(params)
{
    // Params are in form "WORD SPEED\n";

    // Update state
    currentState = GameState.LOADING_LEVEL;

    // Create a new level
    currentLevel = new Level(currentLevelNumber);

    // Go over each line
    var words = params.split("\n");
    for (var i in words)
    {
        if (words[i] == "") { continue; }
        
        // Parse out specials
        if (words[i].charAt(0) == "*")
        {
            var word = words[i].substring(1);
            var sections = word.split(":");
            
            // Can't use switch with strings in JS
            if (sections[0] == "newammo")
            {
                ammoRemaining += (int)sections[1];
                currentLevel.setExtraAmmo((int)sections[1]);
            }
            
            continue;
        }

        var segments = words[i].split(" ");
        Zombie z = new Zombie(segments[0], segments[1]);
        currentLevel.addZombie(z);
    }
    
    currentState = GameState.LEVEL_LOADED;
    start();
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

    var audioComplete = new Audio("./audio/level-complete.mp3");

    int num;
    int extraAmmo = 0;
    boolean completed = false;

    // ctor
    Level(int levelNumber)
    {
        num = levelNumber;
    }

    // Add a zombie
    void addZombie(Zombie z) { levelZombies.add(z); }

    // Start the level
    void startLevel()
    {
        // Clear previous zombies and reset data
        deadZombies = 0;
        zombies = new ArrayList();
        nextZombieInterval = 0;
        backgroundOffset = 0;

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

        // Start the game
        currentState = GameState.IN_GAME;
        zombiesRemaining = levelZombies.size();            
        audioMenu.pause();

        // Restart the loop
        start();
    }

    // Member functions
    boolean isComplete() { return completed; }
    int totalZombies() { return levelZombies.size(); }
    void complete()
    {
        completed = true;
        audioComplete.play();
    }

    boolean isMoreZombies() { return (levelZombies.size() != 0); }
    Zombie getNextZombie()
    {
        // No more zombies!
        if (levelZombies.size() == 0) { return null; }

        // Otherwise, return the next zombie.
        Zombie z = levelZombies.get(0);
        levelZombies.remove(0);
        return z;
    }
    
    void setExtraAmmo(int ammo) { extraAmmo = ammo; }
    int getExtraAmmo() { return extraAmmo; }
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
        PImage p = loadImage("img/player.png");
        image(p,  x - (pWidth / 2), y - (pHeight / 2));
    }

    // Member functions
    int getBulletHeight() { return y + (pHeight / 2) - bulletHeight; }
    int getX()            { return x; }
    int getY()            { return y; }
    int getFront()        { return front; }
    boolean isDead()      { return dead; }
    void kill()
    {
        dead = true;
        currentState = GameState.GAME_OVER;
    }
}

// Zombie
////////////////////////////////////////////////////////////////////////////////////////////////////
class Zombie
{
    // Members
    float speed;
    String word;
    boolean dead = false;
    
    boolean playedIntro = false;
    var audioBegin = new Audio("./audio/zombie-arrive.mp3");
    var audioDie   = new Audio("./audio/zombie-die.mp3");
    
    ArrayList letters = new ArrayList();
    Letter nextLetter;
    int hitPosition = 0;

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
        
        // Construct the letters
        for (int i = 0; i < word.length; i++)
        {
            letters.add(new Letter(this, str(word.charAt(i)), i));
        }
        nextLetter = letters.get(hitPosition);

        heightOffset = (Math.random()*100) - 70;

        // Initial position
        x = width;
        y = height - (zHeight / 2) - 100 + heightOffset;
    }

    // Main activity loop for the zombie
    void run()
    {
        if (!playedIntro) { audioBegin.play(); playedIntro = true; }
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
            PImage b = loadImage("img/zombie.png");
            image(b, x - (zWidth / 2), y - (zHeight / 2));

            // Draw the letter blocks above the zombie
            for (int i = 0; i < letters.size(); i++) { letters.get(i).draw(); }
        }
        // Dead Zombie
        else
        {
            PImage b = loadImage("img/dead-zombie.png");
            image(b, x - (zWidth / 2), y - (zHeight / 2));
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
        if (letters.get(hitPosition).getLetter() == k)
        {
            letters.get(hitPosition).hit();
        
            hitPosition++;

            totalScore++;
            levelScore++;

            // Determine if zombie should die
            if (hitPosition == letters.size())
            {
                kill();
                totalScore += 10;
                levelScore += 10;
                totalKills++;
                levelKills++;
                zombiesRemaining--;
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
    int getY() { return y; }

    // Zombie is killed
    void kill()
    {
        audioDie.play();
        
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

// Letter Block
////////////////////////////////////////////////////////////////////////////////////////////////////
class Letter
{
    String letter;
    int pos;
    boolean h = false;
    Zombie z;
    
    int width  = 30;
    int height = 30;
    int x;
    int y;
    int spacing = 5;
    
    Letter(Zombie zom, String s, int position)
    {
        z = zom;
        letter = s;
        pos = position;
    }
    
    // Render the letter block
    void draw()
    {
        // Determine position
        x = z.getX()  + ((z.getWord().length/2) * (width + spacing)) - (z.getWord().length * (width + spacing)) + (pos * (width + spacing));
        y = z.getY() - (z.getHeight() / 2) - 40;
    
        // Block
        fill(((h) ? letterBlockBGHit : letterBlockBG));
        stroke(letterBlockOutline);
        strokeWeight(1);        
        rect(x, y, width, height);
        
        // Text
        font = loadFont("monospace");
        fill(0);
        textFont(font);
        textAlign(LEFT);
        textSize(30);
        text(letter, x + 5, y + height - 7);
    }
    
    void hit() { h = true; }
    boolean isHit() { return h; }
    String getLetter() { return letter; }
}

// Bullet
////////////////////////////////////////////////////////////////////////////////////////////////////
class Bullet
{
    int speed = bulletSpeed;
    var key;
    int x;

    // ctor
    Bullet(String k)
    {
        key = k;
        x = player.getFront();
        
        audioBullet.currentTime = 0;
        audioBullet.play();
        
        ammoRemaining--;
    }

    void draw()
    {
        color bullet = #FF9622;
        fill(bullet);
        noStroke();
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
