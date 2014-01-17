# coffee to js export crap for button functions
root = exports ? this

transitionTime = 1000

margin = 
  top: 30
  right: 50
  bottom: 75
  left: 75

width = 750 - margin.left - margin.right
height = 400 - margin.top - margin.bottom

parseDate = d3.time.format("%Y-%m-%d").parse
formatTime = d3.time.format("%e %B")

x = d3.time.scale().range([0, width])
y0 = d3.scale.linear().range([height, 0])
y1 = d3.scale.linear().range([height, 0])

xAxis = d3.svg.axis().scale(x).orient("bottom")
yAxisLeft = d3.svg.axis().scale(y0).orient("left")
yAxisLeftMoney = d3.svg.axis().scale(y0).orient("left").tickFormat( (d) -> "$" + Number(d).toFixed(2))
yAxisRight = d3.svg.axis().scale(y1).orient("right")

globalDataType = ""

makeXAxis = () ->
  d3.svg.axis().scale(x).orient("bottom")

makeYAxis = () ->
  d3.svg.axis().scale(y0).orient("left")

# tip = d3.tip()
#   .attr("class", "tooltip")
#   .offset([-10, 0])
#   .html( (d) -> formatTime(d.date) + "<br />#{dataType}: " + d[globalDataType])

valueLine = d3.svg.line()
  .x( (d) -> x(d.date) )
  .y( (d) -> y0(d[globalDataType]) )

area = d3.svg.area()
  .x( (d) -> x(d.date) )
  .y0(height)
  .y1( (d) -> y0(d[globalDataType]) )

div = d3.select("body").append("div")
  .attr("class", "tooltip")
  .style("opacity", 0)

tabulate = (data, columns) ->
  table = d3.select("body").append("table")
    .attr("style", "margin-left: 250px")
  thead = table.append("thead")
  tbody = table.append("tbody")

  thead.append("tr")
    .selectAll("th")
    .data(columns)
    .enter()
    .append("th")
      .text( (column) -> column)

  rows = tbody.selectAll("tr")
    .data(data)
    .enter()
    .append("tr")

  cells = rows.selectAll("td")
    .data( (row) -> columns.map( (column) -> column: column, value: row[column]))
    .enter()
    .append("td")
    .attr("style", "font-family: Courier")
      .html( (d) -> d.value)

  return table

svg = d3.select("body")
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

counter = 0

@pickGraph = window.pickGraph = root.pickGraph = (e) ->
  console.log "window.event = #{window.event}"
  console.log "e = #{e}"

  e = e || window.event 
  e = e.target || e.srcElement || e

  title = e.defaultValue || e.value
  dataType = e.id
  globalDataType = dataType

  updateGraph(dataType, title)

mpgGraph = (data) ->
  svg = d3.select("body").transition()

  svg.select(".y.axis")
    .duration(transitionTime)
    .call(yAxisLeft)

  svg.select(".yAxisTitle")
    .text("Miles (US)")

ppgGraph = (data) ->
  svg = d3.select("body").transition()

  svg.select(".y.axis")
    .duration(transitionTime)
    .call(yAxisLeftMoney)

  svg.select(".yAxisTitle")
    .text("US Dollars ($)")

ppfGraph = (data) ->
  svg = d3.select("body").transition()

  svg.select(".y.axis")
    .duration(transitionTime)
    .call(yAxisLeftMoney)

  svg.select(".yAxisTitle")
    .text("US Dollars ($)")

fuelGraph = (data) ->
  svg = d3.select("body").transition()

  svg.select(".y.axis")
    .duration(transitionTime)
    .call(yAxisLeft)

  svg.select(".yAxisTitle")
    .text("US Dollars ($)")

odometerGraph = (data) ->
  svg = d3.select("body").transition()

  svg.select(".y.axis")
    .duration(transitionTime)
    .call(yAxisLeft)

  svg.select(".yAxisTitle")
    .text("Miles (US)")

updateGraph = (dataType, title) ->
  d3.csv "data/f150.csv", (error, data) ->
    data.forEach (d) ->
      d.dateStr = d.date
      d.date = parseDate(d.date)
      d.odometer = +d.odometer
      d.fuel = +d.fuel
      d.price = +d.price
      d.ppg = Number(d.price / d.fuel).toFixed(2)
      d.mpg = Number(d.mpg).toFixed(2)

    # x.domain(d3.extent(data, (d) -> d.date))
    min = +d3.min(data, (d) -> d[dataType]) - 0.5
    max = +d3.max(data, (d) -> d[dataType])
    offset = (max - min) / 4

    min = Number(min).toFixed(2) - Number(offset).toFixed(2)
    # max = Number(max).toFixed(2) + Number(offset).toFixed(2)

    y0.domain([min, max])

    svg = d3.select("body")

    svg.select(".title")
      .text("F150 - #{title}")

    svg.select(".line")
      .transition()
      .duration(transitionTime)
      .attr("d", valueLine(data))

    svg.select(".area")
      .transition()
      .duration(transitionTime)
      .attr("d", area(data))

    svg.selectAll("circle")
      .transition()
      .duration(transitionTime)
      .attr("cx", (d) -> x(d.date))
      .attr("cy", (d) -> y0(d[dataType]))

    tooltipText = ""
    isPrice = false
    switch dataType
      when 'ppg'
        # ppgGraph(data)
        tooltipText = "Price Per Gal: $"
        isPrice = true
      when 'mpg'
        # mpgGraph(data)
        tooltipText = "MPG: "
      when 'odometer'
        # odometerGraph(data)
        tooltipText = "Miles (US): "
      when 'fuel'
        # fuelGraph(data)
        tooltipText = "Gallons (US): "
      when 'price'
        # ppfGraph(data)
        tooltipText = "Price: $"
        isPrice = true

    svg = d3.select("body")

    #keep mouse events before transition / don't call transition() you'll get the wrong object back
    svg.selectAll("circle")
      .on("mouseover", (d) -> 
        div.transition()
            .duration(200)
            .style("opacity", 0.8)
        div.html(formatTime(d.date) + "<br />#{tooltipText}" + d[dataType])
            .style("left", d3.event.pageX - (div[0][0].clientWidth / 2) + "px")
            .style("top", (d3.event.pageY - 60) + "px")) 
      .on("mouseout", (d) ->
          div.transition()
            .duration(500)
            .style("opacity", 0)
        )

    leftAxis = if isPrice then yAxisLeftMoney else yAxisLeft 
    svg.select(".y.axis")
      .transition()
      .duration(transitionTime)
      .call(leftAxis)

    svg.select(".yAxisTitle")
      .text("#{tooltipText}")

