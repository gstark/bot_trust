DEBUG = false

class Robot
  attr_accessor :buttons
  attr_accessor :dependencies
  attr_accessor :triggers
  attr_accessor :position
  attr_accessor :color

  def initialize(color)
    @color        = color
    @buttons      = []
    @dependencies = []
    @triggers     = []
    @position     = 1
  end

  def add_button(button, dependency)
    new_dependency = ButtonPress.new

    buttons      << button.to_i
    dependencies << dependency
    triggers     << new_dependency

    new_dependency
  end

  def completed?
    buttons.empty?
  end

  def tick
    case
      when completed?        then wait
      when need_to_move?     then move
      when can_press_button? then press_button
      else                   wait
    end
  end

  def post_tick
    @pending_trigger.completed = true if @pending_trigger

    @pending_trigger = nil
  end

  def wait
    puts "#{color} wait at #{position}" if DEBUG
  end

  def press_button
    @pending_trigger = triggers.first

    triggers.shift
    buttons.shift
    dependencies.shift
  end

  def can_press_button?
    dependencies.first && dependencies.first.completed
  end

  def need_to_move?
    buttons.first != position
  end

  def move
    @position += (buttons.first < position) ? -1 : 1
    puts "#{color} move to #{@position}" if DEBUG
  end
end

class ButtonPress
  attr_accessor :completed
end

class Coordinator
  attr_accessor :tick_count

  def initialize(data_string)
    elements = data_string.split

    @number_of_buttons = elements.shift
    dependency         = ButtonPress.new
    dependency.completed = true

    elements.each_slice(2) do |robot_color,button|
      dependency = robot_for_color(robot_color).add_button(button, dependency)
    end

    @tick_count = 0
  end

  def run
    until completed?
      tick
    end
  end

  def tick
    @tick_count += 1
    robots.each do |robot_color,robot|
      robot.tick
    end

    robots.each do |robot_color,robot|
      robot.post_tick
    end

  end

  def completed?
    robots.all? { |robot_color,robot| robot.completed? }
  end

  def robot_for_color(color)
    robots[color] ||= Robot.new(color)
  end

  def robots
    @robots ||= {}
  end
end


coordinator = Coordinator.new("4 O 2 B 1 B 2 O 4")

coordinator.run
puts coordinator.tick_count


coordinator = Coordinator.new("3 O 5 O 8 B 100")

coordinator.run
puts coordinator.tick_count



coordinator = Coordinator.new("2 B 2 B 1")

coordinator.run
puts coordinator.tick_count
