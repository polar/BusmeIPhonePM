class FGBannerPresentationEventController < Platform::FG_BannerPresentationEventController

  attr_accessor :masterMapScreen
  attr_accessor :currentUIBanner

  def initialize(api, masterMapScreen)
    super(api)
    self.masterMapScreen = masterMapScreen
  end

  def displayBanner(bannerInfo)
    PM.logger.info "Adding #{bannerInfo.title} to MapSubview"
    mapViewBounds = masterMapScreen.view.bounds
    if currentUIBanner
      dismissBanner(currentUIBanner.bannerInfo)
    end
    self.currentUIBanner = UIBanner.alloc.initWith(bannerInfo)
    currentUIBanner.origin = [0, mapViewBounds.size.height - currentUIBanner.bounds.size.height]
    PM.logger.info "Adding banner #{currentUIBanner}"
    masterMapScreen.view.addSubview(currentUIBanner)
    currentUIBanner.alpha = 0
    PM.logger.info "Added banner #{currentUIBanner}"
    currentUIBanner.slide_in
  end

  def dismissBanner(bannerInfo)
    PM.logger.info "Should be removing #{bannerInfo.title} from MapView"
    if currentUIBanner
      @removeView = currentUIBanner
      UIView.animation_chain do
        @removeView.slide_out
      end.and_then do
        @removeView.removeFromSuperview
      end.start
      self.currentUIBanner = nil
    end
  end
end