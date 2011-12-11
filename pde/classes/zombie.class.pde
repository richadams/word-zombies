// The zombie class, this controls the zombie position, animation and the logic behind whether a
// bullet as "hit" or not.

class Zombie
{
    // Members
    float speed;
    String word;
    String zType;
    boolean dead = false;

    // Audio
    boolean playedIntro = false;
    var audioBegin;
    var audioDie;

    // Letters
    ArrayList letters = new ArrayList();
    Letter nextLetter;
    int hitPosition = 0;

    // Zombie size
    int zWidth  = 200;
    int zHeight = 260;

    // Animation
    int animationFrame = 0;
    int stepCounter = 0;

    // Current coords of the zombie
    int x;
    int y;

    int heightOffset = 0; // Random height offset to give 3d-ish appearance

    // Constructor
    Zombie(String w, float s, String t)
    {
        speed = s;
        word  = w;
        zType = t;

        if (audioEnabled)
        {
            audioBegin = new Audio("./audio/zombie-arrive.mp3");
            audioDie   = new Audio("./audio/zombie-die.mp3");
        }

        // Construct the letter objects
        for (int i = 0; i < word.length; i++)
        {
            letters.add(new Letter(this, str(word.charAt(i)), i));
        }
        nextLetter = letters.get(hitPosition);

        // Height offset is to randomize the 3D position of the zombie.. are they further back or
        // forward on the screen. So they're not all coming in at the same point.
        heightOffset = (Math.random()*100) - 70;

        // Initial position
        x = width;
        y = height - (zHeight / 2) - 100 + heightOffset;
    }

    // Main activity loop for the zombie
    void run()
    {
        stepCounter++;
        if (audioEnabled) { if (!playedIntro) { audioBegin.play(); playedIntro = true; } }
        update();
        draw();
    }

    // Draws a zombie object
    void draw()
    {
        // Alive Zombie
        if (!dead)
        {
            // Determine the animation frame.
            if (stepCounter % zombieAnimationSpeed == 0) { animationFrame++; }
            if (animationFrame == zombieFrames) { animationFrame = 0; }

            // Draw zombie
            PImage b = loadImage("img/zombies/" + zType + "_" + animationFrame +".png");
            image(b, x - (zWidth / 2), y - (zHeight / 2));

            // Draw the letter blocks above the zombie
            for (int i = 0; i < letters.size(); i++) { letters.get(i).draw(); }
        }
        // Dead Zombie
        else
        {
            PImage b = loadImage("img/dead-zombie.png");
            image(b, x - (zWidth / 2), y - (zHeight / 2) + 10);
        }
    }

    // Updates the position and state of a zombie object
    void update()
    {
        // Dead zombie can't update
        if (dead) { return; }

        // If goes off left side, then kill self.
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
            // Update the letter object so it changes state.
            letters.get(hitPosition).hit();

            // Update counters
            hitPosition++;
            totalScore++;
            levelScore++;

            // Determine if zombie should die
            if (hitPosition == letters.size())
            {
                kill();
                
                // Update score and counters.
                totalScore += 10;
                levelScore += 10;
                totalKills++;
                levelKills++;
                zombiesRemaining--;
            }

            return true; // Hit
        }

        return false; // Miss
    }

    // Member funcs
    int getWidth()   { return zWidth; }
    int getHeight()  { return zHeight; }
    String getWord() { return word; }
    int getSpeed()   { return speed; }
    int getX()       { return x; }
    int getY()       { return y; }

    // Zombie death handling
    void kill()
    {
        if (audioEnabled) { audioDie.play(); }

        deadZombies++;        
        dead = true;

        // Lower to ground
        y += 160;
        zHeight -= 20;
    }

    // Check if dead
    boolean isDead() { return dead; }
}
