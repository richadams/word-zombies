// The bullet is both the drawn object on the screen, and the logic which triggers a hit/miss
// action on the zombie. I keep track of where the bullet is and once it passes the zombie, check
// to see if it's a correct letter for that zombie.

class Bullet
{
    // Members
    int speed = bulletSpeed;
    var key;
    int x;

    // Constructor
    Bullet(String k)
    {
        key = k;
        x   = player.getFront(); // Start at player's front position
        
        // Gunshot sound
        if (audioEnabled)
        {
            audioBullet.currentTime = 0;
            audioBullet.play();
        }

        ammoRemaining--;
    }
    
    // Renders the "bullet". For now this is just a squashed ellipse.
    void draw()
    {
        fill(bullet);
        noStroke();
        ellipse(x, player.getBulletHeight(), 15, 5);
    }

    // Move the bullet forward based on it's speed, and check if it's hit/miss.
    void run()
    {
        draw();
        x += speed;

        // If bullet has gone off the end of the page, remove it.
        if (x >= width)
        {
            bullets.remove(0); return;
        }

        // Check if the bullet has kit any of the active zombies.
        for ( int i = 0; i < zombies.size(); i++)
        {
            Zombie z = zombies.get(i);
            
            // Dead zombies aren't elligible
            if (z.isDead()) { continue; }
            
            // If bullet has passed zombie, check if it's a hit and remove the bullet if so.
            // Zombie object will take care of updating it's own state if we hit.
            if (x >= z.getX()
                && z.tryToHit(key))
            {
                bullets.remove(0); return;
            }
        }
    }
}
