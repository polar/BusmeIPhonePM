class UIEventQueue

  attr_accessor :api
  attr_accessor :bqQueue

  def initialize(api)
    self.api = api
    api.uiEvents.postEventListener = self
    api.bgEvents.postEventlistener = self
    self.bgQueue = Display::Queue.new("background")
  end

  def onPostEveent(queue)
    if queue == api.uiEvents
      Display::Queue.main.async do
        api.uiEvents.rollAll
      end
    else
      bgQueue.async do
        api.bgEvents.rollAll
      end
    end
  end

end