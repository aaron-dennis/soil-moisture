///////////////////////*

MAP

//////////////////////*/

//Width and height
var w = 800;
var h = 600;

//Define projection
var projection = d3.geo.albersUsa()
					.translate([w/2, h/2])
					.scale([1000]);


//Define default path generator
var path = d3.geo.path()
				.projection(projection);

//Colors for high and low
var dryColor = "#fbf3cb";
var wetColor = "#3dc1eb";

//Scale takes data values as input and returns color
var color = d3.scale.linear().domain([0,25])
			.range([dryColor, wetColor])
			.interpolate(d3.interpolateHcl);

//Create SVG element
var svg = d3.select("body")
			.append("svg")
			.attr("width", w)
			.attr("height", h);

//Our soil moisture data
data = d3.csv("/visualization/level3-mean.csv", function(data) {

	console.log(data);

	//Load in GeoJSON data
	d3.json("/visualization/level3-ecoregions.json", function(json) {

		//Merge soil moisture data and GeoJSON
		//Loop through once for each ecoregion
		for (var i = 0; i < data.length; i++) {

			//Grab ecoregion name
			var dataEcoregion = data[i].Ecoregion;

			//Grab data value and convert from string
			var dataValue = parseFloat(data[i].Aug012008);

			//Find corresponding ecoregion in GeoJSON
			for (var j = 0; j < json.features.length; j++) {

				var jsonEcoregion = json.features[j].properties.US_L3NAME;

				if (dataEcoregion == jsonEcoregion) {
				
					//Copy data value into JSON
					json.features[j].properties.Aug012008 = dataValue;

					//Stop looking through GeoJSON
					break;
				}
			}
		}

		//Bind data and create one path per GeoJSON feature
		svg.selectAll("path")
			.data(json.features)
			.enter()
			.append("path")
			.attr("d", path)
			.style("fill", function(d) {
				var value = d.properties.Aug012008;
						if (value) {
							return color(value);
						} else {
							return "#ccc";
						}
			})
			.style("stroke", "white")
			.style("stroke-width", "0.5");
	});
});