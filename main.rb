require 'rubygems'
require 'sinatra'
require 'sinatra/cookies'


helpers do
	def generate_random_string()
		# Generate a random 40 character string for the cookie.
		characters = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
		cookie_value = (0..40).map{characters.sample}.join
		return cookie_value
	end
end

# Handle cookies.
before do
	sess_id = cookies['blood-pressure-cookie'].inspect
	if sess_id.nil? or sess_id == 'nil' then
		sess_id = generate_random_string()
		cookies['blood-pressure-cookie'] = sess_id
	end
	# Bizarrely, the cookie string is returned with quotation marks
	# surrounding it. Delete them.
	@sess_id = sess_id.delete '"'
end

get '/' do
	erb :index
end

get '/graph' do
	erb :graph
end

get '/blood-pressures.csv' do
	# Regress to making up some values for now.
	"reading_time,systolic,diastolic\n"+
	"2012-09-28,120,100\n"+
	"2012-10-03,120,80\n"+
	"2012-10-12,110,90\n"+
	"2012-10-26,120,80\n"
end