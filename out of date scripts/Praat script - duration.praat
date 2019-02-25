##
#	This script computes the durations of (a) either all sounds files in a directory or (b) all labeled
#	segments of all wav-soundfiles in a directory.
#
#  	Version 1.0, Henning Reetz, 01-aug-2007
#		Version 1.1, Henning Reetz, ???; ???
#		Version 1.2, Henning Reetz, 13-jun-2009; only minor adjustments 
#
#	Tested with Praat 5.1.07
#
##

clearinfo

#
## 1) Inquire some parameters
## ! Note that 'form' may only be used once in a script!
#

form Formant parameters:
	comment Leave the directory path empty if you want to use the current directory.
	word directory
	word result_file Duration_all.txt
	comment __________________________________________________________________________________________________
	comment Which interval tiers should be measured?
!	optionmenu tier: 1
!		option Whole file
!		option Tier 1
!		option Tier 2
!		option Tier 3
!		option Tier 4
!		option Tier 5
	choice tier 2
		button Whole file
		button Tier 1
		button Tier 2
		button Tier 3
		button Tier 4
		button Tier 5
	comment __________________________________________________________________________________________________
	comment In case you selected a tier, do you want all intervals or only the labeled ones?
	choice interval_type 1
		button Only labeled intervals
		button all intervals
endform

# tier = 0 should mean whole file, otherwise tier number; the count in the list above is one too high
tier -= 1

#
## 2) delete any pre-existing result file and write a header line
#

result_file$ = directory$+result_file$
filedelete 'result_file$'

if tier = 0
	fileappend 'result_file$' File'tab$'Duration[ms]'newline$'
else
	fileappend 'result_file$' File'tab$'Label'tab$'Start[s]'tab$'Duration[ms]'newline$'
endif

#
## 3) Get file names from a directory
##	In case the whole file should be measured, look for all wav files. 
##	If durations of labels are required, search for TextGrid files only. 
#

# nr. of files that failed
nr_fails = 0					

# total nr. of segments of all files
tot_segments = 0

# create list of .wav if only whole files are needed and nr. textgrid files otherwise
if tier = 0
	Create Strings as file list...  file_list 'directory$'*.wav
else
	Create Strings as file list...  file_list 'directory$'*.TextGrid
endif
nr_files = Get number of strings

#
## 4) Go thru all files
#

for i_file to nr_files
	select Strings file_list
	file_name$ = Get string... i_file
	Read from file... 'directory$''file_name$'

# get length of one file
	if tier = 0
		base_name$ = selected$("Sound")
		duration = Get total duration
		duration *= 1000
		fileappend 'result_file$' 'base_name$''tab$''duration:3''newline$'
		Remove
		printline Handling 'base_name$' finished.

# get length of all segments of one textgrid
	else
		base_name$ = selected$("TextGrid")
		print Handling 'base_name$' 

# check whether the selected tier number is not too large and whether selected tier is an interval tier.
		max_tier = Get number of tiers
		tier_is_interval = 0
		if max_tier >= tier
			tier_is_interval = Is interval tier... tier
		endif

# next statement is only true if there is an interval tier under investigation
		if  tier_is_interval = 1

# Use the TextGrid to find all segments.
			nr_segments = Get number of intervals... tier
			nr_measured_segments = 0

# go thru all segments
			for i to nr_segments
				interval_label$ = Get label of interval... tier i
# measure length
				begin_segment = Get starting point... tier i
				end_segment   = Get end point...      tier i
				duration = (end_segment - begin_segment) * 1000

# report all intervals or only labeled intervals (whatever was selected in the form at the beginning)
				if (interval_type = 2) or (interval_label$ <> "") 
					nr_measured_segments += 1
					fileappend 'result_file$' 'base_name$''tab$''interval_label$''tab$''begin_segment:4''tab$''duration:3''newline$'
				endif						# all/only labeled intervals
			endfor						# going thru all intervals

# entertain user
			tot_segments += nr_measured_segments
			printline with 'nr_measured_segments' segments finished.

		else								# tier 1 is not an interval tier
			printline skipped since Tier 'tier$' is not an interval tier. 
			nr_fails += 1
		endif								# test whether tier 1 is an interval tier

# remove textgrid from object list
		Remove
	endif									# while file/segments handling
endfor									# going thru all files

# clean up

select Strings file_list
Remove

# inform user that we are done.
if tier = 0
	printline 'newline$''nr_files' files processed.
else
	nr_files -= nr_fails
	printline 'newline$''nr_files' files with a total of 'tot_segments' segments processed.
	if nr_fails <> 0
		printline 'nr_fails' files not processed since the selected tier 'tier' was not an interval tier.
	endif
endif
printline Results are written to 'directory$''result_file$'. 'newline$'Program completed.'newline$'
