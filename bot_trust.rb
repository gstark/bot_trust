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
    new_dependency = Dependency.new

    @tasks << { :button_to_press        => button_to_press.to_i,
                :dependency_to_wait     => dependency,
                :dependency_to_complete => new_dependency }

    return new_dependency
  end

  def completed?
    @tasks.empty?
  end

  def tick
    @post_tick_procs = []

    case
      when completed?        then wait
      when need_to_move?     then move
      when can_press_button? then press_button
      else                   wait
    end
  end

  def post_tick
    @post_tick_procs.each { |proc| proc.call }
  end

  def wait
    puts "#{color} wait at #{position}" if DEBUG
  end

  def press_button
    # Set the post tick proc to complete this dependency
    dependency_to_complete = current_task[:dependency_to_complete]
    @post_tick_procs << Proc.new { dependency_to_complete.complete! }

    tasks.shift
  end

  def can_press_button?
    current_task[:dependency_to_wait].completed
  end

  def need_to_move?
    current_task[:button_to_press] != position
  end

  def move
    @position += (current_task[:button_to_press] < position) ? -1 : 1
    puts "#{color} move to #{@position}" if DEBUG
  end

  def current_task
    tasks.first
  end
end

class Dependency
  attr_accessor :completed

  def initialize(state = {})
    self.complete! if state[:completed]
  end

  def complete!
    self.completed = true
  end
end

class Coordinator
  attr_accessor :tick_count

  def add_button_press_task_to_robot(button,robot)
    @previous_dependency = robot.add_task(button, @previous_dependency)
  end

  def initialize(data_string)
    elements = data_string.split

    @number_of_buttons = elements.shift

    # Having to "prime the pump" with a completed dependency
    # makes the robot code easier, but seems a bit hackish here
    @previous_dependency = Dependency.new(:completed => true)
    elements.each_slice(2) do |robot_color,button|
      add_button_press_task_to_robot(button, robot_for_color(robot_color))
    end

    @tick_count = 0
  end

  def run
    tick until completed?
  end

  def tick
    robots.each { |robot_color,robot| robot.tick }
    robots.each { |robot_color,robot| robot.post_tick }

    @tick_count += 1
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
