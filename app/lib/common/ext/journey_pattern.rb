class Bogus

  def isReady()
    @path || @projectedPath
  end

  def isReady?
    isReady()
  end

  # An attempt to reduce memory usage on the stupid iPhone
  # If we have the projectedPath, we really no longer need the
  # the full path. So,
  def projectedPath
    if @projectedPath.nil? && @path
      @projectedPath = Utils::ScreenPathUtils.toProjectedPath(@path)
      @rect ||= Platform::GeoPathUtils.rectForPath(@path)
      @endPoint || @path.last
      @path = nil
    end
    @projectedPath
  end
end