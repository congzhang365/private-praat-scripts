# This script goes through sound and TextGrid files in a directory,
# opens each pair of Sound and TextGrid, calculates the pitch maximum
# of each labeled interval, and saves results to a text file.
# To make some other or additional analyses, you can modify the script
# yourself... it should be reasonably well commented! ;)
#
# This script is distributed under the GNU General Public License.
# Copyright 4.7.2003 Mietta Lennes

form Analyze pitch maxima and minima from labeled segments in files
	comment Directory of sound files
	text sound_directory C:\Users\
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files
	text textGrid_directory C:\Users\
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultfilea C:\Users\pitch max.txt
	text resultfileb C:\Users\pitch min.txt
	comment Which tier do you want to analyze?
	sentence Tier Seg
	comment Pitch analysis parameters
	positive Time_step 0.01
	positive Minimum_pitch_(Hz) 75
	positive Maximum_pitch_(Hz) 800
endform

# Here, you make a listing of all the sound files in a directory.
# The example gets file names ending with ".wav" from C:\Users\

strings = Create Strings as file list: "list", sound_directory$ + "*.wav"
numberOfFiles = Get number of strings

# Check if the max result file exists:
if fileReadable (resultfilea$)
	pause The result file 'resultfilea$' already exists! Do you want to overwrite it?
	filedelete 'resultfilea$'
endif

#################
####write max####

# Write a row with column titles to the max result file:
# (remember to edit this if you add or change the analyses!)

titlelinea$ = "Filename	Segment label	Maximum pitch (Hz)	maxTime 'newline$'"
fileappend "'resultfilea$'" 'titlelinea$'

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
		# Find the tier number that has the label given in the form:
		call GetTier 'tier$' tier
		numberOfIntervals = Get number of intervals... tier
		# Pass through all intervals in the selected tier:
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			if label$ <> ""
				# if the interval has an unempty label, get its start and end:
				start = Get starting point... tier interval
				end = Get end point... tier interval
				# get the Pitch maximum at that interval
				select Pitch 'soundname$'
				pitchmax = Get maximum... start end Hertz Parabolic
				printline 'pitchmax'
				maxTime = Get time of maximum... start end Hertz Parabolic
				# Save result to text file:
				resultlinea$ = "'soundname$'	'label$'	'pitchmax'	'maxTime' 'newline$'"
				fileappend "'resultfilea$'" 'resultlinea$'
				select TextGrid 'soundname$'
			endif
		endfor
	endif
endfor

##########end max#########
##########################

#################
####write min####

# Check if the min result file exists:
if fileReadable (resultfileb$)
	pause The result file 'resultfileb$' already exists! Do you want to overwrite it?
	filedelete 'resultfileb$'
endif

# Write a row with column titles to the min result file:
# (remember to edit this if you add or change the analyses!)

titlelineb$ = "Filename	Segment label	Minimum pitch (Hz)	minTime 'newline$'"
fileappend "'resultfileb$'" 'titlelineb$'

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
		# Find the tier number that has the label given in the form:
		call GetTier 'tier$' tier
		numberOfIntervals = Get number of intervals... tier
		# Pass through all intervals in the selected tier:
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			if label$ <> ""
				# if the interval has an unempty label, get its start and end:
				start = Get starting point... tier interval
				end = Get end point... tier interval
				# get the Pitch minimum at that interval
				select Pitch 'soundname$'
				pitchmin = Get minimum... start end Hertz Parabolic
				printline 'pitchmin'
				minTime = Get time of minimum... start end Hertz Parabolic
				# Save result to text file:
				resultlineb$ = "'soundname$'	'label$'	'pitchmin'	'minTime' 'newline$'"
				fileappend "'resultfileb$'" 'resultlineb$'
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

##########end min#########
##########################


Remove


#-------------
# This procedure finds the number of a tier that has a given label.

procedure GetTier name$ variable$
        numberOfTiers = Get number of tiers
        itier = 1
        repeat
                tier$ = Get tier name... itier
                itier = itier + 1
        until tier$ = name$ or itier > numberOfTiers
        if tier$ <> name$
                'variable$' = 0
        else
                'variable$' = itier - 1
        endif

	if 'variable$' = 0
		exit The tier called 'name$' is missing from the file 'soundname$'!
	endif

endproc
