class Set
  attr_accessor :nsset

  def initialize(a = [])
    self.nsset = NSMutableSet.alloc.initWithArray(a)
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

end