module IPhone
  class BuspassEventDistributor < ::Api::BuspassEventDistributor
    def initialize(args = {})
      super
      @sem = Dispatch::Semaphore.new(0)
    end
    def rollAll
      super
      Dispatch::Queue.main.sync do
        20.seconds.later do
         #puts "BG(#{self.name}) SIGNAL"
          @sem.signal
        end
      end
     #puts "BG(#{self.name}) WAIT"
      @sem.wait
     #puts "BG(#{self.name}) RELEASE"
    end
  end
end