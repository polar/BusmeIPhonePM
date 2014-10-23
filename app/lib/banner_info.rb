
module Api
  [JourneyStore, JourneyPattern, JourneyLocation, BannerInfo, MarkerInfo, MasterMessage, NameId, Route].each do |klass|
    klass.class_eval do
     include Extern::NSCoder
    end
  end
end

module Integration
  [GeoPoint, Point, BoundingBoxE6].each do |klass|
    klass.class_eval do
      include Extern::NSCoder
    end
  end
end

module Platform
  [JourneyStore, MarkerStore, MasterMessageStore].each do |klass|
    klass.class_eval do
      include Extern::NSCoder
    end
  end
end