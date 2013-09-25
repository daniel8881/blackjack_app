require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

helpers do
def calculate_total(cards) # cards is [["H", "3"], ["D", "J"], ... ]
    arr = cards.map{|element| element[1]}

    total = 0
    arr.each do |a|
      if a == "A"
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    #correct for Aces
    arr.select{|element| element == "A"}.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

end

before do
  @shoe_hit_or_stay_buttons = true
end


get '/' do
	if session[:player_name]
	redirect '/game'
	else
	redirect '/new_player'	
	end
end

get '/new_player' do
 erb :new_player
end


post '/new_player' do
session[:player_name] = params[:player_name]
redirect '/game'
end

get '/game' do
 suit = ['H', 'C', 'D' ,'S']
 values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
 session[:deck] = suit.product(values).shuffle!

 session[:dealer_cards] = []
 session[:player_cards] = []

 session[:dealer_cards] << session[:deck].pop
 session[:player_cards] << session[:deck].pop
 session[:dealer_cards] << session[:deck].pop
 session[:player_cards] << session[:deck].pop

 erb :game
end

post '/game/player/hit' do
  
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    @error = "Sorry, it looks like you busted!"
    @shoe_hit_or_stay_buttons = false
  end
 erb :game
end

post '/game/player/stay' do
 @shoe_hit_or_stay_buttons = false
 @success = "you have chosen to stay!"
 erb :game
end