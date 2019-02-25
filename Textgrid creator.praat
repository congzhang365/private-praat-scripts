#######################################################################
# textgrid-creator.praat (Written by Kyuchul Yoon  kyoon@ling.osu.edu )
# Given a plain text file containing sentences by the line, the script
# tokenizes each sentence based on the word-boundary symbol (be it a
# space or any other symbol), creates a default textgrid with one 
# interval tier, and inserts the tokenized words into the interval tier.
#
# can 1. create new TextGrid, 2. insert words into existing tier of 
# existing TextGrid, 3. create new tier of existing TextGrid and insert words
#
# last modification, Pauline Welby welby@icp.inpg.fr
#
# Praat 4.3.29
########################################################################


# Read the text file containing the list of sound files.
Read Strings from raw text file... 'listDir$'\'inputSoundFile$'
Rename... soundFileObj
numSounds = Get number of strings

# Read the text file containing the list of sentences.
Read Strings from raw text file... 'listDir$'\'inputTextFile$'
Rename... textFileObj
numSentences = Get number of strings
# Check if the numbers match, i.e. the number of sentences and sounds
if numSounds <> numSentences
	exit Numbers DO NOT match. Check for end-of-file hard return.
else

	pause 'numSentences' sentences and their matching sound files read. Continue?
endif

if create_new_textgrid = 1
  pause New TextGrids will be created. Continue?
endif

# Proceed with a loop

for iSentence to numSentences
	select Strings textFileObj
	sentence$ = Get string... iSentence
	select Strings soundFileObj
	soundFileName$ = Get string... iSentence
	# Get the filename prefix from the sound filename.
	fileNamePrefix$ = soundFileName$ - ".wav"
	outputTextGridName$ = fileNamePrefix$ + ".TextGrid"

	# Tokenization (Note the use of an array variable "tokenText")
	iTokenCount = 1
	lengthOfSentence = length(sentence$)
	indexOfBoundaryMarker = index(sentence$,boundaryMarker$)
	while (indexOfBoundaryMarker <> 0)
		tokenText'iTokenCount'$ = left$(sentence$,(indexOfBoundaryMarker-1))
		sentence$ = right$(sentence$,(lengthOfSentence-indexOfBoundaryMarker))
		lengthOfSentence = length(sentence$)
		indexOfBoundaryMarker = index(sentence$,boundaryMarker$)
		iTokenCount = iTokenCount + 1
	endwhile
	# Store the last (or the only) word token.
	tokenText'iTokenCount'$ = sentence$

	# Put back the tokenized words into the newly created textgrid
	Read from file... 'soundDir$'\'soundFileName$'
	Rename... soundFileObj
	# But first, check the duration of the sound file
	durationOfSound = Get total duration
	durationOfEachInterval = durationOfSound/iTokenCount

# check whether a new textgrid is added or a tier added to an existing textgrid

        if create_new_textgrid = 1
 
	  # Then create the textgrid and insert interval tier boundaries.
	  To TextGrid... "'tierName$'"
        
        else

          Read from file... 'textDir$'\'outputTextGridName$'
          select TextGrid 'fileNamePrefix$'
          Edit
          editor TextGrid 'fileNamePrefix$'

          if create_new_tier = 1
            Add interval tier... 'tierNum' 'tierName$'    
          endif
 
        Close
        endeditor        

        endif

	Rename... textgridObj

	for iInterval to (iTokenCount-1)
		timeForIntervalTierBoundary = durationOfEachInterval*iInterval
		Insert boundary... 'tierNum' timeForIntervalTierBoundary
	endfor


       # Get starting and end points
        start = Get starting point... 'tierNum' 1
        end= Get end point... 'tierNum' iTokenCount
        

       # insert first and last boundaries

       first = (start + 0.020)
       last = (end - 0.020)

       Insert boundary... 'tierNum' first
       Insert boundary... 'tierNum' last

	# Finally, insert tokenized words.
	for iInterval to iTokenCount
		dummyTokenText$ = tokenText'iInterval'$
		Set interval text... 'tierNum' (iInterval+1) 'dummyTokenText$'
	endfor

	# Check if everything's OK and proceed to the next sentence if any.
	plus Sound soundFileObj
	Edit
	pause Is everything OK? Otherwise, modify the textgrid yourself! :)
        
	#textgridStat$ = Read from file... 'textDir$'\'outputTextGridName$'
        select TextGrid textgridObj
	Write to text file... 'textDir$'\'outputTextGridName$'
	plus Sound soundFileObj
	Remove
endfor
plus Strings textFileObj
plus Strings soundFileObj
Remove
############### END OF SCRIPT ###################