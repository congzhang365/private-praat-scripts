## Modified by Cong Zhang
## Language and Brain Laboratory, University of Oxford
## Last updated 4 June 2016
##
## This script goes through sound and TextGrid files in a directory,
## opens each pair of Sound and TextGrid, gets 
## 		1.Filename	
## 		2.Segment label	
## 		3.StartTime
## 		4.EndTime 
## and calculates
## 		5. Duration(s)
## 		6. Maximum pitch (Hz)	
##		7. maxTime	[the time when the pitch is max]
##		8. Minimum pitch (Hz)	
## 		9. minTime	[the time when the pitch is min]
## 		10. Mean pitch(Hz)	
## 		11. Pitch Range(Hz)
## of each labeled interval(according to tier number), and saves results to a text file.
##
## This script is edited based on the script
## 'collect_pitch_data_from_files.praat' by Mietta Lennes.
## This script is distributed under the GNU General Public License.



form Analyze duration and pitches from labeled segments in files
	comment Directory of sound files
	text sound_directory C:\Users\rolin\OneDrive\Oxford Research\Thesis related\data\2017\!calling contour\best of zi\all\
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files
	text textGrid_directory C:\Users\rolin\OneDrive\Oxford Research\Thesis related\data\2017\!calling contour\best of zi\all\
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultfile C:\Users\rolin\OneDrive\Oxford Research\Thesis related\data\2017\!calling contour\best of zi\all\pitches.txt
	comment Which interval tier do you want to analyze?
	integer Tier 3
	comment Which point tier do you want to analyze?
	integer poitier 5
	comment Pitch analysis parameters
	positive Time_step 0.01
	positive Minimum_pitch(Hz) 75
	positive Maximum_pitch_(Hz) 550
	
endform

# Here, you make a listing of all the sound files in a directory.
# The example gets file names ending with ".wav" from D:\tmp\
strings = Create Strings as file list: "list", sound_directory$ + "*.wav"
numberOfFiles = Get number of strings

# Check if the result file exists:
if fileReadable (resultfile$)
	pause The result file 'resultfile$' already exists! Do you want to overwrite it?
	filedelete 'resultfile$'
endif

# Write a row with column titles to the result file:
# (remember to edit this if you add or change the analyses!)
writeFile:"'resultfile$'"
writeFileLine:"'resultfile$'","Filename",tab$,"Segment Label",tab$,"StartTime",tab$,"EndTime",tab$,"Duration(s)",tab$,"Maximum pitch (Hz)",tab$,"maxTime",tab$,"Minimum pitch (Hz)",tab$,"minTime",tab$,"Mean pitch(Hz)",tab$,"Pitch Range(Hz)",tab$,"Secondary F0 Label - A",tab$,"Secondary F0 (Hz) - A",tab$,"Secondary F0 Time - A",tab$,"Secondary F0 Label - B",tab$,"Secondary F0 (Hz) - B",tab$,"Secondary F0 Time - B"



# Go through all the sound files, one by one:
for ifile to numberOfFiles
	selectObject: strings
	filename$ = Get string: ifile
	# A sound file is opened from the listing:
	Read from file... 'sound_directory$''filename$'
	# Starting from here, you can add everything that should be 
	# repeated for every sound file that was opened:
	soundname$ = selected$ ("Sound", 1)
	To Pitch... time_step minimum_pitch maximum_pitch
	# Open a TextGrid by the same name:
	Read from file... 'sound_directory$''soundname$'.TextGrid
	sec_poi_tier = poitier + 1
	select TextGrid 'soundname$'
	pointnumber = Get number of points: sec_poi_tier
	if pointnumber = 0
		f0labelA$ = "NA"
		f0secA = 999999999
		f0secondtimeA = 999999999
		f0labelB$ = "NA"
		f0secB = 999999999
		f0secondtimeB = 999999999
	elsif pointnumber = 1
		select TextGrid 'soundname$'
		f0labelA$ = Get label of point... sec_poi_tier 1
		f0secondtimeA = Get time of point... sec_poi_tier 1
		select Pitch 'soundname$'
		f0secA = Get value at time: f0secondtimeA, "Hertz", "Linear"
		f0labelB$ = "NA"
		f0secB = 999999999
		f0secondtimeB = 999999999
	else
		select TextGrid 'soundname$'
		f0labelA$ = Get label of point... sec_poi_tier 1
		f0labelB$ = Get label of point... sec_poi_tier 1
		f0secondtimeA = Get time of point... sec_poi_tier 1
		f0secondtimeB = Get time of point... sec_poi_tier 1
		select Pitch 'soundname$'
		f0secA = Get value at time: f0secondtimeA, "Hertz", "Linear"
		f0secB = Get value at time: f0secondtimeB, "Hertz", "Linear"
	endif
	select TextGrid 'soundname$'
	numberOfIntervals = Get number of intervals... tier
	# Pass through all intervals in the selected tier:
	
		
	for i from 1 to numberOfIntervals
		select TextGrid 'soundname$'
		label$ = Get label of interval... tier i
		if label$ <> ""
			# if the interval has an unempty label, get its start and end, and duration:
			start = Get starting point... tier i
			end = Get end point... tier i
			duration = end - start
			# get pitch maximum, pitch minimum, time of pitch maximum, 
			# time of pitch minimum, mean pitch, and pitch range at that interval:
			select Pitch 'soundname$'
			pitchmax = Get maximum: start, end, "Hertz", "Parabolic"
			maxTime = Get time of maximum: start, end, "Hertz", "Parabolic"
			
			
			pitchmin = Get minimum: start, end, "Hertz", "Parabolic"
			minTime = Get time of minimum: start, end, "Hertz", "Parabolic"	
							
			pitchmean = Get mean: start, end, "Hertz"
			pitchrange = pitchmax - pitchmin
			appendFileLine: "'resultfile$'", soundname$,tab$,label$,tab$,start,tab$,end,tab$,duration,tab$,pitchmax,tab$,maxTime,tab$,pitchmin,tab$,minTime,tab$,pitchmean,tab$,pitchrange,tab$,f0labelA$,tab$,f0secA,tab$,f0secondtimeA,tab$,f0labelB$,tab$,f0secB,tab$,f0secondtimeB
		endif
	endfor
			# Save result to text file:
			#resultline$ = "'soundname$'	'label$'	'start'	'end'	'duration'	'pitchmax'	'maxTime'	'pitchmin'	'minTime'	'pitchmean'	'pitchrange'	'newline$'"


	# Remove the TextGrid object from the object list
	select TextGrid 'soundname$'
	Remove
	
	# Remove the temporary objects from the object list
	select Sound 'soundname$'
	plus Pitch 'soundname$'
	Remove
	select Strings list
	# and go on with the next sound file!
endfor

Remove
