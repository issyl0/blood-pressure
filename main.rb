require 'rubygems'
require 'sinatra'
require 'sinatra/cookies'
require 'mysql'
require 'sanitize'

helpers do
	def generate_random_string()
		# Generate a random 40 character string for the cookie.
		characters = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
		return (0..40).map{characters.sample}.join
	end

	def get_blood_pressure_data(userid)
		# Get the data.
		bp_data = Array.new()
		bp_data = $db_connection.query "SELECT reading_time,systolic,diastolic FROM blood_pressures WHERE user_id=#{userid} ORDER BY reading_time"

		# Convert array to CSV.
		csv_data = "reading_time,systolic,diastolic\n"
		bp_data.each do |i|
			csv_data += i[0].split(" ")[0] + "," + i[1] + "," + i[2] + "\n"
		end
		return csv_data
	end
end

before do
	# Handle cookies.
	sess_id = cookies['blood-pressure-cookie'].inspect
	if sess_id.nil? or sess_id == 'nil' then
		sess_id = generate_random_string()
		cookies['blood-pressure-cookie'] = sess_id
	end
	# Bizarrely, the cookie string is returned with quotation marks
	# surrounding it. Delete them.
	@sess_id = sess_id.delete '"'

	# Establish a database connection.	
	$connection_info = File.open("/Users/isabell/bp.txt", "r")
	connection_string = $connection_info.read.chomp
	server, dbname, dbuser, dbpass = connection_string.split(':',4)
	$db_connection = Mysql.new server, dbuser, dbpass, dbname

	# Look up user ID based on session ID.
	result = $db_connection.query "SELECT user_id FROM users WHERE cookie_id = '#{@sess_id}'"
	if result.num_rows == 1
		@userid = result.fetch_row[0].to_i
	else
		@userid = nil
	end
end

get '/' do
	erb :index
end

get '/graph' do
	# A user who is not logged in should not be able to view graphs.
	if @userid != nil then
		erb :graph
	else
		"Sorry, you are not logged in."
	end
end

get '/blood-pressures.csv' do
	# A user who is not logged in should not be able to view graphs.
	if @userid != nil then
		get_blood_pressure_data(@userid)
	else
		"Sorry, you are not logged in."
	end
end

get '/logout' do
	# Log the user out, removing his or her cookie from the database.
	@userid = nil
	$db_connection.query "UPDATE users SET cookie_id = NULL WHERE cookie_id = '#{@sess_id}'"
	erb :index
end

get '/submit' do
	if !params[:systolic].nil? && params[:systolic].match(/^\d+$/) && !params[:diastolic].nil? && params[:diastolic].match(/^\d+$/) && !params[:readingtime].nil? && params[:readingtime].match(/^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}$/) then
		send_data = $db_connection.prepare "INSERT INTO blood_pressures(user_id,reading_time,entered_time,systolic,diastolic) VALUES(?,?,?,?,?)"
		send_data.execute @userid, params[:readingtime], Time.now(), params[:systolic], params[:diastolic]
		"Data insertion successful."
	end
end

after do
	$connection_info.close # Close the database connection.
end