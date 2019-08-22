## View sound file and TextGrid together

## Only for viewing the files. It doesn't edit or modify the original file.


## Written by Cong Zhang
## Language and Brain Laboratory, University of Oxford
## 22 Oct 2017. Last updated 22 Aug 2019.

form Enter directory and search string
	sentence Directory /Users/
	sentence Word
	sentence Filetype wav
endform

Create Strings as file list... list 'directory$'*'Word$'*'filetype$'
pause Edit string?
number_of_files = Get number of strings
for x from 1 to number_of_files
     select Strings list
     current_file$ = Get string... x
     Read from file... 'directory$''current_file$'
     object_name$ = selected$ ("Sound")
     Read from file... 'directory$''object_name$'.TextGrid
     plus Sound 'object_name$'
     Edit
     pause  Click Continue after you're done. Changes WON'T be saved. 
     select all
     minus Strings list
     Remove
endfor

select Strings list
Remove