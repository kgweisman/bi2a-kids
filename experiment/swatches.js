// compile swatches with image sources and adult ratings

function addSwatch(swatchName, swatchStorage) {
	function Swatch(swatchName) {
		this.swatchName = swatchName;
		this.imageSource = "images/"+swatchName+".png";
	};
	newSwatch = new Swatch(swatchName);
	swatchStorage.push(newSwatch);
}

var swatchNameList = [];
for (i = 0; i < 9; i++) {
	swatchNameList[i] = "BI2A0000"+(i+1);
}
for (i = 9; i < 48; i++) {
	swatchNameList[i] = "BI2A000"+(i+1);
}

var animalRatingAdultUSList = [6.300000, 6.466667, 6.600000, 6.166667, 6.666667, 6.666667, 6.500000, 6.400000, 6.500000, 6.266667, 6.700000, 4.966667, 5.433333, 5.433333, 6.100000, 4.600000, 2.611111, 3.500000, 5.800000, 2.900000, 1.900000, 3.633333, 2.666667, 6.033333, 1.533333, 4.785714, 1.800000, 3.866667, 1.166667, 1.733333, 1.066667, 3.066667, 1.233333, 2.433333, 1.066667, 1.166667, 1.766667, 1.466667, 1.066667, 1.066667, 1.133333, 1.700000, 1.933333, 1.033333, 1.033333, 1.033333, 1.133333, 1.100000];

var swatches = [];
for (i in swatchNameList) {
	addSwatch(swatchNameList[i], swatches);
	swatches[i].animalRatingAdultUS = animalRatingAdultUSList[i];
}
swatches.sort(function(a, b) {return a.animalRatingAdultUS - b.animalRatingAdultUS});

// make 4 sets of 16 swatches, evenly spaced
var swatchSets;

function makeSwatchSets(setNum) {
	// make swatch sets
	var swatchSet1 = [];
	var swatchSet2 = [];
	var swatchSet3 = [];
	var swatchSet4 = [];

	// distribute by US adult animal rating
	for (i = 0; i < swatchNameList.length; i++) {
		var iModulo = i % 4; 
		switch (iModulo) {
			case 0: 
				swatchSet1.push(swatches[i]);
				break;
			case 1:
				swatchSet2.push(swatches[i]);
				break;
			case 2:
				swatchSet3.push(swatches[i]);
				break;			
			case 3:
				swatchSet4.push(swatches[i]);
				break;
			default:
				console.log("error in making swatch sets"); 
		}
	};

	// combine sets into one array
	swatchSets = [{condition: "set1", swatchOrder: swatchSet1}, {condition: "set2",swatchOrder: swatchSet2}, {condition: "set3", swatchOrder: swatchSet3}, {condition: "set4", swatchOrder: swatchSet4}];
}

makeSwatchSets();

var swatchSetPractice = [{
	swatchName: "apple_1",
	imageSource: "practice/apple_1.png",
	questionText: "So here's one of the pictures taken by the special camera. This picture only shows a little part of something, so you might not know what it is yet. Let me zoom out a little..." 
},
{
	swatchName: "apple_2",
	imageSource: "practice/apple_2.png",
	questionText: "Can you tell what it is now? Let me zoom out a little more..." 	
},
{
	swatchName: "apple_3",
	imageSource: "practice/apple_3.png",
	questionText: "Now do you know what the picture shows? An apple! So remember, the special camera..." 
},
{
	swatchName: "apple_1",
	imageSource: "practice/apple_1.png",
	questionText: "...took this picture. So this picture shows a little part of an apple. That's how the special camera works! The pictures always show just a little part of something." 
}]

var swatchSetBonus = [swatchSets[0].swatchOrder[0], swatchSets[2].swatchOrder[0], swatchSets[1].swatchOrder[4], swatchSets[3].swatchOrder[4], swatchSets[0].swatchOrder[7], swatchSets[2].swatchOrder[7], swatchSets[1].swatchOrder[11], swatchSets[3].swatchOrder[11]]
