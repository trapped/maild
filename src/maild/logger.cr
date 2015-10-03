require "time/format"

LOG_TIME_FORMAT = "%d/%b/%Y:%H:%M:%S %z"

$no_logging = false

macro info(message)
  unless $no_logging
    puts "#{Time::Format.new(LOG_TIME_FORMAT).format Time.now} - INFO  - #{__FILE__}: #{{{message}}}"
  end
end

macro error(message)
  unless $no_logging
    puts "#{Time::Format.new(LOG_TIME_FORMAT).format Time.now} - ERROR - #{__FILE__}:#{__LINE__}: #{{{message}}}"
  end
end

class Object
  macro info(message)
    unless $no_logging
      puts "#{Time::Format.new(LOG_TIME_FORMAT).format Time.now} - INFO  - #{caller[0][/::(\w+)#(\w+)</i, 1]?}##{caller[0][/::(\w+)#(\w+)</i, 2]?}: #{{{message}}}"
    end
  end

  macro error(message)
    unless $no_logging
      puts "#{Time::Format.new(LOG_TIME_FORMAT).format Time.now} - ERROR - #{caller[0][/::(\w+)#(\w+)</i, 1]?}##{caller[0][/::(\w+)#(\w+)</i, 2]?}:#{__LINE__}: #{{{message}}}"
    end
  end
end