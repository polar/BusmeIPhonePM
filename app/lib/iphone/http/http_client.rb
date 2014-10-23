puts "loading IPhone::Http:HttpClient"

# This is not thread safe.

module IPhone
  module Http
    class BWrap
      def initialize(body)
        @body = body
      end
      def length
        @body.length
      end
      def content
        @s = @body.to_s
      end
    end
    class RWrap
      def initialize(response)
        @resp = response
      end
      def body
        BWrap.new @resp.body
      end
      def headers
        @resp.headers
      end
    end
    class MockWrap
      def initialize(str)
        @str = str
      end
      def body
        BWrap.new @str
      end
      def headers
        []
      end
    end
    puts "past IPHone::Http"
    class HttpClient < Integration::Http::HttpClient
      def initialize
        super
        @queue = Dispatch::Queue.new("http")
        @sem = Dispatch::Semaphore.new(0)
        @entry = Dispatch::Semaphore.new(1)
        @result = nil
      end

      def getURLResponse(url)
        resp = nil
        AFMotion::HTTP.get(url) do |response|
          message = response.body.to_s
          resp = Integration::Http::HttpResponse.new(message)
          block.call(resp) if block_given?
        end
        resp
      end

      def mock
        "<masters>\n<master name='Onondaga-CC' slug='onondaga-cc' mode='active' deployment_slug='spring-and-fall-semester' lon='-76.196280' lat='43.004624' bounds='-76.202108,43.011596,-76.186425,43.001862' api='http://busme-apis.herokuapp.com/masters/521679a96eec8b000800710b/apis/1/get' >\n<title>Onondaga-CC</title>\n<description>Onondaga Community College Shuttle Routes</description>\n</master>\n<master name='Lake Shore Limited Amtrak' slug='lake-shore-limited-amtrak' mode='active' deployment_slug='deployment-1' lon='-77.317205' lat='41.612683' bounds='-87.639359,43.20031,-73.738298,40.75041' api='http://busme-apis.herokuapp.com/masters/512e7ea39f9501000e0000d0/apis/1/get' >\n<title>Lake Shore Limited Amtrak</title>\n<description>The Amtrak Train between New York and Chicago</description>\n</master>\n<master name='Columbus' slug='columbus-in' mode='active' deployment_slug='main2014' lon='-85.920893' lat='39.197660' bounds='-85.925829,39.253869,-85.864988,39.188258' api='http://busme-apis.herokuapp.com/masters/51a56d848b56eb001e0001c3/apis/1/get' >\n<title>Columbus</title>\n<description></description>\n</master>\n<master name='Laurel, MD' slug='laurel-md' mode='active' deployment_slug='deployment-1' lon='-76.848372' lat='39.098387' bounds='-76.9279,39.29074,-76.57181,38.97203' api='http://busme-apis.herokuapp.com/masters/52f43b0a421aa91978036f69/apis/1/get' >\n<title>Laurel, MD</title>\n<description></description>\n</master>\n<master name='Appalcart, Boone, NC' slug='appalcart-boone-nc' mode='active' deployment_slug='deployment-1' lon='-81.674779' lat='36.216771' bounds='-81.679666,36.224729,-81.640378,36.205616' api='http://busme-apis.herokuapp.com/masters/52f92735421aa9197807a3a5/apis/1/get' >\n<title>Appalcart, Boone, NC</title>\n<description></description>\n</master>\n<master name='Marthas Vineyard, MA' slug='marthas-vineyard-ma' mode='active' deployment_slug='deployment-1' lon='-70.513853' lat='41.389135' bounds='-70.836464,41.481884,-70.51055354839067,41.322508' api='http://busme-apis.herokuapp.com/masters/52f440ff421aa9419f012d3a/apis/1/get' >\n<title>Marthas Vineyard, MA</title>\n<description></description>\n</master>\n<master name='GET Bakersfield, CA' slug='get-bakersfield-ca' mode='active' deployment_slug='deployment-1' lon='-119.008155' lat='35.377154' bounds='-119.100891,35.41282,-118.967421,35.350347' api='http://busme-apis.herokuapp.com/masters/536d097422f3243843000455/apis/1/get' >\n<title>GET Bakersfield, CA</title>\n<description>Golden Empire Transit</description>\n</master>\n<master name='Jackson WY' slug='jackson-wy' mode='active' deployment_slug='summer-2014' lon='-110.762594' lat='43.480313' bounds='-110.813467,43.483445,-110.744627,43.458186' api='http://busme-apis.herokuapp.com/masters/51c32492a46acf001e001a7e/apis/1/get' >\n<title>Jackson WY</title>\n<description></description>\n</master>\n<master name='New Paltz, NY' slug='nploop-new-paltz-ny' mode='active' deployment_slug='normal-ops-2012' lon='-74.082661' lat='41.747601' bounds='-74.09084,41.761532,-74.06462,41.737023' api='http://busme-apis.herokuapp.com/masters/50e645493a73c50002001bb1/apis/1/get' >\n<title>New Paltz, NY</title>\n<description></description>\n</master>\n<master name='Syracuse-University' slug='syracuse-university' mode='active' deployment_slug='year2014-2015' lon='-76.131539' lat='43.037268' bounds='-76.176869,43.076736,-76.052041,42.995355' api='http://busme-apis.herokuapp.com/masters/50fcc339223520000c000088/apis/1/get' >\n<title>Syracuse-University</title>\n<description></description>\n</master>\n</masters>"
      end
      def mock1
        "<API version='d1' discover='http://busme-apis.herokuapp.com/apis/d1/discover' master='http://busme-apis.herokuapp.com/apis/d1/master'/>"
      end

      def openURL(url)
        #return Integration::Http::HttpEntity.new(MockWrap.new(mock1)) if /d1\/get/ =~ url
        #return Integration::Http::HttpEntity.new(MockWrap.new(mock)) if /discover\?lon/ =~ url
        res = nil
        puts "HTTP Get #{url} on #{Dispatch::Queue.current}"
        resp = AFMotion::XML.get(url) do |result, a, b|
          # This thread always seems to be the apple-main-thread!
          # So we need to post back to the background immediately
          @queue.async do
            @entry.wait
            if result.failure?
            else
              message = result.body.to_s
              @result = Integration::Http::HttpEntity.new(RWrap.new(result))
            end
            @sem.signal
          end
        end
        @sem.wait
        result = @result
        @entry.signal
        puts "Got #{@result ? @result.body : "-failure-"} on #{Dispatch::Queue.current}"
        result
      end

      def postURLResponse(url, params, &block)
        res = nil
        AFMotion::HTTP.post(url, params) do |response|
          message = response.body.to_s
          res = Integration::Http::HttpResponse.new(message)
          block.call(res) if block_given?
        end
        res
      end

      def postURL(url, params, &block)
        res = nil
        AFMotion::HTTP.post(url, params) do |response|
          message = response.body.to_s
          res = Integration::Http::HttpEntity.new(response)
          block.call(res) if block_given?
        end
        res
      end

      def postDeleteURL(url, &block)
        res = nil
        AFMotion::HTTP.delete(url, params) do |response|
          message = response.body.to_s
          res = Integration::Http::HttpEntity.new(message)
          block.call(res) if block_given?
        end
        res
      end
    end
  end
end
