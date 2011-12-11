// The player object is the drawn player on the screen. It also handles the current location of the
// player for collision detection with the zombies.

class Player
{
    // Members
    int front; // Front of player, for collision detection.
    boolean dead = false;

    // Player size
    int pWidth  = 160;
    int pHeight = 200;

    int bulletHeight = 150; // from bottom

    // Current position
    int x = 50;
    int y = height - 250;

    // Constructor
    Player()
    {
        front = x + (pWidth / 2); // x is centered, so make sure to include 1/2 width too.
    }

    // Just redraw the player in place for now.
    void run() { draw(); }

    // Draw the image of the player in the correct place.
    void draw()
    {
        image(imgPlayer,  x - (pWidth / 2), y - (pHeight / 2));
    }

    // Getters
    int getBulletHeight() { return y + (pHeight / 2) - bulletHeight; }
    int getX()            { return x; }
    int getY()            { return y; }
    int getFront()        { return front; }
    
    // Death handling
    boolean isDead()      { return dead; }
    void kill()
    {
        dead = true;
        currentState = GameState.GAME_OVER;
    }
}
