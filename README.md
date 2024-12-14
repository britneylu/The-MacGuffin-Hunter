# The MacGuffin Hunter!

# Introduction

MacGuffins are great devices, after all. For example, Pac-Man loved his MacGuffins, chomping away and picking them up. Pac-Man was a great game, but we are going to create a way better one: The MacGuffin Hunter!

The MacGuffin Hunter consists of a character the player controls and can move in a particular area. Each tile can be one of two things: (1) a wall and (2) an empty space. Initially, empty spaces will be filled with the most desirable devices: The MacGuffins! And it's the objective of the player to move through the game arena to pick up as many as possible!
The player controls a character that can move through the empty spaces. When the player reaches a MacGuffin, the MacGuffin is picked up.

But be careful. Enemies will spawn on the screen and start capturing MacGuffins as well. And if they catch you, which they will try, you will lose a game life.

The game ends when all the MacGuffins are picked up or when the player runs out of game life. A score is given based on something, such as the time it took the player to clear the arena.


# Game elements

## 1. The Game Arena

The MARS LED display is 64x64 pixels.
The screen is split into two areas.
1. The top area where the action unravels
2. The bottom, where information about the number of points and game lives remaining, is displayed.

### Key Features:

* Arena is constructed from 5x5 pixel tiles, fitting within a 64x64 pixel display.
* The arena’s usable space is smaller (e.g., 60x55 pixels) due to the constraints of 5x5 tiles.
* The arena’s layout includes walls and empty spaces.

### Development tips

1. Create some variables to hold how many points and game lives the player has. You may start with three lives, but you decide for your game.
2. Make a function to display this information at the bottom of the screen.
3. Create the platforms.

The player should navigate the arena using keyboard controls, avoid walls, stay within the arena’s boundaries.


## 2. The Player

The player controls a 5x5 blit character, which moves around the arena to collect MacGuffins and avoid enemies. The player’s starting position is predefined, and they begin with three lives.

### Player Capabilities:

1. Move left, right, up, and down using keyboard input.
2. Collect MacGuffins by moving over them.
3. Avoid enemies to prevent losing lives.
4. Blink to indicate invincibility after losing a life.

### Player Attributes:

* x, y Coordinates: Position in the arena.
* Lives: Starts with three lives, which decrease on enemy collision.
* Invincibility: Player becomes temporarily invincible after losing a life.
* Appearance: Player’s design is customizable.

### Development Tips:

1. Implement separate functions for player movement (left/right and up/down) to simplify debugging.
2. Use the `display_blit_5x5_trans` function to visualize the player.
3. Add logic to handle boundary checks and ensure the player doesn't pass through walls.

## 3. MacGuffins

MacGuffins are collectible items scattered across empty tiles in the arena. Each MacGuffin contributes points to the player's score.

### MacGuffin Attributes:

* Position: Randomized or predefined positions in the arena’s empty tiles.
* Points: Each MacGuffin increases the player’s score.
* Animation: MacGuffins can be animated to create visual appeal.

### MacGuffin Interactions:

* When the player or enemy moves over a MacGuffin, it’s collected.
* Enemies and players compete for the MacGuffins, adding strategy to the gameplay.

### Development Tips:

1. Use an array or matrix to keep track of where MacGuffins are located.
2. Animate MacGuffins by alternating the displayed sprite every frame.


## 4. Enemies

Enemies introduce challenge and strategy to the game. The player’s goal is to avoid them while collecting MacGuffins.

### Enemy Behavior:

* Movement: Enemies follow movement paths (left/right, up/down) or chase the player using simple AI logic.
* Chase Mechanic: Enemies seek to minimize the distance to the player using the distance squared formula.
* Collision: If an enemy collides with the player, the player loses one life.

### Enemy Attributes:

* x, y Coordinates: Position in the arena.
* Direction: The direction (left, right, up, down) they are moving.
* Appearance: Customizable visual design for enemies.

### Development Tips:

1. Implement a "bounce" mechanic so enemies reverse direction when hitting walls.
2. Implement chasing logic where enemies calculate the shortest path to the player.
3. Use the `display_blit_5x5` function to display multiple enemies on the screen.


## 5. Collisions

Collisions are a fundamental mechanic in The MacGuffin Hunter. Collisions can occur between the player, enemies, walls, and MacGuffins.

### Types of Collisions:

1. Player-Enemy Collision: Player loses a life, becomes invincible, and blinks.
2. Player-Wall Collision: Player’s movement is restricted.
3. Player-MacGuffin Collision: Player collects a MacGuffin and increases score.
4. Enemy-MacGuffin Collision: Enemy collects a MacGuffin, removing it from the arena.

### Development Tips:

1. Use hitboxes to track player and enemy positions for more accurate collision detection.
2. Write a utility function to check if two 5x5 tiles overlap.


## 6. Game Flow

### Start Screen:
The game waits for the player to press a key to start.

### Gameplay Loop:

Player moves and collects MacGuffins.
Enemies move and chase the player.
The player’s score and lives are updated.
Game ends when all MacGuffins are collected or player loses all lives.

### Game Over Screen:
Displays player’s score and end-of-game message.

### Development Tips:

The function `input_get_keys` can be helpful.
When the game ends, you should display the player's score. Check `display_draw_int` and `display_draw_text`.
