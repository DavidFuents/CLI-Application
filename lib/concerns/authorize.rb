require "base64" #This is built into ruby 

module Authorize
    attr_accessor :username, :password, :code, :access_token, :refresh_tkn, :client_id, :client_secret

    def initialize
        # Both of these keys(client_id & client_secret) are neccessary to get a user authorize and get an access token
        # There are multiple ways to get a user authorized and get an access token but I went with the Authorization Code 
        # You can find the other methods @ https://developer.spotify.com/documentation/general/guides/authorization-guide
    
        @client_id = '' #Put your application's client id here 
        @client_secret = '' #Put client secret here
    end
    
    def sign_in(client_id)
        puts "Please sign into Spotify:\n".colorize(:yellow)
        puts "Username or email: ".colorize(:yellow)
        self.username = gets.strip
        puts "Password: ".colorize(:yellow)
        self.password= gets.strip
        puts "\n"
        self.open_page(client_id)
    end

    def open_page(client_id)
        puts "Signing in...".colorize(:yellow)

        browser = Ferrum::Browser.new
        browser.goto("https://accounts.spotify.com/authorize?client_id=#{client_id}&response_type=code&redirect_uri=http://localhost:8000&scope=user-read-private")
        username_input = browser.at_css("#login-username")
        username_input.type(@username, :tab).type(@password)
        # password_input = browser.at_css("#login-password") 
        # password_input.type(@password)
        login = browser.at_css("#login-button")
        login.click
        
        puts "Authorizing user...".colorize(:yellow)
        sleep(1) #Needs to stop for one second because Ferrum gets stuck when it redirects to a new link

        self.first_time
        usr_code = browser.current_url.gsub("http://localhost:8000/?", "")

        if usr_code.include?("code=")
            self.code = usr_code
        else 
            puts "\nIncorrect Username or Password.\n".colorize(:red)
            self.get_token
        end
    end

    def get_token
        self.sign_in(@client_id)
        puts "\nGetting access token & refresh token...".colorize(:yellow)
        request_token = HTTParty.post("https://accounts.spotify.com/api/token", {
                            body: "grant_type=authorization_code&#{code}&redirect_uri=http://localhost:8000&client_id=#{client_id}&client_secret=#{client_secret}"
                            })
        puts "Saving access token...".colorize(:yellow)
        self.access_token = request_token["access_token"]
        API.token(self.access_token)
        puts "Saving refresh token...".colorize(:yellow)
        self.refresh_tkn = request_token["refresh_token"]
        puts "Done.\n".colorize(:green)
        sleep(1)
        puts `clear`

        puts "\nWelcome to Spotify Search on Command Line!".colorize(:green)
        CLI.menu
    end

    def refresh_session
        encoded_keys = Base64.encode64("#{self.client_id}:#{self.client_secret}").gsub("\n", "") 
        refresh = HTTParty.post("https://accounts.spotify.com/api/token", {
                    body: "grant_type=refresh_token&refresh_token=#{self.refresh_tkn}", 
                    headers: {
                        "Content-Type" => "application/x-www-form-urlencoded",
                        "Authorization" => "Basic #{encoded_keys}"
                    }})
    end

    def first_time
        puts "\nIs this your first time using this app?(yes/any key)".colorize(:yellow)
        input = gets.strip.downcase

        if input == "yes"
            agree = browser.at_css("#auth-accept")
            agree.click       
        end
    end


end

