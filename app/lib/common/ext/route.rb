Api::Route.class_eval do
  def busAPI=(api)
    @busAPI = WeakRef.new(api)
  end

  def journeyStore=(js)
    @journeyStore = WeakRef.new(js)
  end
end
