// choose condition randomly
var chosenCondition = randomElementNR(swatchSets);

// display random swatch on stage slide
// $('.slide#stage img').attr("src", randomElementNR(chosenCondition.swatchOrder).imageSource);

// create experiment object
var experiment = {
	trials: chosenCondition.swatchOrder.slice(),
	bonusTrials: [chosenCondition.swatchOrder[0], chosenCondition.swatchOrder[6], chosenCondition.swatchOrder[11]],
	dateOfTest: new Date(),
	condition: chosenCondition.condition.slice(),
	trialData: [],

	// what happens after completing all trials
	end: function() {
		showSlide("finished");
	},

	// what happens when participant plays bonus rounds
	bonus: function() {

		// set up how to play a bonus trial
		function playBonus() {

			// create place to store data for this bonus trial
			var data = {
				phase: "bonus",
				trialNum: 4 - experiment.bonusTrials.length,
				swatch: "",
				response: "",
				responseCoded: "",
				rt: NaN
			}

			// choose random image to display
			var chosenSwatch = randomElementNR(experiment.bonusTrials);
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
			});
		};

		if (experiment.bonusTrials.length === 0) {

			// end study session
			experiment.end();

		} else if (experiment.bonusTrials.length === 3) {

			// give option of bonus round
			var chooseBonus = window.confirm("Do you want to play a bonus round?");
			if (chooseBonus === true) {
				// if child says yes...
				playBonus();

			} else {
			// if child says no...

			experiment.end();
			}			

		} else {
			playBonus();
		}
	},

	// what happens when participant sees a new trial
	next: function() {
		if (this.trials.length === 0) {

			// move on to bonus round
			experiment.bonus();

		} else {

			// create place to store data for this trial
			var data = {
				phase: "animal",
				trialNum: (chosenCondition.swatchOrder.length + 1) - this.trials.length,
				swatch: "",
				response: "",
				responseCoded: NaN,
				rt: NaN
			};

			// choose random image to display
			var chosenSwatch = randomElementNR(this.trials);
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
			});
		}
	}
};

experiment.next();