module IPhone
  class EventsController
    attr_accessor :appDelegate
    attr_accessor :bgEvents
    attr_accessor :uiEvents

    def initialize(args)
      self.appDelegate = args.delete :delegate

      @bgQueue = Dispatch::Queue.new("background")
      @bgQueueTime = Time.now
      @bgQueueCount = 0
      @bgQueueSize = 0
      @fgQueue = Dispatch::Queue.current
      @fgQueueTime = Time.now
      @fgQueueCount = 0
      @fgQueueSize = 0
    end

    def register(api)
      self.uiEvents = api.uiEvents
      self.bgEvents = api.bgEvents
      bgEvents.postEventListener = self
      uiEvents.postEventListener = self
    end

    def fixEventDistributors(api, name)
      self.uiEvents = api.uiEvents = ::Api::BuspassEventDistributor.new(name: "IPhone:UIEvents(#{name})")
      self.bgEvents = api.bgEvents = ::Api::BuspassEventDistributor.new(name: "IPhone:BGEvents(#{name})")
      bgEvents.postEventListener = self
      uiEvents.postEventListener = self
    end

    def onPostEvent(queue)
      #puts "onPostEvent from #{queue} from #{Dispatch::Queue.current}"
      if /BGEvents/ =~ queue.name
        #puts "onPostEvent dispatching to #{@bgQueue}"
        @bgQueueSize += 1
        puts "onPostEvent dispatching to #{@bgQueue} #{@bgQueueSize}"
        @bgQueue.async do
          start_time = Time.now
          tdiff = Time.now - @bgQueueTime
          puts "onPostEvent#{@bgQueue}: tdiff #{tdiff} count #{@bgQueueCount} size #{@bgQueueSize}"
          puts "onPostEvent:rollAll from #{queue} #{queue.eventQ.size} on #{Dispatch::Queue.current}"
          queue.rollAll
          @bgQueueCount += 1
          @bgQueueTime = Time.now
          @bgQueueSize -= 1
          end_time = Time.now
          spent = end_time - start_time
          puts "onPostEvent rolled All in #{spent} from  #{queue} #{queue.eventQ.size} on  #{Dispatch::Queue.current} size #{@bgQueueSize}"
        end
      else
        @fgQueueSize += 1
        puts "onPostEvent dispatching to #{@fgQueue} #{@fgQueueSize}"
        @fgQueue.async do
          start_time = Time.now
          tdiff = Time.now - @fgQueueTime
          puts "onPostEvent: tdiff #{tdiff} count #{@fgQueueCount} size #{@fgQueueSize}"
          puts "onPostEvent:rollAll from #{queue} on #{Dispatch::Queue.current}"
          queue.rollAll
          @fgQueueCount += 1
          @fgQueueTime = Time.now
          @fgQueueSize -= 1
          spent = Time.now - start_time
          puts "onPostEvent rolled All in #{spent} from  #{queue} on  #{Dispatch::Queue.current} size #{@fgQueueSize}"
        end
        puts "onPostEvent dispatched to #{@fgQueue}"
      end
    end
  end
end