<?php
// This does the heavy lifting and will create some word zombies levels! :)

////////////////////////////////////////////////////////////////////////////////////////////////////
// Get user input

function usage($exit_code = 0)
{
    echo "Usage: create_levels.php -n <num_levels> -s <start>\n";
    echo "    Example: create_levels.php -n 10 -s 1\n";
    exit($exit_code);
}

$options = getopt("n:s:");

// Check validity of input
if (!isset($options["n"]))      { echo "You must specify the number of levels to create.\n"; usage(1); }
if (!isset($options["s"]))      { echo "You need to specify a starting level, 1 is the first.\n"; usage(1); }
if ($options["s"] < 1)          { echo "The starting level must be 1 or above.\n"; usage(1); }
if (!is_numeric($options["n"])) { echo "Number of levels should be numeric.\n"; usage(1); }
if (!is_numeric($options["s"])) { echo "Start level should be numeric.\n"; usage(1); }

$_numLevels  = intval($options["n"]);
$_startLevel = intval($options["s"]);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Functions

// Gives a weighted random value.
// w of 1 is unweighted. lower w weights to higher number and vice versa.
function wrand($min, $max, $w)
{
    return floor($min+pow(lcg_value(), $w)*($max-$min+1));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Generate the levels

// Create the words
system("cat source.txt | python prepare_wz_dict.py > words.txt");

// Read in the words and create a "skill" value.
$lines = explode("\n", file_get_contents("words.txt"));

$words = array();
foreach ($lines as $l)
{
    $segs = explode(" ", $l);
    
    // Skip any corrupted lines.
    if (count($segs) != 2) { continue; }
    
    $word      = $segs[0];
    $frequency = $segs[1];
    $length    = strlen($word);
    
    // Skip empty words, or ones with special chars
    if ($word == "") { continue; }
    if (strpos($word, "-") !== false
        || strpos($word, "'") !== false)
    {
        continue; 
    }
    
    // Skill is based on word length and frequency. It's a value from 0-100.
    // High frequency = lower skill
    // Longer length = higher skill
    $skill = floor($length / ($frequency/10));
    if ($skill > 100) { $skill = 100; }
    
    $words[$skill][] = $word;
}

// Now I have words and a skill level, construct the levels.
$output = "";
for ($l = $_startLevel; $l < $_startLevel + $_numLevels; $l++)
{
    echo "Generating level ".$l."...";
    
    // Generate between 20 and 30 zombies per level. Times about right with daylight.
    $numZombies = rand(20, 30);
    
    // Counters  
    $totalChars = 0;
    $totalZombies = 0;
    $totalSkill = 0;
    
    for ($z = 0; $z <= $numZombies; $z++)
    {
        // Weighting to use for speed/skill. Based on level number.
        $weighting = 1 / ($l / 10);
    
        // Speed is a weighted random value between 3 and 25. It's weighted based on the level
        // number. So higher level means more chance of faster zombies.
        $speed = wrand(3, 25, $weighting);
        
        // Pick a word from the skills. The skill level is also chosen from a weighted random value
        // with lower levels being weighted more towards the lower skills.
        $skill = wrand(0, 100, $weighting);
        
        // If we have no words for a particular skill level, then go backwards until we do.
        while (!isset($words[$skill])) { $skill--; }
        
        // Now pick a word frm the skill set.
        $word = $words[$skill][array_rand($words[$skill])];
        $totalChars += strlen($word);        
        
        // Determine Zombie type. For now this is based on speed.
        $type = ($speed < 15) ? "slow" : "fast";
        
        // Append zombies to output
        $output .= $type." ".strtoupper($word)." ".$speed."\n";
        
        $totalZombies++;
        $totalSkill += $skill;
    }
    
    // Give player 1.2 times the ammo needed.
    $ammo = (int)(1.2 * $totalChars);
    $output = "*newammo:".$ammo."\n" . $output;
    
    // Output progress
    echo "(Zombies=".$totalZombies.", Ammo=".$ammo.", Avg Skill=".number_format(($totalSkill/$totalZombies), 2).")...";
    
    // Finally, write out the level definition.
    file_put_contents($l, $output); 
    echo "OK\n";
}
