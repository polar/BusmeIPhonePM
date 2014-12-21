class Configurator < Platform::BusmeConfigurator
  # NSUserDefaults doesn't like nil

  def saveAsDefaultMaster(master)
    if master
      PM.logger.info "Configurator.saveAsDefaultMaster #{master.to_s}"
      str = Api::Archiver.encode(master)
      PM.logger.warn "Configurator. #{str}"
      if str
        NSUserDefaults[:defaultMaster] = str
        str
      end
    end
  end

  def getDefaultMaster
    str = NSUserDefaults[:defaultMaster]
    if str && !str.empty?
      master = Api::Archiver.decode(str)
    end
  end

  def removeDefaultMaster
    NSUserDefaults[:defaultMaster] = ""
  end

  def setLastLocation(loc)
    if !loc.is_a?(Integration::GeoPoint)
      loc = Integration::GeoPoint.new(loc.latitude * 1E6, loc.longitude * 1E6)
    end
    NSUserDefaults[:lastLocation] = Api::Archiver.encode(loc)
  end

  def getLastLocation
    PM.logger.info "#{self.class.name}:#{__method__}"
    str = NSUserDefaults[:lastLocation]
    if str && !str.empty?
      loc = Api::Archiver.decode(str)
    end
  end

  def retrieveStoredAuthTokenForMaster(name)
    str = NSUserDefaults["login_#{name}"]
    if str && !str.empty?
      login = Api::Archiver.decode(str)
    end
  end

  def forgetUserForMaster(masterName)
    NSUserDefaults["login_#{nasterName}"] = ""
  end

  def storeCredentialsForMaster(master, login)
    NSUserDefaults["login_#{master}"] = Api::Archiver.encode(login)
  end

  def removeCredentialsAuthTokenForMaster(master, login)
  end
end