class APITag < Api::Tag
  attr_accessor :name
  attr_accessor :attributes
  attr_accessor :childNodes
  attr_accessor :text

  def initialize(args)
    self.childNodes = []
    args.each do |n, v|
     #puts "#{n}= #{v}"
      self.send("#{n}=", v)
    end
#    puts "Initialized #{self.to_s}"
  end

  def to_s
    puts "<#{name} #{attributes.inspect}>#{childNodes.map {|x| x.to_s}.join(",\n")}#{text}</#{name}>"
  end
end
APITAG_DISCOVER = APITag.new(name: 'API', attributes: {
    "version"  => 'd1',
    "discover" => 'http://busme-apis.herokuapp.com/apis/d1/discover',
    "master"   => 'http://busme-apis.herokuapp.com/apis/d1/master'
})
APITAG_MASTERS =
    APITag.new(name: "masters", childNodes: [
        APITag.new(name: "master", attributes: {
            "name"=> 'Onondaga-CC', "slug"=> 'onondaga-cc', "mode"=> 'active', "deployment_slug"=> 'spring-and-fall-semester',
            "lon"=> '-76.196280', "lat"=> '43.004624', "bounds"=> '-76.202108,43.011596,-76.186425,43.001862',
            "api"=> 'http://busme-apis.herokuapp.com/masters/521679a96eec8b000800710b/apis/1/get',
            childNodes: [
                APITag.new(name: "title", text: 'Eatmte'),
                APITag.new(name: "description", text: "sdlkfjlskdfa")]
        })])

#puts APITAG_DISCOVER
#puts APITAG_MASTERS