require 'webrick'

class Stasis
  class Webrick
	# See: https://gist.github.com/806189
	class NonCachingFileHandler < WEBrick::HTTPServlet::FileHandler
	  def prevent_caching(res)
		res['ETag']          = nil
		res['Last-Modified'] = Time.now + 100**4
		res['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
		res['Pragma']        = 'no-cache'
		res['Expires']       = Time.now - 100**4
	  end

	  def do_GET(req, res)
		super
		prevent_caching(res)
	  end
	end

    def initialize(dir, options={})
      @dir = dir
      @options = options
	  @port = (!options[:webrick].nil? && !options[:webrick].empty?) ? options[:webrick].to_i : 4567
	  @public = @options[:public] || File.join(@dir,"public")
	  puts "Starting WEBrick...\n\n"
	  puts "http://localhost:#{@port} -> #{@public}\n\n"
	  puts 'Press ctrl-c to shutdown WEBrick.'
	  server = WEBrick::HTTPServer.new :Port => @port
	  server.mount "/", NonCachingFileHandler , @public
	  trap('INT') do 
		print "\e[0m\r\e[0K"
		$stdout.flush
		server.stop 
	  end
	  server.start
	end
  end
end
