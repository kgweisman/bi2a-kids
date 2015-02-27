// choose condition randomly
var chosenCondition = randomElementNR(swatchSets);

// display random swatch on stage slide
// $('.slide#stage img').attr("src", randomElementNR(chosenCondition.swatchOrder).imageSource);

// create experiment object
var experiment = {
	trials: chosenCondition.swatchOrder.slice(),
	dateOfTest: new Date(),
	condition: chosenCondition.condition.slice(),
	trialData: [],

	// what happens after completing all trials
	end: function() {
		showSlide("bonus");
	},

	// what happens when participant sees a new trial
	next: function() {
		if (this.trials.length === 0) {
			experiment.end();
		} else {

			// create place to store data for this trial
			var data = {
				trialNum: (chosenCondition.swatchOrder.length + 1) - this.trials.length,
				swatch: "",
				response: "",
				responseCoded: NaN,
				rt: NaN
			};

			// choose random image to display
			chosenSwatch = randomElementNR(this.trials);
			data.swatch = chosenSwatch.swatchName;

			// display chosen image
			$('.slide#stage img').attr("src", chosenSwatch.imageSource);

			// show trial
			showSlide("stage");

			// record response and rt
			var startTime = (new Date()).getTime();

			var clickHandler = function(event) {
				var endTime = (new Date()).getTime();
				data.rt = endTime - startTime;
				experiment.trialData.push(data);
			};

			$('.slide#stage button').click(function() {
				// record response
				data.response = $(this).attr('id');
				data.responseCoded = parseFloat($(this).attr('value'));

				// end trial
				clickHandler();
				$('.slide#stage button').unbind().blur();
				window.scrollTo(0, 0);
				experiment.next();
			})

		}
	}
};

experiment.next();