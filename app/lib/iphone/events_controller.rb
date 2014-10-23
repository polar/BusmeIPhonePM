module IPhone
  class EventsController
    attr_accessor :appDelegate
    attr_accessor :bgEvents
    attr_accessor :uiEvents

    def initialize(args)
      self.appDelegate = args.delete :delegate

      @bgQueue = Dispatch::Queue.new("background")
      @fgQueue = Dispatch::Queue.current
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
        @bgQueue.async do
          #puts "onPostEvent:rollAll from #{queue} #{queue.eventQ.size} on #{Dispatch::Queue.current}"
          queue.rollAll
          #puts "onPostEvent rolled All from  #{queue} #{queue.eventQ.size} on  #{Dispatch::Queue.current}"
        end
      else
        #puts "onPostEvent dispatching to #{@fgQueue}"
        @fgQueue.async do
          #api.uiEvents.rollAllWith(Proc.new {|roller| rollUIEventsAsynch(roller)})
          #puts "onPostEvent:rollAll from #{queue} on #{Dispatch::Queue.current}"
          queue.rollAll
          #puts "onPostEvent rolled All from  #{queue} on  #{Dispatch::Queue.current}"
        end
      end
    end
  end
end