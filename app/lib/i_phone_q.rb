class IPhoneQ < Utils::Queue

  def initialize(elemns = nil)
    super(elemns)
    @lock = Dispatch::Semaphore.new(1)
  end

  def push(event)
    puts "Queue #{self} :push Wait on #{Dispatch::Queue.current}"
    @lock.wait
    puts "Queue #{self} :push Rel on #{Dispatch::Queue.current}"
    res = super(event)
    @lock.signal
    puts "Queue #{self} :push signal"
    res
  end

  def poll
    puts "Queue #{self} :poll Wait on #{Dispatch::Queue.current}"
    @lock.wait
    puts "Queue #{self} :poll Rel on #{Dispatch::Queue.current}"
    res = super
    @lock.signal
    puts "Queue #{self} :poll signal with Event #{res ? res.eventName : 'none'}"
    res
  end

  def pop
    puts "Queue #{self} :pop Wait on #{Dispatch::Queue.current}"
    @lock.wait
    puts "Queue #{self} :pop Rel on #{Dispatch::Queue.current}"
    res = super
    @lock.signal
    puts "Queue #{self} :pop signal with Event #{res ? res.eventName : 'none'}"
    res
  end

  def delete(event)
    @lock.wait
    res = super(event)
    @lock.signal
    res
  end

  def peek
    puts "Queue #{self} :peek Wait on #{Dispatch::Queue.current}"
    @lock.wait
    puts "Queue #{self} :peek Rel on #{Dispatch::Queue.current}"
    res = super
    @lock.signal
    puts "Queue #{self} :peek signal"
    res
  end
end