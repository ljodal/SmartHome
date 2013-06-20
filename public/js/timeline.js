function Timeline(data, options) {
	var options = options || {};
	
	var margins = options.margins || [30, 10, 0, 10];
	var width = (options.width || 720) - margins[0] - margins[2];
	var height = (options.height || 200) - margins[1] - margins[3];
	var start = options.start; 
	if (!start) {
		start = new Date();
		start.setHours(start.getHours() - 24); // Default is 24 hours
		start.setMinutes(0);
		start.setSeconds(0);
		start.setMilliseconds(0);
	}
	
	var colors = options.colors || ["#7CC7EF", "#2EB398"];
		
	var stop = options.stop;
	if (!stop) {
		stop = new Date();
		stop.setMinutes(0);
		stop.setSeconds(0);
		stop.setMilliseconds(0);
	}
	
	var hourFormat = d3.time.format("%H:%M");
	var tempFormat = function(d) {
		return d + "°C";
	};
	
	// Scales and axes.
	var x = d3.time.scale().range([margins[0], width]),
	    y = d3.scale.linear().range([height, margins[3]]),
	    xAxis = d3.svg.axis().scale(x).ticks(d3.time.hours, 2).tickSize(-height).tickFormat(hourFormat).tickSubdivide(true),
	    yAxis = d3.svg.axis().scale(y).ticks(5).tickSize(width-margins[0]).orient("left").tickFormat(tempFormat).tickSubdivide(true);
	
	// A line generator, for the dark stroke.
	var line = d3.svg.line()
	    .interpolate("monotone")
	    .x(function(d) { return x(new Date(d.time)); })
	    .y(function(d) { return y(d.value); });
		
	d3.json(data, function(stations) {
		// Compute the minimum and maximum date, and the maximum price.
		x.domain([start, stop]);
		y.domain([11, 23]).nice();
		
		var svg = d3.select("#content").append("svg:svg")
			.attr("width", width+margins[0]+margins[2])
			.attr("height", height+margins[1]+margins[3])
			.attr("viewBox", "0 0 "+(width+margins[0]+margins[2])+" "+(height+margins[1]+margins[3]));
			
	    // Add the x-axis.
	    svg.append("svg:g")
	        .attr("class", "x axis")
	        .attr("transform", "translate(0," + (height+margins[1])  + ")")
	        .call(xAxis);

	    // Add the y-axis.
	    svg.append("svg:g")
	        .attr("class", "y axis")
	        .attr("transform", "translate(" + (width-margins[2]) + ",0)")
	        .call(yAxis);
			
		var len = stations.length;
		
		// Add a box below the labels
		svg.append("svg:rect")
			.attr("x", margins[0]+3)
			.attr("y", margins[1]+3)
			.attr("height", 15*len+3)
			.attr("width", 77)
			.attr("fill", "#FCFCFD");
		
		for (i = 0; i < len; i++) {
			svg.append("svg:path")
				.attr("class", "line")
				.attr("d", line(stations[i].observations))
				.attr("stroke", colors[i%colors.length])
				.attr("fill", "none")
				.attr("stroke-width", 2);
				
			// Add a small label for the symbol name.
			svg.append("svg:text")
				.attr("class", "label")
				.attr("x", margins[0]+5)
				.attr("y", margins[1]+15 + i*15)
				.attr("text-anchor", "start")
				.text(stations[i].name)
				.attr("fill", colors[i%colors.length]);
		}
	});
}

window.onload = function() {
	new Timeline("/weather/24.json");
};