class FGMasterMessagePresentationEventController < Platform::FG_MasterMessagePresentationEventController
  attr_accessor :masterMapScreen
  def initialize(api, masterMapScreen)
    super(api)
    self.masterMapScreen = masterMapScreen
  end

  attr_accessor :messageViewController

  def displayMasterMessage(message)
    PM.logger.info "FGMasterMessageController. presentMasterMessage(#{message.inspect})"
    self.messageViewController = MasterMessageViewController.new(message, masterMapScreen)
    messageViewController.display
  end

  def dismissMasterMessage(message)
    PM.logger.info "FGMasterMessageController. dismissMasterMessage(#{message.inspect})"
    if messageViewController
      messageViewController.dismiss
      messageViewController = nil
    end
  end

end