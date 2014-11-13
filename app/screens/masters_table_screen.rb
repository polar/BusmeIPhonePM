class MastersTableScreen < PM::TableScreen
  include Orientation
  title "Muncipalities"
  refreshable
  searchable placeholder: "Search Municipalities"

  attr_accessor :mainController

  # initialize doesn't get called because Promotion overrides new
  def self.newScreen(args)
   #puts "Initialize MastersTable Screen"
    mainController = args.delete :mainController
   #puts "Initialize MastersTable Screen #{mainController}"
    s = self.new(args)
    s.mainController = mainController
    s.after_init
    s
  end

  def on_load
    # The Apple notifications of rotate transisitions appears to be fucked totatlly.
    # I can't get default notifications her from on_rotate, etc. Garbage. We have to
    # make some assumptions and hopefully we can make some idiot based decisions.
    @current_device_orientation = UIDevice.currentDevice.orientation
   #puts "MasterMapScreen: loading at #{device_orientation_names[@current_device_orientation]}"
    @current_screen_size = UIScreen.mainScreen.bounds
   #puts "MasterMapScreen: loading mainScreen.bounds #{@current_screen_size.inspect}"
   #puts "MasterMapScreen: loading screenZize #{screenSize.inspect}"
   #puts "MasterMapScreen: loading frame #{view.frame.inspect}"

    "UIDeviceOrientationDidChangeNotification".add_observer(self, :resizeIt)
  end

  def screenSize
    size = UIScreen.mainScreen.bounds.size
    if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 && interface_landscape?(UIApplication.sharedApplication.statusBarOrientation)
      size = CGMakeSize(size.height, size.width)
    end
    size
  end

  def resizeIt(*note)
   #puts "MasterMapScreen: resizeIt Device #{device_orientation_names[note.object.orientation]} view.frame #{view.frame.inspect} view.bounds #{view.bounds.inspect}}"

   #puts "MasterMapScreen: resizeIt mainScreen.bounds #{UIScreen.mainScreen.bounds.inspect}"
   #puts "MasterMapScreen: resizeIt screenZize #{screenSize.inspect}"
   #puts "MasterMapScreen: resizeIt frame #{view.frame.inspect}"
  end

  def after_init
    set_nav_bar_button :back, :title => "Back", :style => :plain, :action => :back
    update_table_data
  end

  def table_data
    if mainController
      masters = mainController.discoverController.masters
      @table_data = [{
                         cells: masters.map do |master|
                          { :title => master.name,
                            :action => :select_master,
                            :arguments => { :master => master } }
                         end
                     }]
    else
      []
    end
  end

  def select_master(args)
    master = args[:master]
    if master
      masterApi = IPhone::Api.new(master)
      eventData = Platform::MasterEventData.new(
          :data => { :master => master, :masterApi => masterApi}
      )
      mainController.bgEvents.postEvent("Main:Master:init", eventData)
    end
  end

  def should_rotate(orientation)
   #puts "MasterMapScreen: should_rotate(#{interface_orientation_names[orientation]})"
   #puts "MasterMapScreen: should_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end

  def will_rotate(orientation, duration)
   #puts "MasterMapScreen: will_rotate(#{interface_orientation_names[orientation]}, #{duration})"
   #puts "MasterMapScreen: will_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end

  def on_rotate
    #puts "MasterMapScreen: on_rotate(#{interface_orientation_names[orientation]})"
   #puts "MasterMapScreen: on_rotate Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.inspect} bounds #{bounds.inspect}"
  end
  # iOS 8
  def viewWillTransitionToSize(size, withTransitionCoordinator:coordinator)
    super
   #puts "MasterMapScreen: viewWillTransitionToSize(#{size.inspect}"
   #puts "MasterMapScreen: screen #{UIScreen.mainScreen.bounds.inspect}"
   #puts "MasterMapScreen: UserInterface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.frame.inspect} bounds #{view.bounds.inspect}"
  end

  # iOS 8
  def traitCollectionDidChange(previousTraitCollection)
    super
   #puts "MasterMapScreen: traitCollectionDidChange previous #{previousTraitCollection.inspect}"
   #puts "MasterMapScreen: traitCollectionDidChange previous vertical #{previousTraitCollection.verticalSizeClass}" if previousTraitCollection
   #puts "MasterMapScreen: traitCollectionDidChange previous horizontal #{previousTraitCollection.horizontalSizeClass}" if previousTraitCollection
   #puts "MasterMapScreen: traitCollectionDidChange current #{traitCollection.inspect}"
   #puts "MasterMapScreen: traitCollectionDidChange current vertical #{traitCollection.verticalSizeClass.inspect}"
   #puts "MasterMapScreen: traitCollectionDidChange current horizontal #{traitCollection.horizontalSizeClass.inspect}"
  end
end