class BannerTimer
  attr_accessor :masterController
  attr_accessor :pleaseStop

  def initialize(args)
    self.masterController = args[:masterController]
    self.pleaseStop = true
  end

  def start
    self.pleaseStop = false
    doBannerUpdate(true)
  end

  def stop
    self.pleaseStop = true
  end

  def restart
    self.pleaseStop = false
    doBannerUpdate(true)
  end

  def doBannerUpdate(forced)
    PM.logger.warn "BannerTimer:  Banner Update!!"
    masterController.bannerPresentationController.roll(forced)
    5.seconds.later do
      if ! pleaseStop
        doBannerUpdate(false)
      end
    end
  end
end