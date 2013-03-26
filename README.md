# Gaminator

A simple wrapper around Curses intended for writing ASCII games

Post game submissions here: https://gist.github.com/4684252

## Usage

The Gaminator::Runner class implements the base methods used to
run the game, the event loop being the most important. Initialize
it like so:

```
# If you want the game to fill the whole screen
Gaminator::Runner.new(SkiGame).run

# If you want the game to have a set size (in rows/cols)
Gaminator::Runner.new(SkiGame, :rows => 30, :cols => 80).run
```

The Game that is run by the GameRunner has to implement the
following methods:

* objects - the array of objects that are displayed on the screen
* input_map - the mapping between the keyboard keys and game actions
* tick - the method that is called for every loop cycle
* exit_message - the message displayed when the game is finished
* textbox_content - the message displayed at the bottom of the game window
* wait? - determine whether to wait for input before next tick
* sleep_time - the time interval beteen two event loop cycles

The objects that are displayed on the screen have to implement the following
interface:

* x - the x position of the object
* y - the y position of the object
* char (optional) - the text representation of the object
* color (optional) - the color of the object
* texture (optional) - an array of string representing a row in a bigger shape
* colors (optional) - an array of arrays (rows) of Curses color constants,
  the texture will be colored accordingly

You have to define either char or texture method on each object.

Every color-capable terminal will support at least the 8 basic ANSI colors:

```
Curses::COLOR_BLACK = 0
Curses::COLOR_RED = 1
Curses::COLOR_GREEN = 2
Curses::COLOR_YELLOW = 3
Curses::COLOR_BLUE = 4
Curses::COLOR_MAGENTA = 5
Curses::COLOR_CYAN = 6
Curses::COLOR_WHITE = 7
```

If available, gaminator initializes color pairs for the remaining additional
colors (up to 256 total) so you can literally puke 8-bit rainbows. These
color pairs are assigned the numbers 8-255, without any fancy constants defined
for them. Could YOU name 256 colors? 

## Installation

Add this line to your application's Gemfile:

    gem "gaminator", :git => "git://github.com/futuresimple/gaminator.git"

Execute:

    $ bundle

And put following lines on top of your script file:

    require "bundler/setup"
    require "gaminator"



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
