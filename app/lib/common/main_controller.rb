class MasterController < Platform::MasterController

  def mainController=(mc)
    @mainController = WeakRef.new(mc)
  end
end


class MainController < Platform::MainController
  def instantiateMasterController(args)
    puts "Creating new Master Controller"
    MasterController.new(args).tap do |mc|
     # mc.loginForeground = LoginForeground.new(mc.api,args[:masterMapScreen])
    end
  end
end