// Generated by CoffeeScript 1.6.3
var area, counter, div, formatTime, fuelGraph, globalDataType, height, initGraph, makeXAxis, makeYAxis, margin, mpgGraph, odometerGraph, parseDate, ppfGraph, ppgGraph, root, svg, tabulate, transitionTime, updateGraph, valueLine, width, x, xAxis, y0, y1, yAxisLeft, yAxisLeftMoney, yAxisRight;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

transitionTime = 1000;

margin = {
  top: 30,
  right: 50,
  bottom: 75,
  left: 75
};

width = 750 - margin.left - margin.right;

height = 400 - margin.top - margin.bottom;

parseDate = d3.time.format("%Y-%m-%d").parse;

formatTime = d3.time.format("%e %B");

x = d3.time.scale().range([0, width]);

y0 = d3.scale.linear().range([height, 0]);

y1 = d3.scale.linear().range([height, 0]);

xAxis = d3.svg.axis().scale(x).orient("bottom");

yAxisLeft = d3.svg.axis().scale(y0).orient("left");

yAxisLeftMoney = d3.svg.axis().scale(y0).orient("left").tickFormat(function(d) {
  return "$" + Number(d).toFixed(2);
});

yAxisRight = d3.svg.axis().scale(y1).orient("right");

globalDataType = "";

makeXAxis = function() {
  return d3.svg.axis().scale(x).orient("bottom");
};

makeYAxis = function() {
  return d3.svg.axis().scale(y0).orient("left");
};

valueLine = d3.svg.line().x(function(d) {
  return x(d.date);
}).y(function(d) {
  return y0(d[globalDataType]);
});

area = d3.svg.area().x(function(d) {
  return x(d.date);
}).y0(height).y1(function(d) {
  return y0(d[globalDataType]);
});

div = d3.select("body").append("div").attr("class", "tooltip").style("opacity", 0);

tabulate = function(data, columns) {
  var cells, rows, table, tbody, thead;
  table = d3.select("body").append("table").attr("style", "margin-left: 250px");
  thead = table.append("thead");
  tbody = table.append("tbody");
  thead.append("tr").selectAll("th").data(columns).enter().append("th").text(function(column) {
    return column;
  });
  rows = tbody.selectAll("tr").data(data).enter().append("tr");
  cells = rows.selectAll("td").data(function(row) {
    return columns.map(function(column) {
      return {
        column: column,
        value: row[column]
      };
    });
  }).enter().append("td").attr("style", "font-family: Courier").html(function(d) {
    return d.value;
  });
  return table;
};

svg = d3.select("body").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

counter = 0;

this.pickGraph = window.pickGraph = root.pickGraph = function(e) {
  var dataType, title;
  console.log("window.event = " + window.event);
  console.log("e = " + e);
  e = e || window.event;
  e = e.target || e.srcElement || e;
  title = e.defaultValue || e.value;
  dataType = e.id;
  globalDataType = dataType;
  return updateGraph(dataType, title);
};

mpgGraph = function(data) {
  svg = d3.select("body").transition();
  svg.select(".y.axis").duration(transitionTime).call(yAxisLeft);
  return svg.select(".yAxisTitle").text("Miles (US)");
};

ppgGraph = function(data) {
  svg = d3.select("body").transition();
  svg.select(".y.axis").duration(transitionTime).call(yAxisLeftMoney);
  return svg.select(".yAxisTitle").text("US Dollars ($)");
};

ppfGraph = function(data) {
  svg = d3.select("body").transition();
  svg.select(".y.axis").duration(transitionTime).call(yAxisLeftMoney);
  return svg.select(".yAxisTitle").text("US Dollars ($)");
};

fuelGraph = function(data) {
  svg = d3.select("body").transition();
  svg.select(".y.axis").duration(transitionTime).call(yAxisLeft);
  return svg.select(".yAxisTitle").text("US Dollars ($)");
};

odometerGraph = function(data) {
  svg = d3.select("body").transition();
  svg.select(".y.axis").duration(transitionTime).call(yAxisLeft);
  return svg.select(".yAxisTitle").text("Miles (US)");
};

