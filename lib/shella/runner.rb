module Shella
  class Runner
    def initialize(lines)
      @lines = lines.map { |line| line.strip }
    end

    def run
      @lines.each do |line|
        next if line.size.zero?
        command, args = line.split(" ", 2)
        Shella::Shell.send(command, args)
      end
    end
  end
end


