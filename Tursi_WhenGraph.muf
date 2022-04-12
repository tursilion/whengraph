( Tursi's WhenGraph - inspired by Contimes - needs M3  )
( Displays the activity as it is automatically updated )
( The first day will be incorrectly aligned unless you )
( manually create a string with one space for each 30  )
( mins that have passed. You must also create 7 "old"  )
( entries before you run it the first time, like so:   )
( @set <program>=/Lines/0001:!  <exclamation>          )
( @set <program>=/Lines/0002:!                         )
( @set <program>=/Lines/0003:!  ...etc                 )
( The number of lines you enter is the number of days  )
( that will be displayed <once filled in>              )
( Yes, it's manual and hacky, but it's also late!      )
( Updated 20 Apr 02 to pad lines to the correct time   )

$include $lib/strings

var start

$def LIMIT1 5
$def LIMIT2 15
$def LIMIT3 30

( Run the main loop )
( This function must run every 30 mins on the 30 mins to )
( update the connection count information )
: runLoop
  background
  systime timesplit ( we need to get how long it is until the half hour )
  pop pop pop pop pop pop
  dup 29 > if 30 - then  ( no more than 30 mins )
  60 * +            ( get seconds )
  1800 swap -       ( get seconds left to go )
  begin
    sleep           ( sleep until the half hour break )
    ( We awake - time to work )
	systime dup timesplit
	pop swap pop swap pop swap pop swap pop swap pop swap pop 
	prog "LastDay" getpropval over = not if
	  ( we need to start a new stamp )
	  prog swap "LastDay" swap "" swap addprop
	  intostr "/Lines/" swap strcat
	  ( we also need to delete the oldest one, assuming more than 7 )
      prog "/Lines/" nextprop prog swap remove_prop
	else
	  pop pop
	  "/Lines/" "0"
	  begin
	    swap prog swap nextprop
		dup "" strcmp while
		swap pop dup
	  repeat
	  pop
	then
    dup prog swap getpropstr
	dup "" strcmp if
	  dup strlen 1 - strcut pop
	then
	( Work out how long the string SHOULD be, and make sure it is )
    systime timesplit
	pop pop pop pop pop
	2 * swap
	25 > if 1 else 0 then
	+ 
	swap pop
	begin         ( string len )
	  over strlen over < while
	    swap " " strcat swap 
	repeat
	pop
    
	( Now add today's count )
	concount
	dup LIMIT3 > if
	  "#"
	else
	  dup LIMIT2 > if
	    "*"
	  else
	    dup LIMIT1 > if
		  "+"
		else
		  dup 0 > if
		    "."
		  else
		    " "
		  then
		then
	  then
	then
	swap pop strcat ":" strcat ( the colon is padding to protect spaces )
	prog -3 rotate 0 addprop
	1800
  repeat
;

( print a separator line )
: printseparator ( -- )
"------------------------------------------------" .tell
;

( Main function )
: main
( check if this is startup )
"Startup" strcmp not if
  me @ "W" flag?
  loc @ #-1 dbcmp 
  or if
    runLoop   ( never actually exits )
  else
    "* Nice try." .tell
  then
  exit
then

printseparator
"                Muck Connections" .tell
"----------A.M.--------------------P.M.----------" .tell
"1                   1 1 1                   1 1 " .tell
"2 1 2 3 4 5 6 7 8 9 0 1 2 1 2 3 4 5 6 7 8 9 0 1 " .tell
printseparator

"/Lines/"
begin prog swap nextprop dup "" strcmp while
  dup prog swap getpropstr 
  dup "!" strcmp if
    dup "" strcmp if
      dup strlen 1 - strcut pop
    then
    48 STRleft " %a" strcat
    over dup "/" rinstr strcut swap pop atoi
    timefmt .tell
  else 
    pop
  then
repeat

printseparator

". = 1-" LIMIT1 intostr strcat
"  + = " strcat LIMIT1 1 + intostr strcat "-" strcat LIMIT2 intostr strcat
"  * = " strcat LIMIT2 1 + intostr strcat "-" strcat LIMIT3 intostr strcat
"  # = more than " strcat LIMIT3 intostr strcat .tell
printseparator
;
