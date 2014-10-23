#String.class.send(:alias_method, :old_encode, :encode)
String.class_eval do

  def encode(*args)
    puts "Encode(#{args.inspect}) '#{self}'"
    if self == '>'
      return ">"
    end
  end
end