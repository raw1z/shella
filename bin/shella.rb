$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'shella'

unless ARGV.size == 1
  puts "usage: shella <filename>"
  exit
end

File.open(ARGV.first) do |f|
  Shella::Runner.new(f.lines).run
end
