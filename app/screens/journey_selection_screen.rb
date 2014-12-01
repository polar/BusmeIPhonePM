class JourneySelectionScreen < PM::TableScreen
  attr_reader :journeys
  attr_accessor :masterController
  attr_accessor :parent

  title "Reporting"

  def location=(loc)
    @location = loc
    if masterController
      self.journeys = masterController.journeySelectionPostingController.selectJourneys(loc)
    end
  end

  def journeys=(jds)
    @journeys = jds
    update_table_data
  end

  def table_data
      # This method gets called on_load before we are setup.
      if masterController && journeys
        data = []
        journeys.each do |jd|
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
      else
        data = []
      end

      [{
           :title => "Select the vehicle you are on",
           :cells => data
       }]
  end

  def close_up
    PM.logger.warn "#{self.class.name}:#{__method__} : #{parent.inspect}"
    if parent.is_a?(MenuScreen)
      parent.close_up
    end
  end

  def hit(jd)
    PM.logger.warn "#{self.class.name}:#{__method__} : #{jd.route.name}"
    close_up
  end

  def longHit(jd)
    PM.logger.warn "#{self.class.name}:#{__method__} : #{jd.route.name}"
  end
end