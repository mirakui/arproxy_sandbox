# require 'arproxy'
# 
# class QueryTracer < Arproxy::Base
#   def execute(sql, name=nil)
#     Rails.logger.debug "ARPROXY[ #{sql} ]"
#     super(sql, name)
#   end
# end
# 
# Arproxy.configure do |config|
#   config.adapter = "mysql2"
#   config.use QueryTracer
# end
# Arproxy.enable!
