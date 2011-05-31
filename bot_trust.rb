class Coordinator
  def initialize(data_string)
    elements = data_string.split

    @number_of_buttons = elements.shift
    elements.each_slice(2) do |robot,button|
      puts [robot,button].inspect
    end
  end
end


Coordinator.new("4 O 2 B 1 B 2 O 4")