# TITLE: 	MAUSMOOTH (Manual and AUtomatic SMOOTHing of f0 tracks)

# INPUT: 	given .wav (and potentially .Pitch) file(s)
# ELABORATION: 	plot the f0 contour(s) in (combinations of) the three following formats 
#		red dots: Praat-extracted f0 values;
#		silver dots: manually corrected f0 points;
#		black line: smoothed and interpolated f0 track
# OUTPUT: 	save plots as single .png file, then for each sound save
#		manual correction as .pitch and smoothed contour as .smooth (pitch objects)
#		and .hesp (headerless spreadsheet file, ready for use in e.g. R)

# NOTES: 	The script uses a manual correction (.pitch file) if available,
#		otherwise asks user to create a new one (pausing the script for each file)
# 		Working on Praat 6.0.19 under Windows 10
# AUTHOR: 	fcangemi@uni-koeln.de

# INPUT
form Input parameters
	comment path (with final slash)
	sentence directory C:\Users\rolin\OneDrive\Oxford Research\Thesis related\data\4\Subj1\ju\point tier\
	comment plot parameters
	sentence figname mausmooth
	boolean raw 1
	boolean manual 1
	boolean smooth 1	
	integer plotmin 75
	integer plotmax 400
	comment what word
	word Word T1
	comment advanced extraction parameters
	integer smooth1 10
	integer smooth2 10
	integer timestep 0
	integer pitchmin 75
	integer pitchmax 600
	integer maxcandidates 15
	real silenceThr 0.03
	real voicingThr 0.45
	real octave 0.01
	real octavejump 0.35
	real voiceunvoiced 0.14 
endform 
Erase all
Select inner viewport: 0.5, 2.5, 0.5, 1.5
Solid line
Line width: 1



# open files
Create Strings as file list... pitchlist 'directory$'*'Word$'*.Pitch
Create Strings as file list... list 'directory$'*'Word$'*.wav
Sort
nfile = Get number of strings
for i to nfile
	name$ = Get string: i
	basename$ = name$ - ".wav"
	Read from file: directory$+name$

# ELABORATION 1: EXTRACT
# original f0 track
	To Pitch (ac): timestep, pitchmin, maxcandidates, "no", silenceThr, 
           ...voicingThr, octave, octavejump, voiceunvoiced, pitchmax

# manual correction
#	determine if there is already a manually corrected .pitch file
	exists = 0
	selectObject: "Strings pitchlist"
	npitch = Get number of strings
	for k to npitch
		pitchname$ = Get string: k
		pitchbasename$ = pitchname$ - ".Pitch"
		if pitchbasename$ = basename$
			exists = 1
		endif
	endfor
#	if it exists then open, else provide manual correction and save
	if exists = 1
		Read from file: directory$+basename$+".Pitch"
	elsif exists = 0
		selectObject: "Sound "+basename$
		View & Edit
		selectObject: "Pitch "+basename$
		Copy: basename$
		View & Edit
		pause Confirm
		Save as text file: directory$+basename$+".Pitch"
	endif
	Rename: "manual"

# smooth track
	Smooth: smooth1
	Rename: "smooth"
	Interpolate
	Smooth: smooth2
	Save as text file: directory$+basename$+".smooth"
	Down to PitchTier
	Save as headerless spreadsheet file: directory$+basename$+".hesp"



# ELABORATION 2: PLOT
# with any form-defined combination of 
# original in red, corrected in silver, smoothed in black
# Given the order of plotting, red "surfaces" as manually corrected points
	if raw = 1
		selectObject: "Pitch "+basename$
		Red
		Speckle: 0, 0, plotmin, plotmax, "no"
	endif
	if manual = 1
		selectObject: "Pitch manual"
		Silver
		Speckle: 0, 0, plotmin, plotmax, "no"
	endif
	if smooth = 1
		selectObject: "Pitch smooth"
		Black
		Draw: 0, 0, plotmin, plotmax, "no"
	endif

# OUTPUT
# close loops and clean
	select all
	minusObject: "Strings list"
	minusObject: "Strings pitchlist"
	Remove
	selectObject: "Strings list"
endfor
plusObject: "Strings pitchlist"
Remove

# save output
Save as 600-dpi PNG file: directory$+figname$+".png"
Erase all
