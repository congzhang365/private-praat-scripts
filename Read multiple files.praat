# name:		read multiple files
# author:	Gabriel J.L. Beckers (http://wwwbio.leidenuniv.nl/~eew/G6/staff/beckers/beckers.html)
# date:		2003-12-18
# purpose:	to open all files with a specified extension in
#		a directory
# usage:	Run and specify the source directory and file extension.
#		This script works on Linux, but can easily be adapted to
#		work on Windows or Mac. If you often use the same directory
#		then change the default "/home/user/soundfiles" to whatever
#		it is. Similarly you can change the default file extension.

#############################################################################
# Copyright (C) 2002-2003  Gabriel J.L. Beckers
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#############################################################################


form Read multiple files
	sentence source_directory C:\Documents and Settings\Eric\Desktop\LAUREN\BRADLOW_LAB\SXN\Stimuli\Clear_BKB_Targets\Christina_final_ClearStim
	sentence file_extension .wav
endform

Create Strings as file list... list 'source_directory$'/*'file_extension$'
Sort

string_ID = selected("Strings")
number_of_files = Get number of strings

for ifile to number_of_files
	select Strings list
	file_name$ = Get string... ifile
	Read from file... 'source_directory$'/'file_name$'
endfor

select 'string_ID'
Remove
