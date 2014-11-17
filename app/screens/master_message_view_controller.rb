class MasterMessageViewController < UIViewController

  attr_accessor :masterMessage
  attr_accessor :masterMapScreen
  attr_accessor :buttonIndexes

  def initialize(masterMessage, masterMapScreen)
    PM.logger.warn "MasterMessageViewController.new #{masterMessage.inspect}"
    self.masterMessage = masterMessage
    self.masterMapScreen = masterMapScreen
    self.buttonIndexes = []
    # Seems to be some problem setting otherButtonTitles with a nil terminated string array.
    self.view = UIAlertView.alloc.initWithTitle(masterMessage.title,
                                                     message: masterMessage.content,
                                                     delegate:self,
                                                     cancelButtonTitle: "OK",
                                                     otherButtonTitles: nil)
    index = 1
    if true || masterMessage.goUrl && !masterMessage.goUrl.empty?
      view.addButtonWithTitle("Go")
      self.buttonIndexes[index] = :go
      index += 1
    end
    if masterMessage.remindable
      view.addButtonWithTitle("Remind Me Later")
      self.buttonIndexes[index] = :remind
      index += 1
    end
    self.buttonIndexes[index] = :cancel
    index += 1
    self
  end

  def viewDidLoad
    puts "MasterMessageViewController.viewDidLoad"

  end

  def alertView(alertView, clickedButtonAtIndex: index)
    puts "MasterMessageView: Button #{index} clicked!"
    case buttonIndexes[index]
      when :go
        masterMessage.onDismiss(false, Utils::Time.current)
        webScreen = MasterMessageWebScreen.new(:nav_bar => true)
        webScreen.title = masterMessage.title
        webScreen.open_url("http://busme.us")
        masterMapScreen.open webScreen
      when :remind
        masterMessage.onDismiss(true, Utils::Time.current)
      when :cancel
        masterMessage.onDismiss(false, Utils::Time.current)
    end
    masterMapScreen.masterController.masterMessageController.onDismiss
  end

  def display
    puts "MasterMessageViewController.display"
    view.show
  end

  def dismiss
    puts "MasterMessageViewController.dismiss"
    view.dismissWithClickedButtonIndex(0, animated: true)
  end
end