$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
require 'rectangle'
require 'zorder'

require 'rubygems'
require 'gosu'

class DropArray < Array
  def initialize(max)
    @max = max
  end
  
  def unshift(obj)
    pop if length == @max
    super(obj)
  end
end

class Ball < Rectangle
  attr_accessor :angle, :speed
  attr_reader :x, :y, :width, :height

  def initialize(window, width, height)
    super(window, width, height, Gosu::Color::WHITE, ZOrder::BALL, true, ZOrder::BALL_GLOW)
    @speed = 0.0
    @blurs = DropArray.new(4)
    center
  end
  
  def center
    @x = @window.width / 2
    @y = @window.height / 2
  end
  
  def move(paddles)
    blur = Rectangle.new(@window, @width, @height, @color, ZOrder::BALL_BLUR, true, ZOrder::BALL_BLUR_GLOW)
    blur.warp(@x, @y)
    blur.angle = @angle
    @blurs.unshift(blur)
    @blurs.each do |x|
      new_alpha = x.color.alpha - 60
      new_alpha < 0 && new_alpha = 0
      x.color = Gosu::Color.new(new_alpha, x.color.red, x.color.green, x.color.blue)
    end
    
    @x += Gosu::offset_x(@angle, @speed)
    @y += Gosu::offset_y(@angle, @speed)
    
    # Top/Bottom collision
    if @y <= @speed || @window.height - @y <= @speed
      @angle = 180 - @angle
    end
    # FIXME: Remove Testing Code
    #if @x <= @speed || @window.width - @x <= @speed
    #  @angle = 360 - @angle
    #end
    
    if @x <= @speed
      paddles.last.score += 1
      @angle = 360 - @angle
      @speed = 0.0
      center
    end
    
    # Collide with paddles
    paddles.each do |paddle|
      if @x > paddle.left && @x < paddle.right && (@y > paddle.y ? @y - paddle.bottom <= @speed : paddle.top - @y <= @speed)
        @angle = 180 - @angle
      end
      if @y > paddle.top && @y < paddle.bottom && (@x > paddle.x ? @x - paddle.right <= @speed : paddle.left - @x <= @speed)
        @angle = 360 - @angle
      end
    end
  end
  
  def draw
    super
    @blurs.each do |blur|
      blur.draw
    end
  end
end
