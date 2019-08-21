## Cong Zhang
## 20 Aug 2019
##
## This script goes through sound and TextGrid files in a directory,
## opens each pair of Sound and TextGrid, gets 
## 		1.Filename	
## 		2.Segment label	
## 		3.Syllable label
##      4.Segment Duration(s) 
##      5.Syllable Duration(s)
##
## of each labeled interval(according to tier number), and saves results to a text file.

form Analyze duration and pitches from labeled segments in files
	comment Directory of sound files
	text sound_directory C:\Users\
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files
	text textGrid_directory C:\Users\
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultfile C:\Users\dur_result.txt
	comment Tier number of segments?
	integer tier_seg 1
    comment Tier number of syllables?
    integer tier_syl 2
    #comment pause file for some time after each file(in sec)?
    #integer pause_time 1
endform

#appendInfoLine:"------",date$(),"------"

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
titleline$ = "Filename	Segment_label	Syllable_label  Seg_Duration(s) Syl_Dur(s)  'newline$'"
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
	# Open a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
		numberOfIntervals = Get number of intervals: tier_seg
		# Pass through all intervals in the selected tier:
		for interval to numberOfIntervals
			seg_label$ = Get label of interval... tier_seg interval
			if seg_label$ <> ""
				# if the interval has an unempty label, get its start and end, and duration:
				seg_start = Get starting point... tier_seg interval
				seg_end = Get end point... tier_seg interval
				seg_duration = seg_end - seg_start
                # get the corresponding syllable info
                syl_int = Get interval at time: tier_syl, seg_start
                syllable_lab$ = Get label of interval: tier_syl, syl_int
                syl_start = Get starting point... tier_seg syl_int
				syl_end = Get end point... tier_seg interval
                syl_duration = syl_end - syl_start
                
				# Save result to text file:
				resultline$ = "'soundname$''tab$''seg_label$''tab$''syllable_lab$''tab$''seg_duration''tab$' 'syl_duration''tab$''newline$'"
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
	Remove
    writeInfoLine: soundname$, " has been processed.", numberOfFiles-ifile," files to go."
    #sleep (pause_time)
   	select Strings list
	# and go on with the next sound file!
endfor

Remove
