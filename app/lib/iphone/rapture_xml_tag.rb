class RaptureXMLTag < Api::Tag
  attr_accessor :name
  attr_accessor :attributes
  attr_accessor :childNodes
  attr_accessor :text

  def initialize(rxml)
    self.name = rxml.tag
    self.attributes = {}
    rxml.attributeNames.each do |n|
      attributes[n] = rxml.attribute(n)
    end
    kids = rxml.allChildren
    self.childNodes =kids.map do |x|
      RaptureXMLTag.new(x)
    end
    #
    self.text = rxml.text
  end

  def to_s
    "<#{name} #{attributes.inspect}>#{childNodes.map {|x| x.to_s}.join(",\n")}#{text}</#{name}>"
  end
end