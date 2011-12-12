// This is the letter block which appears above zombies. They are positioned according to where they
// appear in the word.

class Letter
{
    // Members
    String letter;
    int pos; // Position in word.
    boolean h = false; // Has it been hit?
    Zombie z;

    // Positional information
    int width  = 30;
    int height = 30;
    int x;
    int y;
    int spacing = 5;

    // Constructor
    Letter(Zombie zom, String s, int position)
    {
        z      = zom;
        letter = s;
        pos    = position;
    }

    // Render the letter block
    void draw()
    {
        // Determine position
        x = z.getX() // Zombie location on x -axis
            - ((z.getWord().length/2) * (width + spacing)) // Minus half the length of the word number of letter blocks
            + (pos * (width + spacing)); // Plus this letter's position number of letter blocks.
        
        y = z.getY() - (z.getHeight() / 2) - 40; // 40px above Zombie's top.

        // Block
        fill(((h) ? letterBlockBGHit : letterBlockBG));
        stroke(letterBlockOutline);
        strokeWeight(1);
        rect(x, y, width, height, 2);

        // Text
        fill(0);
        textFont(loadFont("monospace"));
        textAlign(LEFT);
        textSize(30);
        text(letter, x + 5, y + height - 7);
    }

    // Member functions
    void hit()         { h = true; }
    boolean isHit()    { return h; }
    String getLetter() { return letter; }
}