initGraph = (dataType, title) ->
  globalDataType = dataType
  d3.csv "data/f150.csv", (error, data) ->
    data.forEach (d) ->
      d.dateStr = d.date
      d.date = parseDate(d.date)
      d.odometer = +d.odometer
      d.fuel = Number(d.fuel).toFixed(2)
      d.price = Number(d.price).toFixed(2)
      d.ppg = Number(d.price / d.fuel).toFixed(2)
      d.mpg = Number(d.mpg).toFixed(2)


    min = +d3.min(data, (d) -> d[dataType]) - 0.5
    max = +d3.max(data, (d) -> d[dataType])
    offset = (max - min) / 4

    min = Number(min).toFixed(2) - Number(offset).toFixed(2)

    x.domain(d3.extent(data, (d) -> d.date))
    # y0.domain([d3.min(data, (d) -> d.price), d3.max(data, (d) -> d.price)])
    y0.domain([min, d3.max(data, (d) -> d[dataType])])
    y1.domain([12, d3.max(data, (d) -> d.mpg)])

    # peopleTable = tabulate(data, ["dateStr", "price", "mpg", "odometer"])
    # peopleTable.selectAll("tbody tr")
    #   .sort((a, b) -> d3.descending(a.mpg, b.mpg))

    # peopleTable.selectAll("th")
    #   .text( (column) -> column.charAt(0).toUpperCase() + column.substr(1))

    svg.append("path")
      # .datum(data)
      .attr("class", "area")
      .attr("d", area(data))

    svg.append("path")
      .attr("class", "line")
      .attr("d", valueLine(data))

    dots = svg.selectAll("dot")

    dots.data(data)
      .enter().append("circle")
        .attr("r", 5)
        .attr("cx", (d) -> x(d.date))
        .attr("cy", (d) -> y0(d[dataType]))
        .on("mouseover", (d) ->
          div.transition()
            .duration(200)
            .style("opacity", 0.8)
          div.html(formatTime(d.date) + "<br />#{dataType.toUpperCase()}: " + d[dataType])
            .style("left", d3.event.pageX - (div[0][0].clientWidth / 2) + "px")
            .style("top", (d3.event.pageY - 60) + "px")
        )
        .on("mouseout", (d) ->
          div.transition()
            .duration(500)
            .style("opacity", 0)
        )

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .style("fill", "#f3f3f3")
      .call(xAxis)
      .selectAll("text")
        .style("text-anchor", "end")
        .attr("dx", "-.8em")
        .attr("dy", ".15em")
        .attr("transform", "rotate(-45)")

    svg.append("g")
      .attr("class", "y axis")
      .style("fill", "#f3f3f3")
      .call(yAxisLeft)

    svg.append("g")
      .attr("class", "grid")
      .attr("transform", "translate(0, #{height})")
      .style("opacity", 0.2)
      .call( makeXAxis().tickSize(-height, 0, 0).tickFormat("") )

    svg.append("g")
      .attr("class", "grid")
      .style("opacity", 0.2)
      .call( makeYAxis().tickSize(-width, 0, 0).tickFormat("") )

    svg.append("text")
      .attr("class", "yAxisTitle")
      .attr("transform", "rotate(-90)")
      .attr("y", 0 - margin.left)
      .attr("x", 0 - (height / 2))
      .attr("dy", "1em")
      .style("text-anchor", "middle")
      .style("fill", "#f3f3f3")
      .text("Value")

    svg.append("text")
      .attr("x", (width / 2))
      .attr("y", (height + margin.bottom))
      .style("text-anchor", "middle")
      .style("fill", "#f3f3f3")
      .text("Date")
      
    svg.append("text")
      .attr("class", "title")
      .attr("x", (width / 2))
      .attr("y", 0 - (margin.top / 2))
      .style("text-anchor", "middle")
      .style("font-size", "16px")
      .style("text-decoration", "underline")
      .style("font-weight", "bold")
      .style("fill", "#f3f3f3")
      .text("F150 - Miles Per Gallon")

    mpgGraph(data)

initGraph("mpg")