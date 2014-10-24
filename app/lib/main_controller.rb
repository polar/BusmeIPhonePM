class MasterController < Platform::MasterController
  def assignStorageSerializerControllers
    puts " Master Controller using XML Storage Controller"
    self.externalStorageController = Platform::XMLExternalStorageController.new(masterController: self, api: api)
    self.storageSerializerController = Platform::StorageSerializerController.new(api, externalStorageController)
  end
end


class MainController < Platform::MainController
  def instantiateMasterController(args)
    puts "Creating new Master Controller"
    MasterController.new(args)
  end
end