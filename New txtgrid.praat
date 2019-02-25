soundname$ = selected$ ("LongSound")
To TextGrid: "sentence word phoneme pinyin", ""

if fileReadable ("'folder$''soundname$'.TextGrid")
	pause The file 'folder$''soundname$'.TextGrid already exists. Do you want to overwrite it?
endif

select TextGrid 'soundname$'
Write to text file... 'soundname$'.TextGrid

echo Ready! The TextGrid file was saved as 'folder$''soundname$'.TextGrid.
