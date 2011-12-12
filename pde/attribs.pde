// Attibutes used throughout the application.

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
color letterBlockBG      = #ffae56;
color letterBlockBGHit   = #ff0000;
color letterBlockOutline = #000000;
color bullet             = #ff9622;

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
int deadZombiesToKeep    = 3; // Number of dead zombies to remain on screen.

boolean audioEnabled     = false;

// Game State
int currentState = GameState.MENU;
Level currentLevel;
int currentLevelNumber = 1;
int nextZombieInterval = 0;
int backgroundOffset   = 0;
int backgroundLimit    = height - 2000 - 216; // Height - image height - ground height
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
var audioLockAndLoad;
var audioEmpty;

// Fonts
var fontSerif     = loadFont("serifbold");
