
Platform::XMLExternalStorageController.class_eval do
  def masterController=(mc)
    @masterController = WeakRef.new(mc)
  end

  alias_method :superDeserializeObjectFromFile, :deserializeObjectFromFile

  def deserializeObjectFromFile(filename)
      superDeserializeObject(filename)
  end
end