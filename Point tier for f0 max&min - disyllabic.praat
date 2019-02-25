

form F0 point tier:
	comment Your working directory:
	sentence Directory C:\Users\rolin\OneDrive\Oxford Research\Thesis related\data\2017\!calling contour\best of ci\4\
	comment Only analyse the files containing...
	sentence Word 
	comment What sound file type would you like to analyse?
	sentence Filetype wav
	comment Which segment tier would you like to analyse?
	integer tier 4
	comment New point tier
	integer newtier 6
	comment What's the shape of the contour?
	comment ______________________________________________________________________________________________________________
	comment Save selected objects...
	sentence Save_to C:\Users\rolin\OneDrive\Oxford Research\Thesis related\data\2017\!calling contour\best of ci\4\point tier 4\

endform
#appendInfoLine:"-----",date$(),"-----"
Create Strings as file list... list 'directory$'*'Word$'*'filetype$'
pause Edit list?
number_of_files = Get number of strings
secondary_tier = newtier + 1
secondary_tier_name$ = "2ndf0"

for x from 1 to number_of_files
	select Strings list
	current_file$ = Get string... x
	Read from file... 'directory$''current_file$'
	object_name$ = selected$ ("Sound")
	Read from file... 'directory$''object_name$'.TextGrid
	plus Sound 'object_name$'
    #Edit
	##it "looks for a word without spaces after the first occurrence" of a word (in this script: SJ101_)
	a$ = extractWord$("'object_name$'", "ci")
	
	##this is to get the FIRST 4 characters from the string stored in variable a.
	tone$ = left$("'a$'",4)
	toneA$ = left$("'tone$'",2)
	toneB$ = right$("'tone$'",2)	
	
	select Sound 'object_name$'
	pitch_id = To Pitch: 0.0, 75.0, 550.0

	select TextGrid 'object_name$'
	#View & Edit
	Insert point tier: newtier, "f0"
	Insert point tier: secondary_tier, "'secondary_tier_name$'"
	
	n_intervals = Get number of intervals: tier
	label$ = Get label of interval: tier, 2
	
	if length(label$)
		start_interval = Get starting point: tier, 2
		end_interval   = Get end point: tier, 2
		
		selectObject:pitch_id
		minimum_f0 = Get time of minimum: start_interval, end_interval, "Hertz", "Parabolic"
		maximum_f0 = Get time of maximum: start_interval, end_interval, "Hertz", "Parabolic"
		
		if toneA$ = "T1" or toneA$ = "T2" 
			select TextGrid 'object_name$'
			nocheck Insert point: newtier, minimum_f0, "'label$'-"
			nocheck Insert point: newtier, maximum_f0, "'label$'+"
		elsif toneA$ = "T3"
			if maximum_f0 > minimum_f0
			second_max = Get time of maximum: start_interval, minimum_f0, "Hertz", "Parabolic"
			else maximum_f0 < minimum_f0
			second_max = Get time of maximum: minimum_f0, end_interval, "Hertz", "Parabolic"
			endif
			select TextGrid 'object_name$'
			nocheck Insert point: newtier, minimum_f0, "'label$'-"
			nocheck Insert point: newtier, maximum_f0, "'label$'+"
			nocheck Insert point: secondary_tier, second_max, "'label$'[2]+"
		else toneA$ = "T4"
			if maximum_f0 < minimum_f0
			second_min = Get time of minimum: start_interval, maximum_f0, "Hertz", "Parabolic"
			else maximum_f0 > minimum_f0
			second_min = Get time of minimum: maximum_f0, end_interval, "Hertz", "Parabolic"
			endif		
			select TextGrid 'object_name$'
			#appendInfoLine: "2nd -:",second_min, "maximum_f0:",maximum_f0,"minimum_f0",minimum_f0
			nocheck Insert point: newtier, minimum_f0, "'label$'-"
			nocheck Insert point: newtier, maximum_f0, "'label$'+"
			nocheck Insert point: secondary_tier, second_min, "'label$'[2]-"		
		endif
	endif

	n_intervals = Get number of intervals: tier
	label$ = Get label of interval: tier, 3
	if length(label$)
		start_interval = Get starting point: tier, 3
		end_interval   = Get end point: tier, 3
		
		selectObject:pitch_id
		minimum_f0 = Get time of minimum: start_interval, end_interval, "Hertz", "Parabolic"
		maximum_f0 = Get time of maximum: start_interval, end_interval, "Hertz", "Parabolic"
		
		if toneB$ = "T1" or toneB$ = "T2" or toneB$ = "T0"
			select TextGrid 'object_name$'
			nocheck Insert point: newtier, minimum_f0, "'label$'-"
			nocheck Insert point: newtier, maximum_f0, "'label$'+"
		elsif toneB$ = "T3"
			if maximum_f0 > minimum_f0
			second_max = Get time of maximum: start_interval, minimum_f0, "Hertz", "Parabolic"
			else maximum_f0 < minimum_f0
			second_max = Get time of maximum: minimum_f0, end_interval, "Hertz", "Parabolic"
			endif
			select TextGrid 'object_name$'
			nocheck Insert point: newtier, minimum_f0, "'label$'-"
			nocheck Insert point: newtier, maximum_f0, "'label$'+"
			nocheck Insert point: secondary_tier, second_max, "'label$'[2]+"
		else toneB$ = "T4"
			if maximum_f0 < minimum_f0
			second_min = Get time of minimum: start_interval, maximum_f0, "Hertz", "Parabolic"
			else maximum_f0 > minimum_f0
			second_min = Get time of minimum: maximum_f0, end_interval, "Hertz", "Parabolic"
			endif		
			select TextGrid 'object_name$'
			#appendInfoLine: "2nd -:",second_min, "maximum_f0:",maximum_f0,"minimum_f0",minimum_f0
			nocheck Insert point: newtier, minimum_f0, "'label$'-"
			nocheck Insert point: newtier, maximum_f0, "'label$'+"
			nocheck Insert point: secondary_tier, second_min, "'label$'[2]-"		
		endif
	endif
		
select TextGrid 'object_name$'
Save as text file... 'Save_to$''object_name$'.TextGrid
#pause File saved. Next one?
selectObject: pitch_id
plus TextGrid 'object_name$'
plus Sound 'object_name$'
Remove
endfor
