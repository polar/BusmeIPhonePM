class Extern

  def self.cache(x, filename)
    IdentityMap.clear
    NSKeyedArchiver.archiveRootObject(x, toFile: filename)
  rescue Exception => boom
    puts "Cache #{boom}"
  end

  def self.retrieve(filename)
    IdentityMap.clear
    obs = NSKeyedUnarchiver.unarchiveObjectWithFile(filename)
    obs
  rescue Exception => boom
    puts "Cache #{boom}"
    nil
  end
  
  class IdentityMap
    @@classmap = {}
    def self.clear
      @@classmap = {}
    end
    def self.store(x, id)
      @@classmap[id] = x
    end

    def self.retrieve(id)
      @@classmap[id]
    end
    def self.keys
      @@classmap.keys
    end
  end

  module NSCoder1

  end
  module NSCoder
    def initWithCoder(decoder)
      puts "Retrieving #{self.class}:#{__id__} #{self.propList}"
      self.propList.each do |name|
        begin
          val = decoder[name]
          #puts "   #{name} = #{val.inspect}"
          self.instance_variable_set(name, val)
        rescue Exception => boom
          puts "On #{name} : #{boom}"
        end
      end
    end

    def encodeWithCoder(encoder)
      puts "Storing #{self.class.name}:#{self.__id__} ==> #{self.propList}"
      self.propList.each do |x|
        begin
        val =  self.instance_variable_get(x)
        if val.is_a? WeakRef
          puts "We are storing a WeakRef"
          val = val.object
        end
        #puts " ==>  #{x} = #{val.inspect}"
        encoder[x] = val
        rescue Exception => boom
          puts "On #{name} : #{boom}"
        end
      end
    end
  end

  module NSCoder1
    def initWithCoder(decoder)
      id = decoder["_imid_"]
      self.init
      puts "Retrieving #{id} #{self.class} #{self.instance_variables}"
      x = IdentityMap.retrieve(id)
      if x.nil?
        x = self
        IdentityMap.store(x, id)
      end
      if decoder.bool("__imr__")
        x.instance_variables.each do |name|
          begin
          val = decoder[name]
          #puts "   #{name} = #{val.inspect}"
          x.instance_variable_set(name, val)
          rescue Exception => boom
            puts "On #{name} : #{boom}"
          end
        end
      end
      x
    end

    def encodeWithCoder(encoder)
      id = "#{self.class.name}:#{self.__id__}"
      if IdentityMap.retrieve(id)
        encoder["_imid_"] = id
        encoder.set("__imr__", toBool: false)
        puts "Storing #{id} for retrieval"
      else
        IdentityMap.store(self, id)
        encoder["_imid_"] = id
        encoder.set("__imr__", toBool: true)
        puts "Storing #{id} ==> #{self.instance_variables}"
        self.instance_variables.each do |x|
          val =  self.instance_variable_get(x)
          #puts " ==>  #{x} = #{val.inspect}"
          encoder[x] = val
        end
      end
    end
  end
end
