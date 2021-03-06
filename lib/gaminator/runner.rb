# encoding: utf-8

require "curses"

module Gaminator
  class Runner
    include Curses

    def initialize(game_class, options = {})
      if options[:rows] && options[:cols]
        resizeterm(options[:rows], options[:cols])
      end

      init_screen
      start_color
      cbreak
      noecho
      stdscr.nodelay = 1
      curs_set(0)

      [
        COLOR_WHITE, COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_CYAN,
        COLOR_MAGENTA, COLOR_YELLOW
      ].each do |color|
        init_pair(color, color, COLOR_BLACK)
      end

      if colors > 8
        (8..colors-1).each do |color|
          init_pair(color, color, COLOR_BLACK)
        end
      end

      @plane_width = cols
      @plane_height = lines - 5
      @plane = Window.new(@plane_height, @plane_width, 0, 0)
      @plane.box("|", "-")

      @textbox_width = cols
      @textbox_height = 5
      @textbox = Window.new(@textbox_height, @textbox_width, @plane_height, 0)
      @textbox.box("|", "-")

      @game = game_class.new(@plane_width - 2, @plane_height - 2)
    end

    def run
      begin
        loop do
          tick_game

          render_objects
          render_textbox

          @plane.refresh
          @textbox.refresh

          handle_input

          clear_plane
          clear_textbox

          sleep(@game.sleep_time)
        end
      ensure
        close_screen
        puts
        puts @game.exit_message
        puts
      end
    end

    private

    def handle_input
      if @game.wait?
        @textbox.timeout = -1
      else
        @textbox.timeout = 0
      end
      char = @textbox.getch
      action = @game.input_map[char]
      if action && @game.respond_to?(action)
        @game.send(action)
      end
    end

    def tick_game
      @game.tick
    end

    def render_objects
      @game.objects.each do |object|
        render_object(object)
      end
    end

    def render_object(object)
      color = object.respond_to?(:color) ? object.color : COLOR_WHITE
      texture = object.texture if object.respond_to?(:texture)
      texture ||= [object.char]

      texture.each.with_index do |row,row_index|
        row.each_char.with_index do |pixel,pixel_index|
          x = object.x + 1 + pixel_index
          y = object.y + 1 + row_index
          next if x < 1 || x >= @plane_width
          next if y < 1 || y >= @plane_height

          if object.respond_to?(:colors) && object.colors
            color = object.colors[row_index][pixel_index]
          end

          @plane.setpos(y,x)
          @plane.attron(color_pair(color) | A_NORMAL) do
            @plane.addstr(pixel)
          end
        end
      end
    end

    def render_textbox
      @textbox.setpos(2, 3)
      @textbox.addstr(@game.textbox_content)
    end

    def clear_plane
      1.upto(@plane_height - 2) do |y|
        1.upto(@plane_width - 2) do |x|
          @plane.setpos(y, x)
          @plane.addstr(" ")
        end
      end
    end

    def clear_textbox
      1.upto(@textbox_height - 2) do |y|
        1.upto(@textbox_width - 2) do |x|
          @textbox.setpos(y, x)
          @textbox.addstr(" ")
        end
      end
    end
  end
end
