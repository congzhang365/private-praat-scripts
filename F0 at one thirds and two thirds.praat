# Form to input some information.
form Enter the following:
	comment Which tier should be analysed?
	integer Which_tier: 4
	comment (do not add trailing slash to your paths)
	sentence Input_folder: C:\your\path\to\input_files
	sentence Output_folder: C:\your\path\to\save\output
endform

# Creating lists of WAV and TextGrid files contained in your
# input_folder. The script assumes that your WAVS and TextGrids have
# the same name (but different extensions: ".TextGrid" and ".wav").
tgd_list_ID = Create Strings as file list: "tgd_list", input_folder$ + "\*.TextGrid"
wav_list_ID = Create Strings as file list: "wav_list", input_folder$ + "\*.wav"
total_n_items = Get number of strings

# Creating table to save results later.
table_ID = Create Table with column names: "data_table", 0, "file tier 
	...interval label start end pitch_a pitch_b pitch_c int_a int_b int_c"

# For loop to iterate through files (pairs of WAV + TextGrid).
row_counter = 0
for i to total_n_items
	
	# Obtaining WAV name and opening file from input folder.
	selectObject: wav_list_ID
	current_wav_name$ = Get string: i
	current_wav_ID = Read from file: current_wav_name$

	# Creating Pitch object from WAV file (default values).
	current_pitch_ID = To Pitch: 0.0, 75, 600

	# Creating Intensity object from WAV file (default values).
	selectObject: current_wav_ID
	current_intensity_ID = To Intensity: 100, 0.0, "yes"

	# Obtaining TextGrid name and opening file from input folder. Also
	# querying how many intervals are present in target tier.
	selectObject: tgd_list_ID
	current_tgd_name$ = Get string: i
	current_tgd_ID = Read from file: current_tgd_name$
	total_n_intervals = Get number of intervals: which_tier

	# Fruity loop to iterate through each interval of target tier.
	for x to total_n_intervals
		
		# Obtaining the label of each interval and calculating its
		# length.
		selectObject: current_tgd_ID
		current_label$ = Get label of interval: which_tier, x
		length_label = length (current_label$)
		
		# Conditional jump: only labels of n characters larger than 0
		# will be further analysed.
		if length_label > 0
			
			# Querying duration points from labelled interval and
			# calculating three points of interest.
			start = Get start point: which_tier, x
			end = Get end point: which_tier, x
			point_a_1st_third = ((end - start) / 3) + start
			point_b_middle = ((end - start) / 2) + start
			point_c_2nd_third =  (((end - start) / 3) * 2) + start
			
			# Querying the Pitch object to obtain desired measurements
			# in three target points.
			selectObject: current_pitch_ID
			pitch_a = Get value at time: point_a_1st_third, "Hertz", "Linear"
			pitch_b = Get value at time: point_b_middle, "Hertz", "Linear"
			pitch_c = Get value at time: point_c_2nd_third, "Hertz", "Linear"

			# Querying Intensity object to obtain measurements in
			# three target points.
			selectObject: current_intensity_ID
			intensity_a = Get value at time: point_a_1st_third, "Cubic"
			intensity_b = Get value at time: point_b_middle, "Cubic"
			intensity_c = Get value at time: point_c_2nd_third, "Cubic"

			# Modifying Table object to save results.
			selectObject: table_ID
			Append row
			row_counter += 1
			Set string value: row_counter, "file", current_wav_name$
			Set numeric value: row_counter, "tier", which_tier
			Set numeric value: row_counter, "interval", x
			Set string value: row_counter, "label", current_label$
			Set numeric value: row_counter, "start", start
			Set numeric value: row_counter, "end", end
			Set numeric value: row_counter, "pitch_a", pitch_a
			Set numeric value: row_counter, "pitch_b", pitch_b
			Set numeric value: row_counter, "pitch_c", pitch_c
			Set numeric value: row_counter, "int_a", intensity_a
			Set numeric value: row_counter, "int_b", intensity_b
			Set numeric value: row_counter, "int_c", intensity_c

		endif
	endfor

	# Selecting all objects that won't be used any longer and remove
	# them from the Objects window.
	selectObject: current_wav_ID
	plusObject: current_tgd_ID
	plusObject: current_pitch_ID
	plusObject: current_intensity_ID
	Remove

endfor

# Selecting Table object in order to save it as CSV file in
# output_folder destination.
selectObject: table_ID
Save as comma-separated file: output_folder$ + "\results.csv"
