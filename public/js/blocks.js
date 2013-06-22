function blocks() {
    var margins = {left: 0, top: 15, right: 0, bottom: 15};
    var width = 470;
    var height = 200;

    var x = d3.time.scale();
    var y = d3.scale.linear();
    var hourFormat = d3.time.format("%H:%M");
    var dayFormat = d3.time.format("%a");
    var timeFormat = function(d) {
        if (d.getHours() == 0) {
            return dayFormat(d);
        } else {
            return hourFormat(d);
        }
    };
    var tempFormat = function(d) {
        return d + "°C";
    };

    function block(selection) {

        selection.each(function(data) {
            // Select the svg element, if it exists.
            var svg = d3.select(this).selectAll("svg")
                .data([data]).enter()
                .append("svg")
                .attr("viewBox", "0 0 "+width+" "+height)
                .attr("preserveAspectRatio", "none")
                .attr("height", height)
                .attr("width", width)
                .append("g");

            // Set the domain and range of the x scale
            x.domain(d3.extent(data.observations, function(d) { return new Date(d.time);}))
                .range([margins.left, width-margins.left-margins.right]);

            // Set the domain and range of the y scale
            y.domain(d3.extent(data.observations, function(d) { return d.value; }))
                .range([height-margins.top-margins.bottom, margins.top]);

            // Setup the x axis
            var xAxis = d3.svg.axis()
                .scale(x)
                .tickFormat(timeFormat)
                .tickSize(-height+margins.top+margins.bottom+10);

            // Add the x axis
            svg.append("svg:g")
                .attr("class", "x axis")
                .attr("transform", "translate(0, "+(height-margins.top-10)+")")
                .call(xAxis);

            var line = d3.svg.line()
                .interpolate("monotone")
                .x(function(d) {return x(new Date(d.time));})
                .y(function(d) {return y(d.value);});

            svg.append("path")
                .attr("d", line(data.observations))
                .attr("fill", "none")
                .attr("stroke", "white")
                .attr("stroke-width", 3);
        });
    }

    block.width = function(value) {
        if (!arguments.length) return width;
        width = value;
        return block;
    }

    block.height = function(value) {
        if (!arguments.length) return height;
        height = value;
        return block;
    }

    return block;
}

window.onload = function() {
    d3.json("/weather/48.json", function(data) {
        var container = d3.select("#blocks");

        var b = blocks().height(150);

        var colors = ["light-green", "light-blue"];

        /*
        container.selectAll(".block")
            .data(data).enter()
            .append("div")
        */

        container.selectAll(".block")
            .data(data).enter()
            .append("div")
            .attr("class", function(d, i) {
                return "block columns small-6 "+colors[i%colors.length];
            })
            .call(b)
            .insert("h4", ":first-child")
            .text(function(d) {return d.name + " - temperature last 48 hours";});
    });
}
