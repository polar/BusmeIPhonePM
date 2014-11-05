class Configurator < Platform::BusmeConfigurator
  # NSUserDefaults doesn't like nil

  def saveAsDefaultMaster(master)
    str = NSUserDefaults[:defaultMaster]
    if str && !str.empty?
      master = Archiver.decode(str)
    end
  end

  def removeDefaultMaster
    NSUserDefaults[:defaultMaster] = ""
  end

  def setLastLocation(loc)
    NSUserDefaults[:lastLocation] = Archiver.encode(loc)
  end

  def getLastLocation
    str = NSUserDefaults[:lastLocation]
    if str && !str.empty
      loc = Archiver.decode(str)
    end
  end

  def retrieveStoredAuthTokenForMaster(name)
    str = NSUserDefaults["login_#{name}"]
    if str && !str.empty?
      login = Archiver.decode(str)
    end
  end

  def forgetUserForMaster(masterName)
    NSUserDefaults["login_#{nasterName}"] = ""
  end

  def storeCredentialsForMaster(master, login)
    NSUserDefaults["login_#{master}"] = Archiver.encode(login)
  end

  def removeCredentialsAuthTokenForMaster(master, login)
  end
end