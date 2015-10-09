require "readline"
require "concurrent/channel"

require "active_record"
require "fs_adapter"
require "./maild/database"

module Maild
  def self.find_models(name : String?) : Array(Class.class)
    raise "Model name is required" if name.nil? || name.not_nil!.empty?
    models = [User]
    pattern = Regex.new name.not_nil!
    results = models.map do |model|
      pattern =~ model.name.split("::").last ? model : nil
    end.reject &.nil?
    raise "Unknown model" unless results.size > 0
    results.map(&.not_nil! as Class) as Array(Object.class)
  end

  def self.eval(data)
    query = data.split " "
    begin
      case query.shift?
      when nil
        return
      when "all"
        model_name = query.shift?
        models = find_models(model_name)
        models.each do |m|
          puts "#{m.name}: #{m.all.map(&._raw_fields).inspect}"
        end
      when "find"
        model_name = query.shift?
        models = find_models(model_name)
        row_number = query.shift? || raise "Missing argument: row number"
        models.each do |m|
          result = m.find(row_number.to_i)
          puts "#{m.name}: #{result._raw_fields.inspect unless result.id.is_a? Int::Null}"
        end
      else
        puts "Unknown method"
      end
    rescue ex
      puts ex.message
    end
  end
end

IN = Channel(String).new

spawn do
  loop do
    line = Readline.readline "db> ", true
    if line
      IN.send line
    else
      exit 0
    end
  end
end

loop do
  Maild.eval IN.receive
end