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
( Updated 6 Jan 03 to track the best connects          )
( Updated 15 Jan 03 to display the current number of   )
( connects                                             )
( Updated 07 Apr 03 by Marjan to display ANSI color    )
( Updated 15 June 03 to fix ANSI color after fixing    )
( the muck's code for ANSI_STRIP - Tursi               )
 
$include $lib/strings
$include $lib/ansi
var start
$def LIMIT1 5
$def LIMIT2 15
$def LIMIT3 30
$def strcut ansi_strcut
$def strlen ansi_strlen
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
  dup ansi_strip "" strcmp while
  swap pop dup
   repeat
   pop
 then
    dup prog swap getpropstr
 dup ansi_strip "" strcmp if
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
 ( check for a record )
    prog "_Record" getpropstr atoi over < if
   dup intostr prog swap "_Record" swap 0 addprop
      prog "_Date" "%e %B, %Y %k:%M" systime timefmt 0 addprop
 then
 dup LIMIT3 > if
   "^RED^#"
 else
   dup LIMIT2 > if
     "^YELLOW^*"
   else
     dup LIMIT1 > if
    "^GREEN^+"
  else
    dup 0 > if
      "^BLUE^."
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
" ^CYAN^-----------------------------------------------------" .tell
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
    "^WHITE^* Nice try." .tell
  then
  exit
then
"^CYAN^/-----------------------------------------------------\\" .tell
"                  ^WHITE^Muck Connections:^GREEN^ " concount intostr dup strlen -3 rotate strcat swap 2 / strcut swap pop .tell
" ^CYAN^------------^WHITE^A.M.^CYAN^--------------------^WHITE^P.M.^CYAN^-------------" .tell
"   ^WHITE^1                   1 1 1                   1 1 " .tell
"   ^WHITE^2 1 2 3 4 5 6 7 8 9 0 1 2 1 2 3 4 5 6 7 8 9 0 1 " .tell
printseparator
"/Lines/"
begin prog swap nextprop dup ansi_strip "" strcmp while
  dup prog swap getpropstr 
  dup ansi_strip "!" strcmp if
    dup ansi_strip "" strcmp if
      dup strlen 1 - strcut pop
    then
    48 STRleft " ^WHITE^%a" strcat
    "^WHITE^%d " swap strcat
    over dup "/" rinstr strcut swap pop atoi
    timefmt .tell
  else 
    pop
  then
repeat
printseparator
"   ^BLUE^. ^WHITE^= 1-" LIMIT1 intostr strcat
"  ^GREEN^+ ^WHITE^= " strcat LIMIT1 1 + intostr strcat "-" strcat LIMIT2 intostr strcat
"  ^YELLOW^* ^WHITE^= " strcat LIMIT2 1 + intostr strcat "-" strcat LIMIT3 intostr strcat
"  ^RED^# ^WHITE^= more than " strcat LIMIT3 intostr strcat .tell
printseparator
"   ^WHITE^Most connections:^GREEN^ " prog "_Record" getpropstr atoi intostr strcat " ^WHITE^on^GREEN^ " strcat prog "_Date" getpropstr strcat .tell
"^CYAN^\\-----------------------------------------------------/" .tell
;
