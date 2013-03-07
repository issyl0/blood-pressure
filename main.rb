require 'rubygems'
require 'sinatra'
require 'twitter_oauth'
require 'mysql'
require 'sanitize'

enable :sessions

CONSUMER_KEY = ""
CONSUMER_SECRET = ""
CALLBACK_URL = ""

helpers do
	def get_blood_pressure_data(user_id)
		# Get the data.
		bp_data = Array.new()
		bp_data = $db_connection.query "SELECT reading_time,systolic,diastolic FROM blood_pressures WHERE user_id=#{user_id} ORDER BY reading_time"

		# Convert array to CSV.
		csv_data = "reading_time,systolic,diastolic\n"
		bp_data.each do |i|
			csv_data += i[0].split(" ")[0] + "," + i[1] + "," + i[2] + "\n"
		end
		return csv_data
	end
end

before do
	# Establish a database connection.	
	$connection_info = File.open("/Users/isabell/bp.txt", "r")
	connection_string = $connection_info.read.chomp
	server, dbname, dbuser, dbpass = connection_string.split(':',4)
	$db_connection = Mysql.new server, dbuser, dbpass, dbname
end

get '/' do
	erb :index
end

get '/connect' do
  client = TwitterOAuth::Client.new(:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET)
  request_token = client.request_token(:oauth_callback => CALLBACK_URL)
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url
end

get '/oauth' do
  session[:oauth_verifier] = params[:oauth_verifier]
  client = TwitterOAuth::Client.new(:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET)
  client.authorize(session[:request_token], session[:request_token_secret], :oauth_verifier => session[:oauth_verifier])
  session[:user_id] = client.info["id"]
  session[:screen_name] = client.info["screen_name"] 
  redirect "/"
end

get '/stats' do
	# A user who is not logged in should not be able to view stats.
	if session[:user_id] != nil then
		erb :stats
	else
		"Sorry, you are not logged in."
	end
end

get '/blood-pressures.csv' do
	# A user who is not logged in should not be able to view stats.
	if session[:user_id] != nil then
		get_blood_pressure_data(session[:user_id])
	else
		"Sorry, you are not logged in."
	end
end

get '/logout' do
	# Log the user out.
	session[:user_id] = nil
	redirect '/'
end

get '/submit' do
	if !params[:systolic].nil? && params[:systolic].match(/^\d+$/) && !params[:diastolic].nil? && params[:diastolic].match(/^\d+$/) && !params[:readingtime].nil? && params[:readingtime].match(/^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}$/) then
		send_data = $db_connection.prepare "INSERT INTO blood_pressures(user_id,reading_time,entered_time,systolic,diastolic) VALUES(?,?,?,?,?)"
		send_data.execute session[:user_id], params[:readingtime], Time.now(), params[:systolic], params[:diastolic]
		"Data insertion successful."
	end
end

after do
	$connection_info.close # Close the database connection.
end