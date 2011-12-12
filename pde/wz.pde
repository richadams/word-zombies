// Words with Zombies - Gravity Hackathon Prototype

// This file contains the main game logic and methods.

// Setup
////////////////////////////////////////////////////////////////////////////////////////////////////
void setup()
{
    size(width, height);
    frameRate(framerate);
    
    // If chrome, then hide the keyboard and enable sounds.    
    if (navigator.userAgent.toLowerCase().indexOf('chrome') > -1) 
    { 
        audioEnabled = true;
        $("#keyboard").css("display", "none");
        $("#canvas").css("margin", "0 auto");
    }

    if (audioEnabled)
    {
        audioMenu        = new Audio("./audio/menu.mp3");
        audioBullet      = new Audio("./audio/bullet.wav");
        audioGameOver    = new Audio("./audio/scream.mp3");
        audioLockAndLoad = new Audio("./audio/lockload.wav");
        audioEmpty       = new Audio("./audio/empty.wav");
    }
}

// Main Program Loop
////////////////////////////////////////////////////////////////////////////////////////////////////
void draw()
{
    // What happens will depend on game state
    switch(currentState)
    {
        // Main game screens
        case GameState.MENU:
            stop(); showIntro(); return;
            break;
        case GameState.LOADING_LEVEL:
            stop(); showLoading(); return;
            break;
        case GameState.LEVEL_LOADED:
            stop(); levelStartScreen(); return;
            break;
        case GameState.END_LEVEL_ALL_DEAD:
        case GameState.END_LEVEL_DAYLIGHT:
            stop(); endOfLevel(); return;
            break;
        case GameState.GAME_OVER:
            stop(); gameOver(); return;
            break;
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
    if (deadZombies == currentLevel.totalZombies()
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

    // Update state
    nextZombieInterval--;
    backgroundOffset -= backgroundSpeed;
}


// This sets up the game background and score board.
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
    textFont(fontSerif);
    fill(255);
    textSize(15);
    textAlign(LEFT);
    text(" Level: " + currentLevelNumber, 0, 18);

    // Render the score
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
    text(str(ammoRemaining), ((width / 2) + 5), 18);

    // Render zombies reamining
    image(imgZombieIcon, (width / 2) + 10 + textWidth(str(ammoRemaining)), 2);
    fill(255);
    text(str(zombiesRemaining), ((width / 2) + textWidth(str(ammoRemaining)) + 35), 18);
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
            if (ammoRemaining == 0) 
            { 
                if (audioEnabled) 
                {
                    audioEmpty.currentTime = 0; 
                    audioEmpty.play();
                }
                return; 
            }
            bullets.add(new Bullet(str(key).toUpperCase())); // Fire a bullet
            break;
    }
    
    // Enter is equiv to a "tap" on the screen.
    if (keyCode == ENTER) { mouseReleased(); }
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
            drawMessage("Rendering level...");
            currentLevel.startLevel();
            break;
       case GameState.GAME_OVER:
            newGame();
            break;
    }
}

// Level Loading
////////////////////////////////////////////////////////////////////////////////////////////////////

// Function to grab level information for WWZ via AJAX
function getLevel(level)
{
    // Update state
    currentState = GameState.LOADING_LEVEL;
    drawMessage("Loading level definition...");
    
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

void loadLevel(params)
{
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
    drawMessage("Level loaded, parsing info...");
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

// Updates the interval at which the next zombie will appear.
void updateNextZombieInterval()
{
    nextZombieInterval = Math.floor(Math.random() * (framerate * 2)) + (framerate * 1);
}
