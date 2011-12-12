// These are the various "screens" that can popup throughout the game.

// The main intro screen, shows the backdrop and a message to tap.
void showIntro()
{
    if (audioEnabled) { audioMenu.play(); }

    image(imgMenu, 0, 0);
    
    textSize(20);
    textAlign(CENTER);
    fill(255);
    text("Tap screen to start a new game!", (width / 2) +1, (height / 2) + 281);
    fill(0);
    text("Tap screen to start a new game!", width / 2, (height / 2) + 280);
}

// This draws the white rectangle popup on the page, with a fancy drop shadow.
void drawMessageArea()
{
    // Drop Shadow
    fill(0);
    rect((width / 2) - (messageWidth / 2) + 5, (height / 2) - (messageHeight /2) + 5, messageWidth, messageHeight);

    fill(255);
    rect((width / 2) - (messageWidth / 2), (height / 2) - (messageHeight /2), messageWidth, messageHeight);
}

// This draws a message, for loading messages, etc.
void drawMessage(String message)
{
    fill(255);
    rect((width / 2) - 100, (height / 2) - 10, 200, 20);
    
    textFont(fontSerif);
    textSize(20);
    textAlign(CENTER);
    fill(0);
    text(message, width / 2, (height / 2) + 5);
}

// The game over screen, plays the relevant audio and shows the score status.
void gameOver()
{
    if (audioEnabled) { audioGameOver.play(); }

    image(imgBackgroundOver, 0, 0);

    drawMessageArea();

    fill(0);
    textFont(fontSerif);
    textSize(50);
    textAlign(CENTER);
    text("GAME OVER", width / 2, (height / 2) - 40);

    textSize(25);
    textAlign(LEFT);
    text("Final Score:", width / 2 - (messageWidth / 2) + 100, (height / 2));

    textSize(20);
    textAlign(LEFT);
    image(imgMoneyIcon, width / 2 - (messageWidth / 2) + 75, (height / 2) + 10);
    text ("You earned $" + levelScore + ".", width / 2 - (messageWidth / 2) + 100, (height/2) + 30);
    image(imgZombieIcon, width / 2 - (messageWidth / 2) + 75, (height / 2) + 33);
    text ("You 'took care' of " + levelKills + " undead.", width / 2 - (messageWidth / 2) + 100, (height/2) + 50);

    textSize(16);
    textAlign(CENTER);
    text("Tap screen to start a new game!", width / 2, (height / 2) + 80);
}

// The level start screen. Shows how many zombies there will be, and how much extra ammo the player
// gets.
void levelStartScreen()
{
    if (audioEnabled) { if (audioMenu.paused) { audioMenu.play(); } } // Restart menu audio.

    drawMessageArea();

    fill(0);
    textFont(fontSerif);
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

// End of Level, shows the score and how the level ended (all zombies killed, or daylight arrived).
void endOfLevel()
{
    drawMessageArea();

    fill(0);
    textFont(fontSerif);
    textSize(50);
    textAlign(CENTER);
    text("Level " + currentLevelNumber + " completed!", width / 2, (height / 2) - 50);

    textSize(20);
    textAlign(CENTER);

    if (currentState == GameState.END_LEVEL_ALL_DEAD)
    {
        text("You killed all the zombies!", width/2, (height/2) - 20);
    }
    else if (currentState == GameState.END_LEVEL_DAYLIGHT)
    {
        text("You survived until daylight!", width/2, (height/2) - 20);
    }

    textAlign(LEFT);
    image(imgMoneyIcon, width / 2 - (messageWidth / 2) + 75, (height / 2) - 5);
    text ("You earned $" + levelScore + ".", width / 2 - (messageWidth / 2) + 100, (height/2) + 15);
    image(imgZombieIcon, width / 2 - (messageWidth / 2) + 75, (height / 2) + 18);
    text ("You 'took care' of " + levelKills + " undead.", width / 2 - (messageWidth / 2) + 100, (height/2) + 35);

    textSize(20);
    textAlign(CENTER);
    text("Tap screen to continue to level " + (currentLevelNumber+1) + "!", width / 2, (height / 2) + 75);
}

// Completed the game!! Impossible to reach in the demo due to level 3, but will work if you give
// proper level definitions. Could have a scoreboard and stuff here.
void completedGame()
{
    background(0);
    fill(255);

    textFont(fontSerif);
    textSize(50);
    textAlign(CENTER);
    text("You completed the game!", width / 2, height / 2);

    textSize(30);
    textAlign(CENTER);
    text("Final Score - $" + totalScore + " Kills: " + totalKills, width / 2, (height / 2) + 40);
}
