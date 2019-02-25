form Add new point tier of f0max and f0min for labeled segments in files:
	comment Leave the directory path empty if you want to use the current directory.
	text directory C:\Users\
	comment Which tier do you want to analyze?
	integer tier 2
	comment ______________________________________________________________________________________________________________
	comment Pitch analysis parameters
	positive Time_step 0.01
	positive Minimum_pitch_(Hz) 75
	positive Maximum_pitch_(Hz) 800
	comment ______________________________________________________________________________________________________________
	comment New point tier
	integer newtier 4
	comment ______________________________________________________________________________________________________________
	comment Save selected objects...
	sentence Save_to C:\Users\point tier\
	comment Leave empty for GUI selector
	sentence Pad_name_with 
	comment Name padding used to create unique names
	boolean Overwrite no
	boolean Quiet yes
endform

# Create a list for file names of sounds
strings = Create Strings as file list: "wavlist", directory$ + "*.wav"
numberOfFiles = Get number of strings

# Go through all the sound files, one by one:
for ifile to numberOfFiles
	selectObject: strings
	filename$ = Get string: ifile
	# A sound file is opened from the listing:
	Read from file... 'directory$''filename$'
	# Starting from here, you can add everything that should be 
	# repeated for every sound file that was opened:
	soundname$ = selected$ ("Sound", 1)
	# Get pitches
	pitch_id = To Pitch... time_step minimum_pitch maximum_pitch
endfor

# Create a list for file names of Textgrids
strings = Create Strings as file list: "list", directory$ + "*.TextGrid"
number_of_files = Get number of strings
for i_file to number_of_files
	select Strings list
	grid_file_name$ = Get string... i_file
	Read from file... 'directory$''grid_file_name$'
	base_name$ = selected$("TextGrid")
	print Handling 'base_name$' 

# try to open .wav and .nsp files for this TextGrid

	ext1$ = ".wav"
	sound_file_name$ = directory$+base_name$+ext1$
	
# next line not really necessary - just to prevent errors if we cut-n-paste this part into another script where things might be different
	select TextGrid 'base_name$'

	tier_one_is_interval = Is interval tier... tier
	if  tier_one_is_interval = 1

# read in the sound file
		Read from file... 'sound_file_name$'

# Use the TextGrid to find all labeled segments
		select TextGrid 'base_name$'
		nr_segments = Get number of intervals... tier
		for i to nr_segments
			select TextGrid 'base_name$'
			interval_label$ = Get label of interval... tier i
			if interval_label$ <> ""

# Compute the formants at the center and +/- one step_rate around it and perform a median smoothing.
				for i from 1 to nr_segments
				  label$ = Get label of interval: tier, i
				  if length(label$)
					start_interval = Get starting point: tier, i
					end_interval   = Get end point: tier, i
					selectObject:pitch_id
					minimum_f0 = Get time of minimum: start_interval, end_interval, "Hertz", "Parabolic"
					maximum_f0 = Get time of maximum: start_interval, end_interval, "Hertz", "Parabolic"
					select TextGrid 'base_name$'
					Insert point tier: newtier, "f0"
					nocheck Insert point: newtier, minimum_f0, "-"
					nocheck Insert point: newtier, maximum_f0, "+"
				  endif
				endfor
			endif
		endfor
	endif
endfor


pause select the new textgrids

verbose = if quiet then 0 else 1 fi
cleared_info = 0

@checkDirectory(save_to$, "Save objects to...")
directory$ = checkDirectory.name$

# Save selection
selected_objects = numberOfSelected()
for i to selected_objects
  my_object[i] = selected(i)
endfor

# Create Table to store object data
object_data = Create Table with column names: "objects", selected_objects,
  ..."id type name extension num"

# Populate Table with data
for i to selected_objects
  selectObject(my_object[i])
  type$ = extractWord$(selected$(), "")
  name$ = selected$(type$)

  if type$ = "Sound"
    extension$ = ".wav"
  elsif type$ != "LongSound"
    extension$ = "." + type$
  endif
    
  selectObject(object_data)
  Set numeric value: i, "id",        my_object[i]
  Set string value:  i, "type",      type$
  Set string value:  i, "name",      name$
  Set string value:  i, "extension", extension$
  Set numeric value: i, "num",       number(name$)
endfor

# Sort Table rows, 
Sort rows: "num name"

# create name conversion table
conversion_table = Collapse rows: "name type", "", "", "", "", ""
Append column: "new_name"

if !overwrite
  n = Get number of rows
  for i to n
    name$ = Get value: i, "name"
    type$ = Get value: i, "type"

    pad$ = ""
    repeat
      file_name$ = name$ + pad$ + extension$
      full_name$ = directory$ + "/" + file_name$
      
      pad$ = pad$ + pad_name_with$
      new_name$ = file_name$ - extension$
      converted = Search column: "new_name", new_name$
    until !(fileReadable(full_name$) or converted)

    if name$ != new_name$
      Set string value: i, "new_name", new_name$
    else
      Set string value: i, "name", ""
    endif
  endfor
endif

# Create saved names hash
used_names = Create Table with column names: "used_names", 0, "name n"

saved_files = 0

# Loop through objects, for saving
for i to selected_objects
  selectObject(object_data)
  id         = Get value: i, "id"
  type$      = Get value: i, "type"
  name$      = Get value: i, "name"
  extension$ = Get value: i, "extension"

  if !overwrite
    selectObject(conversion_table)
    converted = Search column: "name", name$
    if converted
      converted_name$ = Get value: converted, "new_name"
      name$ = converted_name$
    endif
  endif
    
  selectObject(used_names)
  used = Search column: "name", name$
  counter = 0
  if used
    counter = Get value: used, "n"
    Set numeric value: used, "n", counter+1
  else
    Append row
    r = Get number of rows
    Set numeric value: r, "n", 1
    Set string value: r, "name", name$
  endif
  
  counter$ = string$(counter)
  counter$ = if counter$ = "0" then "" else counter$ fi
  
  selectObject(id)

  file_name$ = name$ + counter$ + extension$
  full_name$ = directory$ + "/" + file_name$
  if type$ = "Sound"
    Save as WAV file: full_name$
  elsif type$ != "LongSound"
    Save as text file: full_name$
  endif

  if verbose
    if !cleared_info
      clearinfo
      cleared_info = 1
    endif
    appendInfoLine("Saved ", selected$(type$), " as ", full_name$)
  endif
  
endfor

removeObject(object_data, conversion_table, used_names)

if selected_objects
  selectObject(my_object[1])
  for i from 2 to selected_objects
    plusObject(my_object[i])
  endfor
endif

procedure checkDirectory (.name$, .label$)
  if .name$ = "" and praatVersion >= 5204
    .name$ = chooseDirectory$(.label$)
  endif
  if .name$ = ""
    exit
  endif
endproc

