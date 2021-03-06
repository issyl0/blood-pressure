require 'rubygems'
require 'sinatra'
require 'twitter_oauth'
require 'mysql'
require 'sanitize'

require './secret'

set :session_secret, SECRET_KEY
enable :sessions

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
	$db_connection = Mysql.new DBSERVER, DBUSER, DBPASS, DBNAME
end

get '/' do
	erb :index
end

get '/twitter_connect' do
  client = TwitterOAuth::Client.new(:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET)
  request_token = client.authentication_request_token(:oauth_callback => CALLBACK_URL)
  session[:request_token] = request_token.token
  session[:request_token_secret] = request_token.secret
  redirect request_token.authorize_url
end

get '/twitter_oauth' do
  session[:oauth_verifier] = params[:oauth_verifier]
  client = TwitterOAuth::Client.new(:consumer_key => CONSUMER_KEY, :consumer_secret => CONSUMER_SECRET)
  client.authorize(session[:request_token], session[:request_token_secret], :oauth_verifier => session[:oauth_verifier])

  user_id_query = $db_connection.query "SELECT user_id FROM users WHERE auth_user_id='twitter_#{client.info["id"]}'"
  # Make sure that the query returns some data before dealing with it.
  user_id_query_result = user_id_query.fetch_row
  if user_id_query_result != nil then
  	user_id = user_id_query_result[0]
  	# User has signed in previously. Update timing of the last login.
    session[:user_id] = user_id
    $db_connection.query "UPDATE users SET last_login_time = NOW() WHERE user_id=#{session[:user_id]}"
  else
  	user_id = nil
  	# Add the new user to the database with a last login time.
    new_user = $db_connection.prepare "INSERT INTO users(auth_user_id, last_login_time) VALUES(?, NOW())"
    new_user.execute "twitter_#{client.info["id"]}"

    user_id_session_query = $db_connection.query "SELECT user_id FROM users WHERE auth_user_id='twitter_#{client.info["id"]}'"
    # Make sure that the query returns some data before dealing with it.
    user_id_session_query_result = user_id_session_query.fetch_row
    if user_id_session_query_result != nil then
    	session[:user_id] = user_id_session_query_result[0]
    end
  end

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
	$db_connection.close # Close the database connection.
end