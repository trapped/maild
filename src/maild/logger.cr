LOG_TIME_FORMAT = "%d/%b/%Y:%H:%M:%S %z"

macro info(message)
  puts "#{TimeFormat.new(LOG_TIME_FORMAT).format Time.now} - INFO  - #{__FILE__}: #{{{message}}}"
end

macro error(message)
  puts "#{TimeFormat.new(LOG_TIME_FORMAT).format Time.now} - ERROR - #{__FILE__}:#{__LINE__}: #{{{message}}}"
end

class Object
  macro info(message)
    puts "#{TimeFormat.new(LOG_TIME_FORMAT).format Time.now} - INFO  - #{caller[0][/::(\w+)#(\w+)</i, 1]}##{caller[0][/::(\w+)#(\w+)</i, 2]}: #{{{message}}}"
  end

  macro error(message)
    puts "#{TimeFormat.new(LOG_TIME_FORMAT).format Time.now} - ERROR - #{caller[0][/::(\w+)#(\w+)</i, 1]}##{caller[0][/::(\w+)#(\w+)</i, 2]}:#{__LINE__}: #{{{message}}}"
  end
end