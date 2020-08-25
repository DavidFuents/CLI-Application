require "./lib/concerns/authorize"
# In order to use the Spotify API you will need a developer account @ https://developer.spotify.com/documentation/web-api/

 class API 
    include Authorize

    attr_accessor :access_token

    def self.token(token)
        @access_token = token
    end

    def self.get_response(name, type)
        search = HTTParty.get("https://api.spotify.com/v1/search?q=#{name}&type=#{type}&offset=0&limit=1", {
            headers: {            
              "Authorization" => "Bearer #{@access_token}"                
            }}) #Only looks for the top result(most related)
        search       
    end

    def self.get_response_from_link(href)
        search = HTTParty.get("#{href}", {
            headers: {            
              "Authorization" => "Bearer #{@access_token}"                
            }}) #Only looks for the top result(most related)
        search       
    end

    def expired_token
        puts "\nSorry access token has expired. Refresh token...".colorize(:yellow)
        self.refresh_token
        puts "Please try again."
        CLI.menu
    end
end


  