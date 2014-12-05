
Platform::XMLExternalStorageController.class_eval do
  def masterController=(mc)
    @masterController = WeakRef.new(mc)
  end
end