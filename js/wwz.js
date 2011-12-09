// Words with Zombies

// Enum for game state
var GameState = { MENU:0, LOADING_LEVEL:1, IN_GAME:2, END_LEVEL_ALL_DEAD:3, END_LEVEL_DAYLIGHT:4, END_GAME:5, GAME_OVER:6 }

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
