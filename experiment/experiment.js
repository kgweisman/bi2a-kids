// choose condition randomly
var chosenCondition = randomElementNR(swatchSets);

// display random swatch on stage slide
// $('.slide#stage img').attr("src", randomElementNR(chosenCondition.swatchOrder).imageSource);

// create experiment object
var experiment = {
	subid: "",
	trials: chosenCondition.swatchOrder.slice(),
	bonusTrials: [chosenCondition.swatchOrder[0], chosenCondition.swatchOrder[1],chosenCondition.swatchOrder[5], chosenCondition.swatchOrder[6], chosenCondition.swatchOrder[10], chosenCondition.swatchOrder[11]],
	questionTypes: ["Do you think this one can think?", "Do you think this one has feelings?", "Do you think this one can sense things nearby?", "Do you think this can feel happy?", "Do you think this one can feel hungry?", "Do you think this one can feel pain?"],
	dateOfTest: new Date(),
	condition: chosenCondition.condition.slice(),
	trialData: [],

	// what happens after completing all trials
	end: function() {

		// show ending slide	
		showSlide("finished");

		// export data to csv
		var data = experiment.trialData;
 
		function DownloadJSON2CSV(objArray) { // code source: http://www.zachhunter.com/2010/11/download-json-to-csv-using-javascript/
		    // get trial-level info
		    var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;

		    // add subject-level info
		    for (trial in objArray) {
		    	objArray[trial].subid = experiment.subid;
		    	objArray[trial].dateOfTest = experiment.dateOfTest;
		    	objArray[trial].condition = experiment.condition;
		    };

		    // add headers in a hacky way
		    objArray.unshift({
		    	phase: "phase",
		    	question: "question",
		    	trialNum: "trialNum",
		    	swatch: "swatch",
		    	response: "response",
		    	responseCoded: "responseCoded",
		    	rt: "rt",
		    	subid: "subid",
		    	dateOfTest: "dateOfTest",
		    	condition: "condition"
		    });

		    // convert to csv
		    var str = '';
		     
		    for (var i = 0; i < array.length; i++) {
		        var line = '';
		        for (var index in array[i]) {
		            if(line != '') line += ','
		         
		            line += array[i][index];
		        }
		 
		        str += line + '\r\n';
		    }
		 
		    if (navigator.appName != 'Microsoft Internet Explorer')
		    {
		        window.open('data:text/csv;charset=utf-8,' + escape(str));
		    }
		    else
		    {
		        var popup = window.open('','csv','');
		        popup.document.body.innerHTML = '<pre>' + str + '</pre>';
		    }          
		}
		DownloadJSON2CSV(data);
	},

	// what happens when participant plays bonus rounds
	bonus: function() {

		// set up how to play a bonus trial
		function playBonus() {

			// create place to store data for this bonus trial
			var data = {
				phase: "bonus",
				question: "",
				trialNum: 18 - experiment.bonusTrials.length,
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

			// display randomly selected question
			var chosenQuestion = randomElementNR(experiment.questionTypes);
			data.question = chosenQuestion.slice();
			$('.slide#stage #question').text(chosenQuestion);

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

		} else if (experiment.bonusTrials.length === 6) {

			$(".slide").hide();

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
				phase: "study",
				question: "Do you think this one is an animal?",
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

// start!

showSlide("start");

$('.slide#start button').click(function() { 
	// record subid
	experiment.subid = $('input#subid').val();

	// advance to first trial
	experiment.next();
});
