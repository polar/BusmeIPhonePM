class RoutesView < PM::TableScreen
  include Orientation
  longpressable

  attr_accessor :masterController
  attr_accessor :masterMapScreen
  attr_accessor :backButton
  attr_accessor :tabButton

  def self.newView(args)
    masterController = args.delete :masterController
    masterMapScreen = args.delete :masterMapScreen
    m = self.new(args)
    m.masterController = masterController
    m.masterMapScreen = masterMapScreen
    m.after_init
    m
  end

  def masterController=(mc)
    @masterController = WeakRef.new(mc)
  end

  def masterMapScreen=(ms)
    @masterMapScreen = WeakRef.new(ms)
  end

  def tabButton=(tb)
    @tabButton = WeakRef.new(tb)
  end

  def slide_out
   #puts "RoutesView : slide_out"
    @view_origin = view.origin
    view.animate(1.0) { view.alpha=0; view.origin = [view.origin.x + view.origin.x + view.size.width + 10, view.origin.y]}
    tabButton.slide_in
    @view_is_out = true
  end

  def slide_in
   #puts "RoutesView : slide_in"
    view.animate(1.0) { view.alpha=1; view.origin = @view_origin}
    tabButton.slide_out
    @view_is_out = false
  end

  def toggle_slide
    if @view_is_out
      slide_in
    else
      slide_out
    end
  end

  def on_load
   #puts "RoutesView on_load #{view.superview}"
    self.backButton = UIButton.rounded_rect
    self.backButton.size =  [50,28]
    self.backButton.title = "< Back"
    self.backButton.titleLabel.adjustsFontSizeToFitWidth = true
    self.backButton.on(:touch) do
      journeyVisibilityController.goBack
      masterController.api.uiEvents.postEvent("VisibilityChanged")
      update_table_data
    end
    view.addSubview(backButton)
    self.view.on_swipe(:right) do
      slide_out
    end
    view.rowHeight = 48
    "UIDeviceOrientationDidChangeNotification".add_observer(self, :resizeIt)
  end

  def resizeIt(*note)
    @orientation = device_landscape?(note.object.orientation) ? :landscape : :portrait
   #puts "RoutesView: resizeIt Device #{device_orientation_names[note.object.orientation]} view.frame #{view.frame.inspect} view.bounds #{view.bounds.inspect}}"
   #puts "RoutesView: resizeIt Interface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.superview.frame.inspect} superview.bounds #{view.superview.bounds.inspect}"
   #puts "RoutesView: resizeIt Screen applicationFrame #{UIScreen.mainScreen.applicationFrame.inspect} bounds #{UIScreen.mainScreen.bounds.inspect}"
    resizeAll
  end

  def resizeAll
   #puts "RoutesView: resizeAll view.frame #{view.frame.inspect}"
   #puts "RoutesView: resizeAll view.bounds #{view.bounds.inspect}"
   #puts "RoutesView: resizeAll orientation #{@orientation}"
   #puts "RoutesView: resizeAll super_frames #{@super_frames.inspect}"
    bounds = @super_frames[@orientation]
    bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height)
   #puts "RoutesView: resizeALL  frame #{bounds.inspect}"
    nav_bar_end =  @orientation == :landscape ? 40 : 70
    bounds.size.height = bounds.size.height/4.0
    bounds.size.width = [(w = bounds.size.width)*0.8, 250].min
    bounds.origin.x = (x = bounds.origin.x) + w - bounds.size.width
    bounds.origin.y = bounds.origin.y + nav_bar_end
   #puts "RoutesView: resizeALL  final frame #{bounds.inspect}"
    view.frame = bounds
    view.rowHeight = 28
    view.shadow(opacity: 0.5, offset: [5,5], color: :black, radius: 1)
    f = backButton.frame
    f = CGRectMake(f.origin.x, f.origin.y, f.size.width, f.size.height)
    # This frame is in the coorindate system of the RoutesView
    f.origin.x = bounds.size.width - f.size.width
    f.origin.y = 0
    backButton.frame = f

    tabButton.origin = [x + w - tabButton.size.width, bounds.origin.y]
    tabButton.slide_out
    @view_is_out = false
    @view_origin = view.origin
  end

  def tableView(table_view, cellForRowAtIndexPath:index_path)
    table_view_cell(index_path: index_path).tap do |cell|
      cell.will_display
    end
  end

  def tableView(table_view, heightForRowAtIndexPath:index_path)
    puts "HeightForRowAtIndexPath #{index_path}"
    37
  end

  def will_appear
   #puts "RoutesView will appear #{view.superview}"
   #puts "RoutesView will bounds #{view.superview.bounds.inspect}"
   #puts "RoutesView will frame #{view.superview.frame.inspect}"
    @super_frames ||= {}
    if @original_device_orientation.nil?
      @original_device_orientation = UIDevice.currentDevice.orientation
      origin = view.superview.frame.origin
      size = view.superview.frame.size
      if device_landscape?(@original_device_orientation)
        @orientation = :landscape
        @super_frames[:landscape] = CGRectMake(origin.x, origin.y, size.width, size.height)
        @super_frames[:portrait] = CGRectMake(origin.y, origin.x, size.height, size.width)
      else
        @orientation = :portrait
        @super_frames[:portrait] = CGRectMake(origin.x, origin.y, size.width, size.height)
        @super_frames[:landscape] = CGRectMake(origin.y, origin.x, size.height, size.width)
      end
    end
    view.rowHeight = 48.0
    tabButton.setup
    resizeAll
  end

  def on_init
   #puts "RoutesView on_init"
  end

  def after_init
    masterController.api.uiEvents.registerForEvent("VisibilityChanged", self)
    masterController.api.uiEvents.registerForEvent("JourneyAdded", self)
    masterController.api.uiEvents.registerForEvent("JourneyRemoved", self)
  end

  def journeyVisibilityController
    masterController.journeyVisibilityController
  end

  def onBuspassEvent(event)
    case event.eventName
      when "JourneyAdded", "JourneyRemoved", "VisibilityChanged"
        update_table_data
    end
  end

  def set_attribute(element, k, v)
   #puts "#{element} set_attribute #{k} = #{v}"
    super
  end

  def table_data
    journeyDisplays = masterController.journeyVisibilityController.getSortedJourneyDisplays
    jds = journeyDisplays.select do |x|
      x.isNameVisible?
    end
   #puts "RoutesView: update_table_data: #{journeyDisplays.count} displays #{jds.count} visible"
    data = []
    jds.each do |jd|
        data << {
            #:title => jd.route.name,
            :action => :hit,
            :long_press_action => :longhit,
            :arguments => jd,
            :cell_class => RouteCell,
            :cell_style => UITableViewCellStyleSubtitle,
            :style => {
              :journeyDisplay => jd,
              :time_format => masterController.master.time_format
            }
        }
    end
    [{
        #:title => "Routes",
        :cells => data
    }]
  end

  def centerMap(journeyDisplay)
    loc = journeyDisplay.route.lastKnownLocation
    if loc
      masterMapScreen.center = {latitude: loc.latitude, longitude: loc.longitude, animated: true}
    end
  end

  def highlight(jd)
    masterController.journeyVisibilityController.highlight(jd)
    masterController.api.uiEvents.postEvent("VisibilityChanged")
    update_table_data
    5.seconds.later do
      masterController.journeyVisibilityController.unhighlightAll
      update_table_data
      masterController.api.uiEvents.postEvent("VisibilityChanged")
    end
  end

  def longhit(jd)
   #puts "RoutesView: Hit  #{jd.route.name}"
    vstate = journeyVisibilityController.getCurrentState
    case vstate.state
      when Platform::VisualState::S_ALL
        highlight(jd)
      when Platform::VisualState::S_ROUTE
        highlight(jd)
        if jd.route.isJourney?
          centerMap(jd)
        end
      when Platform::VisualState::S_VEHICLE
        if jd.route.isRouteDefinition?
        else
          centerMap(jd)
        end
      else
       #puts "Bad VisualState #{vstate.state}"
    end
  end

  def hit(jd)
   #puts "RoutesView: Hit  #{jd.route.name}"
    vstate = journeyVisibilityController.getCurrentState
    case vstate.state
      when Platform::VisualState::S_ALL
        if jd.route.isRouteDefinition? # should be the case regardless
          journeyVisibilityController.onRouteSelected(jd)
          masterController.api.uiEvents.postEvent("VisibilityChanged")
        end
      when Platform::VisualState::S_ROUTE
        if jd.route.isJourney?
          journeyVisibilityController.onVehicleSelected(jd)
          masterController.api.uiEvents.postEvent("VisibilityChanged")
        end
      when Platform::VisualState::S_VEHICLE
        if jd.route.isRouteDefinition?
          journeyVisibilityController.goBack
          masterController.api.uiEvents.postEvent("VisibilityChanged")
        else
          centerMap(jd)
        end
      else
       #puts "Bad VisualState #{vstate.state}"
    end
    update_table_data
  end
  # iOS 8
  def viewWillTransitionToSize(size, withTransitionCoordinator:coordinator)
    super
   #puts "RoutesView: viewWillTransitionToSize(#{size.inspect}"
   #puts "RoutesView: screen #{UIScreen.mainScreen.bounds.inspect}"
   #puts "RoutesView: UserInterface #{interface_orientation_names[UIApplication.sharedApplication.statusBarOrientation]} superview.frame #{view.frame.inspect} bounds #{view.bounds.inspect}"
  end

  # iOS 8
  def traitCollectionDidChange(previousTraitCollection)
    super
   #puts "RoutesView: traitCollectionDidChange previous #{previousTraitCollection.inspect}"
   #puts "RoutesView: traitCollectionDidChange previous vertical #{previousTraitCollection.verticalSizeClass}" if previousTraitCollection
   #puts "RoutesView: traitCollectionDidChange previous horizontal #{previousTraitCollection.horizontalSizeClass}" if previousTraitCollection
   #puts "RoutesView: traitCollectionDidChange current #{traitCollection.inspect}"
   #puts "RoutesView: traitCollectionDidChange current vertical #{traitCollection.verticalSizeClass.inspect}"
   #puts "RoutesView: traitCollectionDidChange current horizontal #{traitCollection.horizontalSizeClass.inspect}"
  end
end