ProMotion::Logger.class_eval do

  def log(label, message_text, color)
    NSLog("[#{label}] #{message_text}")
    nil
  end
end