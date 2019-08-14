require 'arproxy'

class QueryTracer < Arproxy::Base
  def execute(sql, name=nil)
    puts "ARPROXY[ #{sql} ]"
    super(sql, name)
  end
end

Arproxy.configure do |config|
  config.adapter = "<%= adapter %>"
  config.use QueryTracer
end
Arproxy.enable!
