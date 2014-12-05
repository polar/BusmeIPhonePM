module A
  def app
    UIApplication.sharedApplication.delegate
  end
  def scr
    app.discoverScreen
  end
  def map
    app.discoverScreen.map
  end
  def blue
    Locator.get("blue")
  end
  def red
    Locator.get('red')
  end
  def green
    Locator.get("green")
  end
end

class BLocation
  attr_accessor :title
  attr_accessor :subtitle
  attr_accessor :identifier
  attr_accessor :direction
  attr_accessor :view

  def initialize(coord)
    @coordinate = coord
    self.direction = 1.0
    self.title = "Title"
  end

  def coordinate
    @coordinate
  end
  def setCoordinate(coord)
    @coordinate = coord
  end
  def direction=(d)
    @direction = d
    update
  end

  attr_accessor :icon

  def update
    view.update if view
  end
end