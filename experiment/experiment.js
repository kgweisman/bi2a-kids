// get date
var date = new Date();

// set up condition variable
var chosenCondition;

// create experiment object
var experiment = {
	subid: "",
	dateOfBirth: "",
	// trials: chosenCondition.swatchOrder.slice(),
	trials: [],
	// bonusTrials: [chosenCondition.swatchOrder[0], chosenCondition.swatchOrder[1],chosenCondition.swatchOrder[5], chosenCondition.swatchOrder[6], chosenCondition.swatchOrder[10], chosenCondition.swatchOrder[11]],
	bonusTrials: [],
	practiceTrials: [],
	questionTypes: ["Do you think this one can think?", "Do you think this one has feelings?", "Do you think this one can sense things close by?", "Do you think this one can feel happy?", "Do you think this one can feel hungry?", "Do you think this one can feel pain?", "Do you think this one can remember things?", "Do you think this one can hear?"],
	dateOfTest: date.getMonth()+1+"/"+date.getDate()+"/"+date.getFullYear(),
	age: "",
	timeOfTest: date.getHours()+":"+date.getMinutes(),
	// condition: chosenCondition.condition.slice(),
	condition: "",
	englishExposure: "",
	gender: "",
	trialComments: "",
	sessionComments: "",
	trialData: [],

	// what happens after completing all trials
	end: function() {

		// show ending slide	
		showSlide("finished");
		
		$('.slide#finished button').click(function() { 
			// reload html to return to start slide
			location.reload();
		});

		// export data to csv
		var data = experiment.trialData;
 
		function DownloadJSON2CSV(objArray) { // code source: http://www.zachhunter.com/2010/11/download-json-to-csv-using-javascript/
		    // get trial-level info
		    var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;

		    // add subject-level info
		    for (trial in objArray) {
		    	objArray[trial].subid = experiment.subid;
		    	objArray[trial].dateOfBirth = experiment.dateOfBirth;
		    	objArray[trial].dateOfTest = experiment.dateOfTest;
		    	objArray[trial].age = experiment.age;
		    	objArray[trial].timeOfTest = experiment.timeOfTest;	    	
		    	objArray[trial].condition = experiment.condition;
		    	objArray[trial].englishExposure = experiment.englishExposure;
		    	objArray[trial].gender = experiment.gender;
		    	objArray[trial].trialComments = experiment.trialComments;
		    	objArray[trial].sessionComments = experiment.sessionComments;
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
		    	dateOfBirth: "dateOfBirth",
		    	dateOfTest: "dateOfTest",
		    	age: "age",
		    	timeOfTest: "timeOfTest",
		    	condition: "condition",
		    	englishExposure: "englishExposure",
		    	gender: "gender",
		    	trialComments: "trialComments",
		    	sessionComments: "sessionComments"
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
				trialNum: 21 - experiment.bonusTrials.length,
				swatch: "",
				response: "",
				responseCoded: "",
				rt: NaN
			}

			// display progress bar
			var percentComplete = (data.trialNum-13)/8 * 100;
			$('#stage .progress-bar').attr("aria-valuenow", percentComplete.toString());
			$('#stage .progress-bar').css("width", percentComplete.toString()+"%");

			// restyle progress bar
			$('#stage .progress').css("background-color", "rgba(170, 120, 240, .1)");
			$('#stage .progress-bar').css("background-color", "rgba(170, 120, 240, 1)");

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

			$('.slide#stage button[type="submit"]').click(function() {
				// record response
				data.response = $(this).attr('id');
				data.responseCoded = parseFloat($(this).attr('value'));

				// end trial
				clickHandler();
				$('.slide#stage button[type="submit"]').unbind().blur();
				window.scrollTo(0, 0);
				experiment.next();
			});
		};

		if (experiment.bonusTrials.length === 0) {

			// end study session
			experiment.end();

		} else if (experiment.bonusTrials.length === 8) {

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

	// what happens when participant does practice trials
	practice: function() {

		// set up how to play a bonus trial
		function playPractice() {

			// create place to store data for this bonus trial
			var data = {
				phase: "practice",
				question: "NA",
				trialNum: 1 - experiment.practiceTrials.length,
				swatch: "",
				response: "",
				responseCoded: "",
				rt: NaN
			}

			// // display progress bar
			// var percentComplete = (data.trialNum-1)/15 * 100;
			// $('#practice .progress-bar').attr("aria-valuenow", percentComplete.toString());
			// $('#practice .progress-bar').css("width", percentComplete.toString()+"%");

			// display next image
			var chosenSwatch = experiment.practiceTrials.shift();
			data.swatch = chosenSwatch.swatchName;
			$('.slide#practice img').attr("src", chosenSwatch.imageSource);

			// display text
			$('.slide#practice #question').text(chosenSwatch.questionText);

			// show trial
			showSlide("practice");

			// hide all buttons except for "next"
			$('.slide#practice button[type="submit"]').hide();
			$('.slide#practice button#skip').show().text("next");

			// record response and rt
			var startTime = (new Date()).getTime();

			var clickHandler = function(event) {
				var endTime = (new Date()).getTime();
				data.rt = endTime - startTime;
				experiment.trialData.push(data);
			};

			$('.slide#practice button[type="submit"]').click(function() {
				// record response
				data.response = $(this).attr('id');
				data.responseCoded = parseFloat($(this).attr('value'));

				// end trial
				clickHandler();
				$('.slide#practice button[type="submit"]').unbind().blur();
				window.scrollTo(0, 0);
				experiment.practice();
			});
		};

		if (experiment.practiceTrials.length === 0) {

			// advance to study instructions
			showSlide("instructions");

		} else {

			// do practice trials
			playPractice();
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
				trialNum: 13 - this.trials.length,
				swatch: "",
				response: "",
				responseCoded: NaN,
				rt: NaN
			};

			// display progress bar
			var percentComplete = (data.trialNum-1)/12 * 100;
			$('#stage .progress-bar').attr("aria-valuenow", percentComplete.toString());
			$('#stage .progress-bar').css("width", percentComplete.toString()+"%");

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

			$('.slide#stage button[type="submit"]').click(function() {
				// record response
				data.response = $(this).attr('id');
				data.responseCoded = parseFloat($(this).attr('value'));

				// end trial
				clickHandler();
				$('.slide#stage button[type="submit"]').unbind().blur();
				window.scrollTo(0, 0);
				experiment.next();
			});
		}
	}
};

// start!
showSlide("start");

$('.slide#start button').click(function() { 

	// if no subid, prevent progress
	if($('input#subid').val() === "") {
		window.alert("Please enter a subid.");

	// if subid has been used before, prevent progress
	} else if(subidsMasterList.lastIndexOf($('input#subid').val()) !== -1) {
		window.alert("This subid has been used before. Please enter a new subid.")

	// if subid provided is new, proceed!
	} else {
		// record subid in tracker file
		subidsMasterList.push($('input#subid').val());

		// record subid in experiment object
		experiment.subid = $('input#subid').val();

		// record condition selection
		switch($('input#condition').val()) {
			case "1":
				chosenCondition = swatchSets[0];
				break;
			case "2":
				chosenCondition = swatchSets[1];
				break;
			case "3":
				chosenCondition = swatchSets[2];
				break;
			case "4":
				chosenCondition = swatchSets[3];
				break;
			case "":
				chosenCondition = randomElementNR(swatchSets);
				break;
			default:
				window.alert("Enter a valid condition number (1, 2, 3, or 4), or leave blank for random assignment.");
				break;
	};

	// set parameters of this session
	experiment.practiceTrials = swatchSetPractice.slice();
	experiment.trials = chosenCondition.swatchOrder.slice();
	experiment.bonusTrials = swatchSetBonus;
	experiment.condition = chosenCondition.condition.slice();

	// record dob if entered
	experiment.dateOfBirth = $('input#dob').val();

	// advance to practice slides
	showSlide("camera");
	}
});

// advance to study from instructions
$('.slide#camera button').click(function() { 
	// go to end
	experiment.practice();
});

// advance to study from instructions
$('.slide#instructions button').click(function() { 
	// go to end
	experiment.next();
});

// bail out if needed
$('button[type="end"]').click(function() { 
	// go to end
	experiment.end();
});
