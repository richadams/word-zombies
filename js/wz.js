// Words with Zombies

// Processing instance
var instance;

// Includes
////////////////////////////////////////////////////////////////////////////////////////////////////

// Want to use "include" style syntax for Processing JS file, easier to maintain.
var processingFiles = ""; function include(filename) { processingFiles += "./pde/" + filename + " "; }

// Main game
include("wz.pde");

// Classes
include("bullet.class.pde");
include("player.class.pde");
include("zombie.class.pde");
include("letter.class.pde");
include("level.class.pde");

// Screens
include("screens.pde");

// State
////////////////////////////////////////////////////////////////////////////////////////////////////
var GameState = { MENU:0, 
                  LOADING_LEVEL:1, 
                  LEVEL_LOADED:2, 
                  IN_GAME:3, 
                  END_LEVEL_ALL_DEAD:4, 
                  END_LEVEL_DAYLIGHT:5, 
                  END_GAME:6, 
                  GAME_OVER:7 
                 }

// Init
////////////////////////////////////////////////////////////////////////////////////////////////////

// Only start once the page has fully loaded
$(document).ready(function ()
{
    // Init the processing instance
    $("canvas#wz").attr("data-src", processingFiles);
    instance = new Processing(document.getElementById("wz"));

    // Bind keyboard events, pass through to processing.
    // Have to use "touchstart" event as Apple introduce a 300ms delay on "click" events.
    $("#keyboard input[type=submit]").bind("touchstart", function()
    {
        instance.keyboardPress($(this).attr("value"));
    });
});
