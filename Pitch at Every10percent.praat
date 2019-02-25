form Analyze pitches from labeled segments in files
	comment Directory of sound files
	text sound_directory C:\Users\
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files
	text textGrid_directory C:\Users\
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultfile C:\Users\10percent.txt
	comment Which tier do you want to analyze?
	integer Tier 1
	comment Pitch analysis parameters
	positive Time_step 0.01
	positive Minimum_pitch_(Hz) 75
	positive Maximum_pitch_(Hz) 800
	comment Subject name
	text subject_name
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
titleline$ = "Filename	Segment label	sub	StartTime	EndTime	pitch_0%	pitch_10%	pitch_20%	pitch_30%	pitch_40%	pitch_50%	pitch_60%	pitch_70%	pitch_80%	pitch_90%	pitch_100%	'newline$'"
fileappend "'resultfile$'" 'titleline$'

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
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
		numberOfIntervals = Get number of intervals... tier
		# Pass through all intervals in the selected tier:
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			if label$ <> ""
				# if the interval has an unempty label, get its start and end, and duration:
				start = Get starting point... tier interval
				end = Get end point... tier interval
				point_o_0 = start
				point_a_1st = ((end - start) * 0.1) + start
				point_b_2nd = ((end - start) * 0.2) + start
				point_c_3rd = ((end - start) * 0.3) + start
				point_d_4th = ((end - start) * 0.4) + start
				point_e_5th = ((end - start) * 0.5) + start
				point_f_6th = ((end - start) * 0.6) + start
				point_g_7th = ((end - start) * 0.7) + start
				point_h_8th = ((end - start) * 0.8) + start
				point_i_9th = ((end - start) * 0.9) + start
				point_j_10th = end
				# get pitch maximum, pitch minimum, time of pitch maximum, 
				# time of pitch minimum, mean pitch, and pitch range at that interval:
				select Pitch 'soundname$'
				pitch_o = Get value at time: point_o_0, "Hertz", "Linear"
				pitch_a = Get value at time: point_a_1st, "Hertz", "Linear"
				pitch_b = Get value at time: point_b_2nd, "Hertz", "Linear"
				pitch_c = Get value at time: point_c_3rd, "Hertz", "Linear"
				pitch_d = Get value at time: point_d_4th, "Hertz", "Linear"
				pitch_e = Get value at time: point_e_5th, "Hertz", "Linear"
				pitch_f = Get value at time: point_f_6th, "Hertz", "Linear"
				pitch_g = Get value at time: point_g_7th, "Hertz", "Linear"
				pitch_h = Get value at time: point_h_8th, "Hertz", "Linear"
				pitch_i = Get value at time: point_i_9th, "Hertz", "Linear"
				pitch_j = Get value at time: point_j_10th, "Hertz", "Linear"
				# Save result to text file:
				resultline$ = "'soundname$'	'label$'	'subject_name$'	'start'	'end'	'pitch_o'	'pitch_a'	'pitch_b'	'pitch_c'	'pitch_d'	'pitch_e'	'pitch_f'	'pitch_g'	'pitch_h'	'pitch_i'	'pitch_j'	'newline$'"
				fileappend "'resultfile$'" 'resultline$'
				select TextGrid 'soundname$'
			endif
		endfor

		# Remove the TextGrid object from the object list
		select TextGrid 'soundname$'
		Remove
	endif
	# Remove the temporary objects from the object list
	select Sound 'soundname$'
	plus Pitch 'soundname$'
	Remove
	select Strings list
	# and go on with the next sound file!
endfor

Remove