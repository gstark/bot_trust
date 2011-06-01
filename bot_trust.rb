DEBUG = false

class Robot
  attr_reader :tasks
  attr_reader :position
  attr_reader :color

  def initialize(color)
    @color    = color
    @tasks    = []
    @position = 1
  end

  def add_task(button_to_press, dependency_to_wait, dependency_to_trigger)
    @tasks << { :button_to_press        => button_to_press.to_i,
                :dependency_to_wait     => dependency_to_wait,
                :dependency_to_complete => dependency_to_trigger }
  end

  def completed?
    tasks.empty?
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
    # and remove the task from the queue
    @post_tick_procs << Proc.new { current_task[:dependency_to_complete].complete! }
    @post_tick_procs << Proc.new { tasks.shift }
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

  def add_button_press_task_to_robot(button, robot)
    dependency_to_wait    = @dependency_to_wait || Dependency.new(:completed => true)
    dependency_to_trigger = Dependency.new

    robot.add_task(button, dependency_to_wait, dependency_to_trigger)

    @dependency_to_wait = dependency_to_trigger
  end

  def initialize(data_string)
    elements = data_string.split

    # Consume the number of buttons to press as
    # we can figure that out from the input
    elements.shift

    # Having to "prime the pump" with a completed dependency
    # makes the robot code easier, but seems a bit hackish here
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
