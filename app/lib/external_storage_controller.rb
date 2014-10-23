module Platform
  ExternalStorageController.class_eval do
    def serializeObjectToFile(store, filename)
      if isAvailable?
        if isWriteable?
          FileUtils.mkdir_p(directory)
          fn = File.join(directory, legalize(filename))
          Extern.cache(store, fn)
          true
        end
      end
    end

    def deserializeObjectFromFile(filename)
      if isAvailable?
        fn = File.join(directory, legalize(filename))
        store = Extern.retrieve(fn)
        return store
      end
    end
  end
end