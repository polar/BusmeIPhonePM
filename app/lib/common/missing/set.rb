class Set
  attr_accessor :nsset

  def initialize(a = [])
    if a.is_a?(Array)
      self.nsset = NSMutableSet.alloc.initWithArray(a)
    # elsif a.is_a?(NSSet)
    #   self.nsset = NSMutableSet.alloc.initWithInitialCapacity(a.count)
    #   self.nsset.setSet(a)
      PM.logger.error "creating #{self.inspect} #{self.nsset}"
      PM.logger.error "creating #{self.inspect} #{self.nsset.count}"
    elsif a.is_a?(Set)
      PM.logger.error "#{a.inspect} #{a.nsset}"
      # TODO: FIx this iOS bug?
      # Horrible workaround
      # It seems that sometimes the count attribute disappears from a
      # nsset, maybe because it's empty? So, if we get that error, we
      # just assume.

      begin
        size = a.nsset.count
        self.nsset = NSMutableSet.alloc.initWithInitialCapacity(size)
        self.nsset.setSet(a.nsset)
      rescue Exception => boom
        begin
          PM.logger.error "Set.new #{boom} trying array"
          objects = a.nsset.allObjects
          self.nsset = NSMutableSet.alloc.initWithArray(objects)
        rescue Exception => boom
          PM.logger.error "Set.new #{boom} creating empty set"
          size = 0
          self.nsset = NSMutableSet.alloc.initWithArray([])
        end
      end
    end
    self
  end

  def delete(a)
    self.nsset.removeObject(a)
  end

  def add(a)
    self.nsset.addObject(a)
  end

  alias_method :<<, :add

  def add?(a)
    if self.nsset.member(a)
      return nil
    else
      self.nsset.addObject(a)
      self
    end
  end

  def subset?(a)
    self.nsset.isSubsetOfSet(a.nsset)
  end

  def include?(a)
    !! self.nsset.member(a)
  end

  alias_method :member?, :include?

  def intersect?(a)
    self.nsset.intersectsSet(a.nsset)
  end

  def empty?
    self.nsset.count == 0
  end

  def merge(set)
    set = NSSet.alloc.initWithArray(set) if set.is_a?(Array)
    set = set.nsset if set.is_a?(Set)
    self.nsset.unionSet(set)
    self
  end

  def subtract(set)
    set = NSSet.alloc.initWithArray(set) if set.is_a?(Array)
    set = set.nsset if set.is_a?(Set)
    self.nsset.minusSet(set)
    self
  end

  def dup
    PM.logger.error "#{self.class.name}:#{__method__} #{self.inspect} making new set"
    Set.new(self)
  end

  def map(&block)
    self.nsset.allObjects.map &block
  end

end