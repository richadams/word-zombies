// Words with Zombies - Gravity Hackathon Prototype

// Preload images
/* @pjs preload="img/menu.jpg,img/player.png,img/zombies/slow_0.png,img/zombies/slow_1.png,img/zombies/slow_2.png,img/zombies/fast_0.png,img/zombies/fast_1.png,img/zombies/fast_2.png,img/dead-zombie.png,img/background-ground.png,img/background-sky.jpg,img/icons/ammo.png,img/icons/ammo-black.png,img/icons/ammo-empty.png,img/icons/zombie.png,img/background-game-over.jpg,img/icons/money.png"; */

// Attribs
////////////////////////////////////////////////////////////////////////////////////////////////////

// Game Setup
int width     = 768;
int height    = 640;
int framerate = 20;

// Colors
color red                = #ff0000;
color letterBlockBG      = #FFAE56;
color letterBlockBGHit   = #FF0000;
color letterBlockOutline = #000000;
color bullet             = #FF9622;

// Game Elements
int deadZombies   = 0;
ArrayList zombies = new ArrayList();
Player player     = new Player();
ArrayList bullets = new ArrayList();

// Game Settings
int backgroundSpeed      = 1;
int bulletSpeed          = 100;
int zombieAnimationSpeed = 3; // Higher = slower
int zombieFrames         = 3;

boolean audioEnabled     = false;

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
PImage imgMenu             = loadImage("img/menu.jpg");
PImage imgBackgroundSky    = loadImage("img/background-sky.jpg");
PImage imgBackgroundGround = loadImage("img/background-ground.png");
PImage imgAmmoIcon         = loadImage("img/icons/ammo.png");
PImage imgAmmoIconBlack    = loadImage("img/icons/ammo-black.png");
PImage imgAmmoEmptyIcon    = loadImage("img/icons/ammo-empty.png");
PImage imgZombieIcon       = loadImage("img/icons/zombie.png");
PImage imgBackgroundOver   = loadImage("img/background-game-over.jpg");
PImage imgMoneyIcon        = loadImage("img/icons/money.png");
PImage imgPlayer           = loadImage("img/player.png");

// Audio
var audioMenu;
var audioBullet;
var audioGameOver;

// Fonts
var fontSerif     = loadFont("serifbold");

// Setup
////////////////////////////////////////////////////////////////////////////////////////////////////
void setup()
{
    size(width, height);
    frameRate(framerate);
    
    var is_chrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
    
    if (is_chrome) 
    { 
        audioEnabled = true;
        $("#keyboard").css("display", "none");
        $("#canvas").css("margin", "0 auto");
    }

    if (audioEnabled)
    {
        audioMenu     = new Audio("./audio/menu.mp3");
        audioBullet   = new Audio("./audio/bullet.wav");
        audioGameOver = new Audio("./audio/scream.mp3");
    }
}

// Helper Functions
////////////////////////////////////////////////////////////////////////////////////////////////////

// Start and stop animation processing
void stop()  { Processing.getInstanceById("wz").noLoop(); }
void start() { Processing.getInstanceById("wz").loop(); }

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
void keyboardPress(k)
{
    key = k;
    keyReleased();
}

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
       case GameState.GAME_OVER:
            newGame();
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
        Zombie z = new Zombie(segments[1], segments[2], segments[0]);
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

// Game Functions
////////////////////////////////////////////////////////////////////////////////////////////////////
void newGame()
{
    // Reset counters
    totalScore         = 0;
    levelScore         = 0;
    totalKills         = 0;
    levelKills         = 0;
    ammoRemaining      = 0;
    zombiesRemaining   = 0;
    currentLevelNumber = 1;

    // Put into correct state, and start
    currentState = GameState.MENU;
    start();
}

void updateNextZombieInterval()
{
    nextZombieInterval = Math.floor(Math.random() * (framerate * 2)) + (framerate * 1);
}

// Function to grab level information for WWZ via AJAX
function getLevel(level)
{
    // Retrieve the file
    $.ajax({
        url: "./levels/" + level,
        success: function(response)
        {
            var p = Processing.getInstanceById("wz");
            p.loadLevel(response);
        },
        error: function(response)
        {
            var p = Processing.getInstanceById("wz");
            p.loadLevelFailed();
        }        
    });
}
