class MarkerMessageViewController < UIViewController

  attr_accessor :markerInfo
  attr_accessor :masterMapScreen
  attr_accessor :buttonIndexes

  def initialize(markerInfo, masterMapScreen)
    PM.logger.warn "MarkerMessageViewController.new #{markerInfo.inspect}"
    self.markerInfo = markerInfo
    self.masterMapScreen = masterMapScreen
    self.buttonIndexes = []
    # Seems to be some problem setting otherButtonTitles with a nil terminated string array.
    self.view = UIAlertView.alloc.initWithTitle(markerInfo.title,
                                                     message: markerInfo.content,
                                                     delegate:self,
                                                     cancelButtonTitle: "OK",
                                                     otherButtonTitles: nil)
    # Instead we set the other button titles after creation
    index = 1
    if markerInfo.goUrl && !markerInfo.goUrl.empty?
      view.addButtonWithTitle("Go")
      self.buttonIndexes[index] = :go
      index += 1
    end
    if markerInfo.remindable
      view.addButtonWithTitle("Remind Me Later")
      self.buttonIndexes[index] = :remind
      index += 1
    end
    self.buttonIndexes[index] = :cancel
    index += 1
    self
  end

  def viewDidLoad
    puts "MarkerMessageViewController.viewDidLoad"

  end

  def alertView(alertView, clickedButtonAtIndex: index)
    puts "MarkerMessageView: Button #{index} clicked!"
    case buttonIndexes[index]
      when :go
        webScreen = MarkerMessageWebScreen.new(
            :title => markerInfo.title,
            :url => markerInfo.goUrl,
            :nav_bar => true)
        masterMapScreen.open webScreen
      when :remind
        masterMapScreen.masterController.markerPresentationController.dismissMarker(markerInfo, true)
      when :cancel
    end
  end

  def display
    puts "MarkerMessageViewController.display"
    view.show
  end

  def dismiss
    puts "MaarkerMessageViewController.dismiss"
    view.dismissWithClickedButtonIndex(0, animated: true)
  end
end