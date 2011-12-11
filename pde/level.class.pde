// Level
////////////////////////////////////////////////////////////////////////////////////////////////////
class Level
{
    ArrayList levelZombies = new ArrayList();

    var audioComplete;

    int num;
    int extraAmmo = 0;
    boolean completed = false;

    // ctor
    Level(int levelNumber)
    {
        num = levelNumber;

        if (audioEnabled)
        {
            audioComplete = new Audio("./audio/level-complete.mp3");
        }
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
        if (audioEnabled) { audioMenu.pause(); }

        // Restart the loop
        start();
    }

    // Member functions
    boolean isComplete() { return completed; }
    int totalZombies() { return levelZombies.size(); }
    void complete()
    {
        completed = true;
        if (audioEnabled) { audioComplete.play(); }
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
