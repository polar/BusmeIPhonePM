class RoutesView < PM::TableScreen

  attr_accessor :masterController

  def self.newView(args)
    masterController = args.delete :masterController
    m = self.new(args)
    m.masterController = masterController
    m.after_init
    m
  end

  def on_load
    puts "RoutesView on_load #{view.superview}"
  end

  def will_appear
    puts "RoutesView will appear #{view.superview}"
    bounds = view.superview.frame
    bounds.size.height = bounds.size.height/4.0
    bounds.size.width = bounds.size.width/2.0
    bounds.origin.x = bounds.origin.x + bounds.size.width
    bounds.origin.y = bounds.origin.y + 60
    view.frame = bounds
  end

  def on_init
    puts "RoutesView on_init"
  end

  def after_init
    masterController.api.uiEvents.registerForEvent("JourneyAdded", self)
    masterController.api.uiEvents.registerForEvent("JourneyRemoved", self)
  end

  def onBuspassEvent(event)
    case event.eventName
      when "JourneyAdded", "JourneyRemoved"
        update_table_data
    end
  end

  def set_attribute(element, k, v)
    puts "#{element} set_attribute #{k} = #{v}"
    super
  end

  def table_data
    journeyDisplays = masterController.journeyDisplayController.journeyDisplays
    jds = journeyDisplays.select do |x|
      x.isNameVisible?
    end
    jds = jds.sort do |m,n|
        m.route.sort <=> n.route.sort
    end
    data = []
    jds.each do |jd|
        data << {
            :title => jd.route.name,
            :action => :eatme,
            :arguments => jd,
            :cell_class => RouteCell,
            :cell_style => UITableViewCellStyleSubtitle,
            :style => {
              :journeyDisplay => jd
            }
        }
    end
    [{
        #:title => "Routes",
        :cells => data
    }]
  end

  def eatme(jd)
    puts "eatme! #{jd}"
  end
end