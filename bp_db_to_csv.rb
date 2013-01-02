# Convert the blood pressures from the database into a CSV file in
# order to display the graph.

require 'rubygems'
require 'mysql'

connection_info = File.open("/home/isabell/bp.txt", "r")
connection_string = connection_info.read.chomp
connection_info.close
server, dbname, dbuser, dbpass = connection_string.split(':',4)
$db_connection = Mysql.new server, dbuser, dbpass, dbname

# User ID of whoever is logged in. Hardcoded until authentication is
# implemented.
userid = 12345

# Get the data.
bp_data = Array.new()
bp_data = $db_connection.query "SELECT reading_time,systolic,diastolic FROM blood_pressures WHERE user_id=#{userid} ORDER BY reading_time"

# Convert array to CSV.
puts "reading_time,systolic,diastolic"
bp_data.each do |i|
	puts i[0].split(" ")[0] + "," + i[1] + "," + i[2]
end