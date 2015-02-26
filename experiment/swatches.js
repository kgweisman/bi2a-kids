function addSwatch(swatchName, animalRatingUS, animalRatingInd) {
	function Swatch(swatchName, animalRatingUS, animalRatingUS) {
		this.swatchName = swatchName;
		this.animalRatingUS = animalRatingUS;
		this.animalRatingInd = animalRatingInd;
		this.imageSource = "images/"+swatchName+".png";
	};
	newSwatch = new Swatch(swatchName, animalRatingUS, animalRatingInd)
}

var swatchNameList = [];
for (i = 0; i < 10; i++) {
	swatchNameList[i] = "BI2A0000"+(i+1);
}
for (i = 10; i < 48; i++) {
	swatchNameList[i] = "BI2A000"+(i+1);
}

var swatches = {};
for (i in swatchNameList) {
	addSwatch(swatchNameList[i]);
}
