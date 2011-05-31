class Robot
  attr_accessor :buttons
  attr_accessor :position

  def initialize
    @buttons = []
    @position = 1
  end

  def complete?
    true
  end
end

class Coordinator
  attr_accessor :tick_count

  def initialize(data_string)
    elements = data_string.split

    @number_of_buttons = elements.shift
    elements.each_slice(2) do |robot_color,button|
      robot_for_color(robot_color).buttons << button
    end

    @tick_count = 0
  end

  def run
    until complete?
      tick
    end
  end

  def tick
    @tick_count += 1
  end

  def complete?
    tick_count > 10
    # robots.all? { |robot| robot.complete?}
  end

  def robot_for_color(color)
    robots[color] ||= Robot.new
  end

  def robots
    @robots ||= {}
  end
end


coordinator = Coordinator.new("4 O 2 B 1 B 2 O 4")

coordinator.run
puts coordinator.tick_count