updateGraph = function(dataType, title) {
  return d3.csv("data/f150.csv", function(error, data) {
    var isPrice, leftAxis, max, min, offset, tooltipText;
    data.forEach(function(d) {
      d.dateStr = d.date;
      d.date = parseDate(d.date);
      d.odometer = +d.odometer;
      d.fuel = +d.fuel;
      d.price = +d.price;
      d.ppg = Number(d.price / d.fuel).toFixed(2);
      return d.mpg = Number(d.mpg).toFixed(2);
    });
    min = +d3.min(data, function(d) {
      return d[dataType];
    }) - 0.5;
    max = +d3.max(data, function(d) {
      return d[dataType];
    });
    offset = (max - min) / 4;
    min = Number(min).toFixed(2) - Number(offset).toFixed(2);
    y0.domain([min, max]);
    svg = d3.select("body");
    svg.select(".title").text("F150 - " + title);
    svg.select(".line").transition().duration(transitionTime).attr("d", valueLine(data));
    svg.select(".area").transition().duration(transitionTime).attr("d", area(data));
    svg.selectAll("circle").transition().duration(transitionTime).attr("cx", function(d) {
      return x(d.date);
    }).attr("cy", function(d) {
      return y0(d[dataType]);
    });
    tooltipText = "";
    isPrice = false;
    switch (dataType) {
      case 'ppg':
        tooltipText = "Price Per Gal: $";
        isPrice = true;
        break;
      case 'mpg':
        tooltipText = "MPG: ";
        break;
      case 'odometer':
        tooltipText = "Miles (US): ";
        break;
      case 'fuel':
        tooltipText = "Gallons (US): ";
        break;
      case 'price':
        tooltipText = "Price: $";
        isPrice = true;
    }
    svg = d3.select("body");
    svg.selectAll("circle").on("mouseover", function(d) {
      div.transition().duration(200).style("opacity", 0.8);
      return div.html(formatTime(d.date) + ("<br />" + tooltipText) + d[dataType]).style("left", d3.event.pageX - (div[0][0].clientWidth / 2) + "px").style("top", (d3.event.pageY - 60) + "px");
    }).on("mouseout", function(d) {
      return div.transition().duration(500).style("opacity", 0);
    });
    leftAxis = isPrice ? yAxisLeftMoney : yAxisLeft;
    svg.select(".y.axis").transition().duration(transitionTime).call(leftAxis);
    return svg.select(".yAxisTitle").text("" + tooltipText);
  });
};

initGraph = function(dataType, title) {
  globalDataType = dataType;
  return d3.csv("data/f150.csv", function(error, data) {
    var dots, max, min, offset;
    data.forEach(function(d) {
      d.dateStr = d.date;
      d.date = parseDate(d.date);
      d.odometer = +d.odometer;
      d.fuel = Number(d.fuel).toFixed(2);
      d.price = Number(d.price).toFixed(2);
      d.ppg = Number(d.price / d.fuel).toFixed(2);
      return d.mpg = Number(d.mpg).toFixed(2);
    });
    min = +d3.min(data, function(d) {
      return d[dataType];
    }) - 0.5;
    max = +d3.max(data, function(d) {
      return d[dataType];
    });
    offset = (max - min) / 4;
    min = Number(min).toFixed(2) - Number(offset).toFixed(2);
    x.domain(d3.extent(data, function(d) {
      return d.date;
    }));
    y0.domain([
      min, d3.max(data, function(d) {
        return d[dataType];
      })
    ]);
    y1.domain([
      12, d3.max(data, function(d) {
        return d.mpg;
      })
    ]);
    svg.append("path").attr("class", "area").attr("d", area(data));
    svg.append("path").attr("class", "line").attr("d", valueLine(data));
    dots = svg.selectAll("dot");
    dots.data(data).enter().append("circle").attr("r", 5).attr("cx", function(d) {
      return x(d.date);
    }).attr("cy", function(d) {
      return y0(d[dataType]);
    }).on("mouseover", function(d) {
      div.transition().duration(200).style("opacity", 0.8);
      return div.html(formatTime(d.date) + ("<br />" + (dataType.toUpperCase()) + ": ") + d[dataType]).style("left", d3.event.pageX - (div[0][0].clientWidth / 2) + "px").style("top", (d3.event.pageY - 60) + "px");
    }).on("mouseout", function(d) {
      return div.transition().duration(500).style("opacity", 0);
    });
    svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").style("fill", "#f3f3f3").call(xAxis).selectAll("text").style("text-anchor", "end").attr("dx", "-.8em").attr("dy", ".15em").attr("transform", "rotate(-45)");
    svg.append("g").attr("class", "y axis").style("fill", "#f3f3f3").call(yAxisLeft);
    svg.append("g").attr("class", "grid").attr("transform", "translate(0, " + height + ")").style("opacity", 0.2).call(makeXAxis().tickSize(-height, 0, 0).tickFormat(""));
    svg.append("g").attr("class", "grid").style("opacity", 0.2).call(makeYAxis().tickSize(-width, 0, 0).tickFormat(""));
    svg.append("text").attr("class", "yAxisTitle").attr("transform", "rotate(-90)").attr("y", 0 - margin.left).attr("x", 0 - (height / 2)).attr("dy", "1em").style("text-anchor", "middle").style("fill", "#f3f3f3").text("Value");
    svg.append("text").attr("x", width / 2).attr("y", height + margin.bottom).style("text-anchor", "middle").style("fill", "#f3f3f3").text("Date");
    svg.append("text").attr("class", "title").attr("x", width / 2).attr("y", 0 - (margin.top / 2)).style("text-anchor", "middle").style("font-size", "16px").style("text-decoration", "underline").style("font-weight", "bold").style("fill", "#f3f3f3").text("F150 - Miles Per Gallon");
    return mpgGraph(data);
  });
};

initGraph("mpg");
