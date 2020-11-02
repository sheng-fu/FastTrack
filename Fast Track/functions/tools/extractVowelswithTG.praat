
procedure extractVowelswithTG

segment_tier = 1
word_tier = 0

# set parameter for specifying vowels. make table
.vwl_str = Create Strings as tokens: "AA AE AH AO AW AX AY EH ER EY IH IX IY OW OY UH UW UX", " ,"
Rename: "vowels"

#selectObject: tg
#tmp$ = Get tier name: 1
#if tmp$ = "words"
#  word_tier = 1
#  segment_tier= 2
#endif
#tmp$ = Get tier name: 2
#if tmp$ = "words"
#  word_tier = 2
#endif

beginPause: "Set Parameters"
    optionMenu: "", 1
    option: "[**IMPORTANT** Click to Read]"
    option: "When this form is generated, a Strings object called vowels is created and appears in the"
    option: "Praat object window.  Any vowels found here will be extracted. All arpabet vowels are included"
    option: "by default. Once this form is closed the strings object can no longer be edited."
    option: "Alternatively, you can write the vowels you want in a text file, one per lines. You can read"
    option: "this in by specifying a path to a text file below."
    comment: "Path to optional text file with alternate vowels (--)"
    sentence: "Vowels file:", "--"
    optionMenu: "", 1
    option: "[**IMPORTANT** Click to Read]"
    option: "Sounds folder: sounds will be extracted for all sound files in this folder with corresponding text grids."
    option: "TextGrid folder: any TextGrids here willbe matched up with sounds with the same filename in the above folder."
    option: "Folder: all output sounds and CSV files will go here."
    sentence: "Sound folder:", ""
    sentence: "TextGrid folder:", ""
    sentence: "Folder:", folder$
    comment: "Which tier contains segment information?"
    positive: "Segment tier:", segment_tier
    comment: "Which tier contains word information? (not necessary)"
		integer: "Word tier:", word_tier
    comment: "Optional tiers (up to 3) containing comments that will also be collected."
		integer: "Comment tier1:", 0
		integer: "Comment tier2:", 0
		integer: "Comment tier3:", 0
    comment: "Collect vowels with the following stress."
    optionMenu: "Select stress", 2
    option: "Only primary stress"
    option: "Primary and secondary stress"
    option: "Any"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "Vowels will not be extracted from any words specified here. Please spell"
    option: "words exactly as they will appear in the textgrid (including capitalization)."
    option: "Words should be separated by a space."
		sentence: "Words to skip:", "--"
    optionMenu: "", 1
    option: "[Click to Read]"
    option: "How much time should be added to edges (0 = no padding)?"
    option: "Setting the buffer to 0.025 allows formant tracking to the edge of the sound when using"
    option: "a 50ms analysis window. Alternatively, sounds can be padded with zeros before analysis"
    option: "with another function provided by Fast Track."
    positive: "Buffer (s):", 0.025
nocheck endPause: "Ok", 1

if vowels_file$ <> "--"
  removeObject: "Strings vowels"
  Read Strings from raw text file: vowels_file$
  Rename: "vowels"
endif

words_to_skip = 0
## make table with words to skip
if words_to_skip$ <> "--"
  words_to_skip = 1
  .skipWords = Create Strings as tokens: words_to_skip$, " ,"
  Rename: "wordstoskip"
  n = Get number of strings

  wordTbl = Create Table with column names: "wordstoskip", n, "word"
  for i from 1 to n
    selectObject: "Strings wordstoskip"
    tmp$ = Get string: i
    selectObject: "Table wordstoskip"
    Set string value: i, "word", tmp$
  endfor
  removeObject: "Strings wordstoskip"
endif

## make table with vowels to collect
selectObject: "Strings vowels"
n = Get number of strings
vwlTbl = Create Table with column names: "vowels", n, "vowel"
  for i from 1 to n
    selectObject: "Strings vowels"
    tmp$ = Get string: i
    selectObject: "Table vowels"
    Set string value: i, "vowel", tmp$
  endfor
  removeObject: "Strings vowels"
endif



obj = Create Strings as file list: "files", textGrid_folder$ + "/*.TextGrid"
nfiles = Get number of strings



for filecounter from 1 to nfiles
    selectObject: obj
    filename$ = Get string: filecounter
    basename$ = filename$ - ".TextGrid"

    tg = Read from file: textGrid_folder$ + "/" + filename$
    nintervals = Get number of intervals: 1

    if (fileReadable: sound_folder$ + "/" + basename$ + ".wav") & (nintervals > 1)
    snd = Read from file: sound_folder$ + "/" + basename$ + ".wav"

    ## make table that will contain all output information
    tbl = Create Table with column names: "table", 0, "file filename vowel interval duration start end previous_sound next_sound stress"
    if word_tier > 0
    Append column: "word"
    Append column: "word_interval"
    Append column: "word_start"
    Append column: "word_end"
    Append column: "previous_word"
    Append column: "next_word"
    endif
    
    if comment_tier1 > 0
      Append column: "comment1"
    endif
    if comment_tier2 > 0
      Append column: "comment2"
    endif
    if comment_tier3 > 0
      Append column: "comment3"
    endif

    @extractVowels

    selectObject: tbl
    Save as comma-separated file: folder$ + "/"+ basename$+ "_segmentation_info.csv"
    removeObject: tbl, snd, tg


endfor
     
removeObject: vwlTbl, obj

endproc