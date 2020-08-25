require "json"

class Spotify
    attr_accessor :name, :type
    
    def initialize(name, type)
        @name = name
        @type = type
    end

    def search
        response = API.get_response(@name, @type)
    
        if type == "track"
            @track_name = response["tracks"]["items"][0]["name"]
            @track_album = response["tracks"]["items"][0]["album"]["name"]
            @track_artist =  response["tracks"]["items"][0]["artists"][0]["name"]
            @track_popularity = response["tracks"]["items"][0]["popularity"]
            @track_release_date = response["tracks"]["items"][0]["album"]["release_date"]
        elsif type == "artist"
            @artist_artist = response["artists"]["items"][0]["name"]
            @artist_followers = response["artists"]["items"][0]["followers"]["total"].to_s.reverse.scan(/\d{3}|.+/).join(",").reverse
            @artist_genres = response["artists"]["items"][0]["genres"].map {|genre| genre.capitalize}
            @artist_popularity = response["artists"]["items"][0]["popularity"]

            @artist_albums = []
            id = response["artists"]["items"][0]["id"]
            albm = API.get_response_from_link("https://api.spotify.com/v1/artists/#{id}/albums?include_groups=album")
            albums = JSON.parse(albm.body)["items"] #[0]["name"]
           
            albums.each do |album|
                @artist_albums << album["name"]
            end
        elsif type == "album"
            @album_name = response["albums"]["items"][0]["name"]
            @album_artist = response["albums"]["items"][0]["artists"][0]["name"]
            @album_release_date = response["albums"]["items"][0]["release_date"]

            @album_tracks = []

            href = response["albums"]["items"][0]["href"]
            tracks = API.get_response_from_link(href)
            names = JSON.parse(tracks.body)["tracks"]["items"] #this goes into the tracks array and the items array of each song to retreive each name  
            names.each do |song|
                @album_tracks << song["name"]
            end
        end

        self.show_results
    end

    def show_results
        if type == "track"
            puts "\nSearch results:".colorize(:green)
            rows = [] #This is part of the table below
            rows << ["Song name: #{@track_name}".colorize(:green)]
            rows << ["Artist: #{@track_artist}".colorize(:green)]
            rows << ["Album: #{@track_album}".colorize(:green)]
            rows << ["Realease date: #{@track_release_date}".colorize(:green)]
            rows << ["Popularity: #{@track_popularity}/100".colorize(:green)]
            table = Terminal::Table.new :headings => ['Song'.colorize(:green)], :rows => rows # uses the row array above to create a terminal table
            puts table
            Spotify.search_again     
        elsif type == "artist"
            puts "\nSearch results:".colorize(:green)
            rows = []
            rows << ["Artist: #{@artist_artist}".colorize(:green)]
            rows << ["Follower(s): #{@artist_followers}".colorize(:green)]
            rows << ["Genre(s): #{@artist_genres.join(", ")}".colorize(:green)]
            rows << ["Popularity: #{@artist_popularity}/100".colorize(:green)]
            rows << ["Albums: ".colorize(:green)]
            @artist_albums.uniq.each_with_index  do |album, index|
                rows << ["      #{index}. #{album}".colorize(:green)]
            end
            table = Terminal::Table.new :headings => ['Artist'.colorize(:green)], :rows => rows
            puts table
            Spotify.search_again     
        elsif type == "album"
            puts "\nSearch results:".colorize(:green)
            rows = []
            rows << ["Album: #{@album_name}".colorize(:green)]
            rows << ["Artist: #{@album_artist}".colorize(:green)]
            rows << ["Songs: ".colorize(:green)]
            @album_tracks.each_with_index  do |song, index|
                rows << ["      #{index}. #{song}".colorize(:green)]
            end
            rows << ["Release date: #{@album_release_date}".colorize(:green)]
            table = Terminal::Table.new :headings => ['Album'.colorize(:green)], :rows => rows
            puts table
            Spotify.search_again     
        end
    end

    def self.search_again
        puts "\nWould you like to do another search?(yes/no)".colorize(:green)
        input = gets.strip.downcase
         
        if input == "yes"
            CLI.menu
        elsif input == "no"
            Spotify.sign_out     
        else
            puts "I don't understand. Please try again.".colorize(:yellow)
            self.search_again
        end
    end

    def self.sign_out 
        puts "\nSigning out...".colorize(:yellow)
        puts "Goodbye.".colorize(:yellow)
        exit
    end
end


