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

// Show intro
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

// Start Level
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

// End of Level
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

// Completed the game!!
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
