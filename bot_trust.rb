class Robot
  attr_accessor :buttons

  def initialize
    @buttons = []
  end
end

class Coordinator
  def initialize(data_string)
    elements = data_string.split

    @number_of_buttons = elements.shift
    elements.each_slice(2) do |robot_color,button|
      robot_for_color(robot_color).buttons << button
    end

    puts robots.inspect
  end

  def robot_for_color(color)
    robots[color] ||= Robot.new
  end

  def robots
    @robots ||= {}
  end
end


Coordinator.new("4 O 2 B 1 B 2 O 4")