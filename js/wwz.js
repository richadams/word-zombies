// Words with Zombies

// Function to grab level information for WWZ via AJAX
function getLevel(level)
{
    // Retrieve the file
    $.ajax({
        url: "/levels/" + level,
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
