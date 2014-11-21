module IPhone
  class EventsController
    attr_accessor :appDelegate
    attr_accessor :eventControllers

    def initialize(args)
      self.appDelegate = args.delete :delegate
      self.eventControllers = []

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
      self.eventControllers << api.uiEvents
      self.eventControllers << api.bgEvents
      api.bgEvents.postEventListener = PostEventListener.new(@bgQueue, api.bgEvents)
      api.uiEvents.postEventListener = PostEventListener.new(@fgQueue, api.uiEvents)
    end

    def unregister(api)
      if api.uiEvents.postEventListener
        api.uiEvents.postEventListener.unregister
        self.eventControllers.delete(api.uiEvents)
      end
      if api.bgEvents.postEventListener
        api.bgEvents.postEventListener.unregister
        self.eventControllers.delete(api.bgEvents)
      end
    end

    class PostEventListener
      def initialize(dispatchQ, eventQ)
        @dispatchQ = dispatchQ
        @eventQ = eventQ
        @queueTime = Time.now
        @queueCount = 0
        @queueSize = 0
      end

      def unregister
        @dispatchQ = nil
        @eventQ = nil
      end

      def to_s
        "PostEventListener(#{@dispatchQ},#{@eventQ})"
      end
      def onPostEvent
       #puts "#{self.to_s}:onPostEvent"
        @queueSize += 1
       #puts "#{self.to_s}:onPostEvent dispatching to #{@dispatchQ} #{@queueSize}"
        @dispatchQ.async do
          start_time = Time.now
          tdiff = Time.now - @queueTime
         #puts "#{self.to_s}:onPostEvent#{@eventQ}: tdiff #{tdiff} count #{@queueCount} size #{@queueSize}"
         #puts "#{self.to_s}:onPostEvent:rollAll from #{@eventQ} #{@eventQ.eventQ.size} on #{Dispatch::Queue.current}"
         #puts "#{self.to_s}:onPostEvent:rollAll make array #{[]}"
          @eventQ.rollAll if @eventQ
          @queueCount += 1
          @queueTime = Time.now
          @queueSize -= 1
          end_time = Time.now
          spent = end_time - start_time
         #puts "#{self.to_s}:onPostEvent: Finished rollAll in #{spent} from  #{@eventQ} #{@eventQ.eventQ.size} on  #{Dispatch::Queue.current} size #{@queueSize}"
         #puts "#{self.to_s}:onPostEvent: Finished rollAll make array #{[]}"
        end if @dispatchQ
      end
    end
  end
end