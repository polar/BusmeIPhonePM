class ProgressModal < UIView
  attr_accessor :iRoute
  attr_accessor :nRoutes
  attr_accessor :master

  def initialize(master)
    self.master = master
    JSON.generate(master)
  end
end

