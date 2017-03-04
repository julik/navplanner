Dir.glob(__dir__ + '/../lib/*.rb').each {|p| require p }
$:.unshift(File.dirname(__FILE__) + '/../lib')
