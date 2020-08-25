class CLI
      def start
        puts " _______  _______  _______  _______  ___   _______  __   __  ______\n|       ||       ||       ||       ||   | |       ||  | |  ||      | \n|  _____||    _  ||   _   ||_     _||   | |    ___||  |_|  ||___   | \n| |_____ |   |_| ||  | |  |  |   |  |   | |   |___ |       |  __|  | \n|_____  ||    ___||  |_|  |  |   |  |   | |    ___||_     _| |_____| \n _____| ||   |    |       |  |   |  |   | |   |      |   |     __    \n|_______||___|    |_______|  |___|  |___| |___|      |___|    |__|\n".colorize(:green)
        puts "--------------------------------------------------------------------\n".colorize(:light_black)
        API.new.get_token
    end

    def self.menu
        rows = []
        rows << ['Song'.colorize(:green), 'Artist'.colorize(:green), 'Album'.colorize(:green)]
        table = Terminal::Table.new :rows => rows
        puts "\n"
        puts table
        self.take_input
    end

    def self.take_input
        puts "\nPlease enter a type:".colorize(:green)
        type = gets.strip.downcase

        if type == "song"
            type = "track"
            puts "\nWhat song would you like to look for?".colorize(:green)
            song_title = gets.strip.gsub(' ', '%20')
            new_song = Spotify.new(song_title, type)
            new_song.search
        elsif type == "artist"
            puts "\nWhat artist would you like to look for?".colorize(:green)
            artist_name = gets.strip.gsub(' ', '%20')
            new_artist = Spotify.new(artist_name, type)
            new_artist.search
        elsif type == "album"
            puts "\nWhat album would you like to look for?".colorize(:green)
            album_title = gets.strip.gsub(' ', '%20')
            new_album = Spotify.new(album_title, type)
            new_album.search
        else
            puts "\nSorry I don't understand. Please try again.".colorize(:yellow)
            self.take_input
        end
    end
        
end