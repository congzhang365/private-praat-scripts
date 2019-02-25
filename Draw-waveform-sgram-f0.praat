################################################################
###  
### draw-waveform-sgram-f0.praat
###
### Reads in sound files and TextGrid files, creates related Objects (Pitch, Spectrogram),
### draws picture in Praat picture window, saves under specified format
###
### Draws waveform, spectrogram, F0 curve and TextGrid.
###
### Optionally overlays F0 curve on spectrogram. The F0 curve is drawn first with a thick white line,
### then a narrower black line, which makes it stand out against the dark spectrogram.
### 
### Pauline Welby
### welby@ling.ohio-state.edu, welby@icp.inpg.fr
### April 15, 2003
###
### Last change, November 20, 2005
###
### Praat 4.3.29
###
################################################################

# Form that queries the user to specify the name of various relevant
# directories and other parameters

form Input directory name
    comment Enter parent directory where soundfiles are kept:
    sentence soundDir D:\Program Files
    comment Enter parent directory where TextGrid files are kept:
    sentence textDir D:\Program Files
    comment Enter directory where figure files will be saved:
    sentence figDir D:\Program Files
    comment Superimpose f0 curve?
    boolean superimp_f0 yes
    comment Enter F0 minimum:
    positive f0min 50
    comment Enter F0 maximum:
    positive f0max 350
    comment Enter x axis label:
    sentence xaxis Time (s)
    comment Enter y axis:
    sentence yaxis Fundamental frequency (Hz)
    comment Enter x axis (time) major unit:
    positive timeMajUnit 0.1
    comment Enter x axis (time) minor unit:
    positive timeMinUnit 0.1
    comment Enter right boundary of figure (specify width)
    positive rightBound 10 
    comment Enter lower boundary of TextGrid/inner box:
    positive tgridBot 7
    comment Save as Windows media file?
    boolean wmf yes
    comment Save as encapsulated Postscript file?
    boolean eps no
    comment Save as as praat picture file?
    boolean praatPic no
endform

# Create list of .wav files

## uncomment to read files from a list
# Read Strings from raw text file... 'soundDir$'\list.txt

Create Strings as file list... list 'soundDir$'\*.wav

# loop that goes through all the specified files

numberOfFiles = Get number of strings
for ifile to numberOfFiles
   select Strings list
   fileName$ = Get string... ifile
   baseFile$ = fileName$ - ".wav"

   # Read in the TextGrid file and .wav file with that base name

   Read from file... 'textDir$'\'baseFile$'.TextGrid
   Read from file... 'soundDir$'\'baseFile$'.wav

   select Sound 'baseFile$'
   # Make Pitch object
   if superimp_f0 = 1
     To Pitch... 0.005 75 600
   endif

   # Make Spectrogram object
   select Sound 'baseFile$'
   To Spectrogram... 0.005 10000 0.002 20 Gaussian

   # Draw in Praat picture window.  These specifications draw a Sound object (waveform) and under that,
   # a Pitch object superimposed Spectrogram object.  The TextGrid is
   # drawn and then the entire picture is enclosed in a box.
   # 
   # To change these specifications (and indeed, to make all types of changes to a Praat script): 
   # In the Script window: Edit | Clear history. Draw a sample picture in the Praat picture the way you 
   # want it to appear, then place your cursor in the Script window and do: 
   # Edit | Paste history.  You'll have to add in the appropriate variables (here, baseFile), 
   # but you'll get the right structure.

     # Specify font type size, color
     Times
     Font size... 15
     Black

     # Define size and position of waveform (by specifying grid coordinates)
     Viewport... 0 'rightBound' 0 2

     # Draw waveform
     select Sound 'baseFile$'
     Draw... 0 0 0 0 no curve
 
     # Define size and position of spectrogram
     Viewport... 0 'rightBound' 1 5

     # Draw spectrogram
     select Spectrogram 'baseFile$'
     Paint... 0 0 0 0 100 yes 50 6 0 no

     if superimp_f0 = 1
       # Draw Pitch curve
       # first as a thick white line
       select Pitch 'baseFile$'
       Line width... 15
       White
       Draw... 0 0 'f0min' 'f0max' no

       # then as a thin black line
       Line width... 4
       Black
       Draw... 0 0 'f0min' 'f0max' no

       # Label y axis
       # N.B.: can change language of labels here. 
       # Also, Praat default label for y axis is "Pitch".
       Line width... 1
       One mark left... 'f0max' no no yes
       One mark left... 'f0min' no no yes
       Marks left every... 1 50 yes yes no
       Text left... yes 'yaxis$'
       Draw... 0 0 'f0min' 'f0max' no
     endif

     # Label x axis 
     Text bottom... yes 'xaxis$'
     Marks bottom every... 1 'timeMinUnit' no yes no
     Marks bottom every... 1 'timeMajUnit' yes yes no

###########################################################

## To print F0 labels that follow the f0 contour,
## create a second TextGrid file (named baseFile2) 
##  with only the F0 label tier
## and uncomment the following lines

## Reads in the F0-labels-only TextGrid
#Read from file... 'textDir$'\'baseFile$'2.TextGrid

## Defines size and position of pitch curve and F0 labels 
## N.B.: must be the same as early pitch curve
#Viewport... 0 'rightBound' 1 5

## Draw first in white

#White

## Select TextGrid and Pitch objects together, so labels will
## follow pitch curve

#select TextGrid 'baseFile$'2
#plus Pitch 'baseFile$'
#Draw... 1 0 0 'f0min' 'f0max' 18 yes Centre no

## Draw in black

#Black
#select TextGrid 'baseFile$'2
#plus Pitch 'baseFile$'
#Draw... 1 0 0 'f0min' 'f0max' 16 yes Centre no

###########################################################

   # Define size and position of TextGrid
   Viewport... 0 'rightBound' 3 'tgridBot'

   # Draw TextGrid
   select TextGrid 'baseFile$'
   Draw... 0 0 yes yes no

   # Define size and position of inner box
   Viewport... 0 'rightBound' 0 'tgridBot'

   # Draw inner box
   Black
   Draw inner box

  # Write to a file (see choices under File in the Praat picture window)
   if 'wmf' = 1
     Write to Windows metafile... 'figDir$'\'baseFile$'.wmf
   endif

   if 'eps' = 1
     Write to EPS file... 'figDir$'\'baseFile$'.eps
   endif

   if 'praatPic' = 1
     Write to praat picture file... 'figDir$'\'baseFile$'.praapic
   endif

   # Erase picture before going onto next object in list
   Erase all

   # Remove objects from Praat objects list
   select Spectrogram 'baseFile$'
   plus TextGrid 'baseFile$'
   plus Sound 'baseFile$'
   Remove
   
   # Remove Pitch object, if necessary
   if superimp_f0 = 1
     select Pitch 'baseFile$'
     Remove
   endif

endfor

# Remove object list

select Strings list
Remove

################################################################
#END OF SCRIPT -- HAPPY, HAPPY, JOY, JOY!
################################################################
