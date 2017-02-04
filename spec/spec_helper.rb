Dir.glob(__dir__ + '/../lib/*.rb').each {|p| require p }
Dir.glob(__dir__ + '/../lib/*.so').each {|p| require p }
Dir.glob(__dir__ + '/../lib/*.bundle').each {|p| require p }

$:.unshift(File.dirname(__FILE__) + '/../lib')
