## View sound file and TextGrid together

## Choose your sound files and open their corresponding textgrid files in another folder.


## Cong Zhang
## 22 Aug 2019

form Enter directory and search string
	comment Path to your wav files:
    sentence wav_dir C:\dir1\
    comment Path to the textgrid files:
    sentence tg_dir C:\dir2\
    comment Specify the word in the file name of your chosen wav file. Leave blank to process all.
	sentence Word
    comment Change the file type if you have other audio types
	sentence Filetype wav
    comment Do you want to save your changes?
    boolean save_file 0
endform

Create Strings as file list... list 'wav_dir$'*'Word$'*'filetype$'
pause Edit list. 'Remove' any files that do not have matching textgrid files in the chosen folder.
number_of_files = Get number of strings
for x from 1 to number_of_files
     select Strings list
     current_file$ = Get string... x
     Read from file... 'wav_dir$''current_file$'
     object_name$ = selected$ ("Sound")
     tg_name$ = "'tg_dir$''object_name$'.TextGrid"
     if fileReadable (tg_name$)
        Read from file... 'tg_name$'
     else
        appendInfoLine: "!!ATTENTION!!","'tg_name$'", " cannot be found."
     endif
     plus Sound 'object_name$'
     Edit
     pause  Changes WON'T be saved unless you have chosen to save your files. 
     if save_file = 1
        minus Sound 'object_name$'
        Write to text file... 'directory$''object_name$'.TextGrid
     endif
     select all
     minus Strings list
     Remove
endfor

select Strings list
Remove