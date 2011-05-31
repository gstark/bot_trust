DEBUG = false

class Robot
  attr_accessor :tasks
  attr_accessor :position
  attr_accessor :color

  def initialize(color)
    @color    = color
    @tasks    = []
    @position = 1
  end

  def add_task(button_to_press, dependency)
    new_dependency = ButtonPress.new

    @tasks << { :button_to_press => button_to_press.to_i,
                :dependency      => dependency,
                :trigger         => new_dependency }

    return new_dependency
  end

  def completed?
    @tasks.empty?
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
    @pending_trigger.complete if @pending_trigger

    @pending_trigger = nil
  end

  def wait
    puts "#{color} wait at #{position}" if DEBUG
  end

  def press_button
    @pending_trigger = tasks.first[:trigger]

    tasks.shift
  end

  def can_press_button?
    tasks.first && tasks.first[:dependency].completed
  end

  def need_to_move?
    tasks.first[:button_to_press] != position
  end

  def move
    @position += (tasks.first[:button_to_press] < position) ? -1 : 1
    puts "#{color} move to #{@position}" if DEBUG
  end
end

class ButtonPress
  attr_accessor :completed

  def initialize(state = {})
    self.complete if state[:completed]
  end

  def complete
    self.completed = true
  end
end

class Coordinator
  attr_accessor :tick_count

  def initialize(data_string)
    elements = data_string.split

    @number_of_buttons = elements.shift
    dependency         = ButtonPress.new(:completed => true)

    elements.each_slice(2) do |robot_color,button|
      robot = robot_for_color(robot_color)
      dependency = robot.add_task(button, dependency)
    end

    @tick_count = 0
  end

  def run
    tick until completed?
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


# Main
number_of_test_cases = STDIN.gets.to_i
number_of_test_cases.times do |case_number|
  coordinator = Coordinator.new(gets)
  coordinator.run
  puts "Case \##{case_number+1}: #{coordinator.tick_count}"
end
