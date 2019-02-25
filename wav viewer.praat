## text grid reviewer.praat
## Originally created by the excellent Katherine Crosswhite
## Script modified by Mark Antoniou
## MARCS Auditory Laboratories C 2010

##  This script opens all the sound files in a given directory, plus
##  their associated textgrids so that you can review/change the
##  boundaries or labels.

form Enter directory and search string
# Be sure not to forget the slash (Windows: backslash, OSX: forward
# slash)  at the end of the directory name.
	sentence Directory D:\Rokid\pycharm\detection\ASR\recordings\
#  Leaving the "Word" field blank will open all sound files in a
#  directory. By specifying a Word, you can open only those files
#  that begin with a particular sequence of characters. For example,
#  you may wish to only open tokens whose filenames begin with ba.
	sentence Word
	sentence Filetype wav
	boolean loop_all 0
	sentence file_list D:\Rokid\pycharm\detection\ASR\comparison.txt
	boolean view_edit 1
endform


if loop_all = 1
	Create Strings as file list... list 'directory$'*'Word$'*'filetype$'
else 
	Read Strings from raw text file... 'file_list$'
	Rename: "list"
endif
pause edit strings?
number_of_files = Get number of strings
for x from 1 to number_of_files
     select Strings list
     current_file$ = Get string... x
     Read from file... 'directory$''current_file$'
     object_name$ = selected$ ("Sound")
     #Read from file... 'directory$''object_name$'.TextGrid
     #plus Sound 'object_name$'
	 if view_edit = 1
		Edit
	else
		Play
	 endif
     pause  Make any changes then click Continue. 
     #minus Sound 'object_name$'
     #Write to text file... 'directory$''object_name$'.TextGrid
     #select all
     #minus Strings list
     Remove
endfor

select Strings list
Remove
clearinfo
printline TextGrids have been reviewed for 'word$'.'filetype$' files in 
printline 'directory$'.
