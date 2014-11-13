describe "Location Updating" do

  def location_manager
    BW::Location.instance_variable_get("@location_manager")
  end

  before do
    @points = [
        {location:{latitude:40.828300000,longitude:-96.69941700}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.830158000,longitude:-96.700531000}, options:{speed:11, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.83086000,longitude:-96.700829000}, options:{speed:12, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.830860000,longitude:-96.700829000}, options:{speed:13, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.830551000,longitude:-96.70187400}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.8304710004,longitude:-96.70233900}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.830471000,longitude:-96.702339000}, options:{speed:9, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.830349000,longitude:-96.702332000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.830471000,longitude:-96.701782000}, options:{speed:3, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.830719000,longitude:-96.700958000}, options:{speed:6, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.8307190001,longitude:-96.700958000}, options:{speed:10, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.83005900,longitude:-96.700661000}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.827221000,longitude:-96.699043000}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.825829000,longitude:-96.698181000}, options:{speed:12, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.82502000,longitude:-96.697578000}, options:{speed:10, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.822899000,longitude:-96.695374000}, options:{speed:5, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.821571000,longitude:-96.693329000}, options:{speed:5, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.821331000,longitude:-96.693047000}, options:{speed:6, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.820938000,longitude:-96.692703000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.820351000,longitude:-96.692413000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.819988000,longitude:-96.692307000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.819489000,longitude:-96.69229900}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.818859000,longitude:-96.692322000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.818501000,longitude:-96.692421000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.818008000,longitude:-96.692741000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.817131000,longitude:-96.693703000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.816898000,longitude:-96.693871000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.816490000,longitude:-96.694054000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.815819000,longitude:-96.694099000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.813580000,longitude:-96.694092000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.813580000,longitude:-96.694092000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.813560000,longitude:-96.685478000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.813499000,longitude:-96.685188000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.813450000,longitude:-96.682411000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.813450000,longitude:-96.682411000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.804840000,longitude:-96.682419000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.799541000,longitude:-96.682487000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.797611000,longitude:-96.682487000}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.797508000,longitude:-96.682426000}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.793510000,longitude:-96.682449000}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.793190000,longitude:-96.682457000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.793121000,longitude:-96.682518000}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude: 40.791660000,longitude:-96.682518000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude: 40.791580000,longitude:-96.682472000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude: 40.790779000,longitude:-96.682457000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.784431000,longitude:-96.682510000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.784431000,longitude:-96.682510000}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.784451000,longitude:-96.687378000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.784451000,longitude:-96.687378000}, options:{speed:15, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.780891000,longitude:-96.687401000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.780891000,longitude:-96.687401000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}},
        {location:{latitude:40.780880000,longitude:-96.687210000}, options:{speed:8, altitude:200, horizontalAccuracy:10, verticalAccuracy:15}}
    ]

    @app_delegate = UIApplication.sharedApplication.delegate
  end

  it "should get location updates" do
    last = nil
    puts "#{@points.inspect}"
    puts "STARTING ON #{Dispatch::Queue.current}"
    for p in @points do
      to = CLLocation.alloc.initWithLatitude(p[:location][:latitude], longitude: p[:location][:longitude])
      last ||= to
      puts "To: #{to.inspect}"
      Dispatch::Queue.main.async do
        puts "Submitting on #{Dispatch::Queue.current}"
       BubbleWrap::Location.locationManager(location_manager, didUpdateToLocation: to, fromLocation: last)
      end
      last = to
      puts "SLEEPING ON #{Dispatch::Queue.current}"
      sleep 1
    end
  end
end