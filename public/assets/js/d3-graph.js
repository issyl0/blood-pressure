var margin = {top: 100, right: 100, bottom: 100, left: 100},
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

var parseDate = d3.time.format("%Y-%m-%d").parse;
var formatDate = d3.time.format("%Y-%m-%d");

var x = d3.time.scale()
    .range([0, width])
    .nice(d3.time.day);

var y = d3.scale.linear()
    .range([height, 0]);

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

// Systolic line.
var line0 = d3.svg.line()
    .x(function(d) { return x(d.reading_time); })
    .y(function(d) { return y(d.systolic); })

// Diastolic line.
var line1 = d3.svg.line()
    .x(function(d) { return x(d.reading_time); })
    .y(function(d) { return y(d.diastolic); })

var svg = d3.select("div#content").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// Parse the CSV of blood pressures.
d3.csv("/blood-pressures.csv", function(error, data) {
  data.forEach(function(d) {
    d.reading_time = parseDate(d.reading_time);
    d.systolic = +d.systolic;
    d.diastolic = +d.diastolic;
  });

  /* Find the range of the systolic/diastolic blood pressure values,
   * then make the y axis the minimum of the systolic and maximum of
   * diastolic values. */
  x.domain(d3.extent(data, function(d) { return d.reading_time; }));
  var smin = d3.min(data, function(d) { return d.systolic; });
  var smax = d3.max(data, function(d) { return d.systolic; });
  var dmin = d3.min(data, function(d) { return d.diastolic; });
  var dmax = d3.max(data, function(d) { return d.diastolic; });
  y.domain([Math.min(smin,dmin),Math.max(smax,dmax)]);

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("blood pressure readings");

  // Display both lines.
  svg.append("path")
      .datum(data)
      .attr("class", "line0")
      .attr("d", line0);
  svg.append("path")
      .datum(data)
      .attr("class", "line1")
      .attr("d", line1);

  // Display the user's five most recent blood pressures.
  $("#bp_user_readings_container").append("<table id='bp_user_readings_table'><thead><tr><th>Reading Time</th><th>Systolic</th><th>Diastolic</th></tr></thead>");
  for (i = 0; i <= 5; i++) {
    var d = data.pop();
    if (d) {
      $("#bp_user_readings_table").append("<tr><td>" + formatDate(d.reading_time) + "</td><td>" + d.systolic + "</td><td>" + d.diastolic + "</td></tr>");
    }
  }
  $("#bp_user_readings_container").append("</table>")
});