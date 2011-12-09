// Words with Zombies

// Enum for game state
var GameState = { MENU:0, LOADING_LEVEL:1, LEVEL_LOADED:2, IN_GAME:3, END_LEVEL_ALL_DEAD:4, END_LEVEL_DAYLIGHT:5, END_GAME:6, GAME_OVER:7 }

// Function to grab level information for WWZ via AJAX
function getLevel(level)
{
    // Retrieve the file
    $.ajax({
        url: "./levels/" + level,
        success: function(response)
        {
            var p = Processing.getInstanceById("wwz");
            p.loadLevel(response);
        },
        error: function(response)
        {
            var p = Processing.getInstanceById("wwz");
            p.loadLevelFailed();
        }        
    });
}

// After document loaded
$(document).ready(function ()
{
    // Capture keyboard events
    $("#keyboard input").mousedown(function() 
    { 
        var p = Processing.getInstanceById("wwz");
        p.keyboardPress($(this).attr("value"));
    });
});
