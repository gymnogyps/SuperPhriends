#!/bin/bash

# Function: superNavigator () 
#  Purpose: The function provides fast directory structure transversal with persistance provided by Sqlite3.
#           This is a drop in replacement for bash directory stack.  
#     Date:  6/7/14
#   Author:  Joseph Pesco
#     GUFI:  53a625c4622263.37230699:53930d86598882.90283896:20140622:024100UTC


# Multibyte key squence work derived from Stack Overflow "Casing arrow keys in bash"

# Sunday, 20140622 9:55 UTC
#         Goal: Use sqlite_rocket for SuperNavigator utility.   


echo "DEBUG (sandbox.sh) Entering Script"

BUGGY=0
VERBOSE=1
HEREDOC_DESTINATION=/dev/stdout
USERINTERFACE=$PWD/bash_tui
DBLOCATION=/home/condor/bin/SuperNavigator.db
ROCKET=$PWD/sqlite_rocket
A_TESTVAR="test"


ABSOLUTE_DATABASE_PATH=/home/condor/bin/SuperNavigator.db
export ABSOLUTE_DASTABASE_PATH	
# ABSOLUTE_DATABASE_PATH=""
# Function: verbose_out ()
# Purpose:  Echo to standard ouptput
# Date:     8/4/14
# Author:   condor

verbose_out () {

		(($VERBOSE)) && echo "$1" > /dev/stdout
}

# Function: debug_out ()
# Purpose:  Echo to standard ouptput
# Date:     8/4/14
# Author:   condor

debug_out () {

		(($BUGGY)) && echo "$1"  > /dev/stderr
}

error_out () {

		echo "$1"  > /dev/stderr
}

# Function: init_rocket ()
# Purpose:  Plugin database functionality, note future versions of the rocket may not be shell scripts!
# Date:     8/4/14
# Author:   condor

init_rocket () {

	local BUGGY=1
	local VERBOSE=1
	local ABSOLUTE_DATABASE_PATH="$1"
	local fret=0
	
	echo "DEBUG (sandbox.sh), init_rocket() \$ABSOLUTE_DATABASE_PATH  $DBLOCATION"

	if [ -f "$DBLOCATION" ]; then

		echo "DEBUG (sandbox.sh), init_rocket(): Database Location: $ABSOLUTE_DATABASE_PATH"

		if [ -f $ROCKET ]; then
	
			verbose_out "VERBOSE (sandbox.sh), init_rocket(): rocket has been assigned to: $ROCKET"
			$ROCKET --configure
		else
	
			verbose_out "rocket has not been assigned."
			fret=1
		fi
	else

		verbose_out "VERBOSE (sandbox.sh), init_rocket(): Database Not In Assigned location Location: $DBLOCATION"
		verbose_out "VERBOSE (sandbox.sh), init_rocket(): Attempt sqlite_rocket without arguments and creating a new database."

		fret=1
	fi
	debug_out "DEBUG (sandbox.sh), init_rocket(): returning with value: \$fret: $fret"
	return $fret
}

# Function: init_ui ()
# Purpose:  Plugin the console text user interface
# Date:     8/4/14
# Author:   condor

init_ui () {

  local fret=1
  local USERINTERFACE="${1}"

  if [ -f $USERINTERFACE ]; then
    . $USERINTERFACE
    fret=0
  else 
    error_out "ERROR (sandbox.sh), init_ui(): \"$USERINTERFACE\" could not be found!."
    error_out "ERROR (sandbox.sh), init_ui(): Calling script should terminate upon return from this function!"
  fi
  
  return $fret

}

# STACK=( '/home/condor' '/home/condor/devel/bash/read' '/usr/local/bin' )
# Obsolete, replace the following line of script with a call to stack_retrieve ()

# Function: isnum ()
# Purpose:  This function insures that the characters in the string passed as an argument are all digits.
# Date:     8/4/14
# Author:   condor

function isnum () {

        debug_out "function: isnum{}" 
        len=${#1}

        for (( y=0; $y < $len; y++ )) ; do 

                char=${1:${y}:1}

                # Uncomment for a fearful quantity of verbosity!
                # echo -n $char 

                if ! [[ $char =~ [[:digit:]] ]]; then 
                        return 1
                fi
        done
        return 0
}



# New Primatives based on disatisfaction with with functions:

# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function navigation_help () {

	:

}

# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function navigation_kboard () {

	COMPLETE=0
	EXITONCOMPLETE=1



	if [ "$1" == '--help' ]; then

		echo "Keyboard_navigation help"
	fi

	# #######################################

	CURSOR=0
	FIRST_ELEMENT=0
	LAST_ELEMENT=${#STACK[@]}


	
	# echo -en "\\0337"
	# clear
	# echo -e "\\033[10;1H"
	# echo -e "\\033#3"
	echo -n ${STACK[${CURSOR}]}

	# #######################################

	while [[ $COMPLETE -eq 0 ]]; do # 1 char (not delimiter), silent

		read -sN1 key

		unset complete_key_sequence

		# catch multi-char special key sequences
		read -sN1 -t 0.0001 k1
		read -sN1 -t 0.0001 k2
		read -sN1 -t 0.0001 k3
		complete_key_sequence+=${key}${k1}${k2}${k3}
		
		echo -en "\\033[2K\\033[1000D"
	
		case "$complete_key_sequence" in 
			$'' )
				(($VERBOSE)) && echo "Enter"

				if [ -d  ${STACK[${CURSOR}]} ]; then

					PREVIOUSLOCATION=$PWD
					cd ${STACK[${CURSOR}]}
					CURRENTLOCATION=$PWD
					COMPLETE=1
				else
					echo -n "can't find selected directory!"
				fi
			;;
#		$'\e[D')
#				(($VERBOSE)) && echo "left arrow"
#
#				(($EXITONCOMPLETE)) && COMPLETE=1
#
#				if [ $CURSOR -lt ${#MYPATH[@]} ]; then
#					let CURSOR++
#				fi
#			;;
#			$'\e[C')
#				(($VERBOSE)) && echo "right arrow"
#
#				(($EXITONCOMPLETE)) && COMPLETE=1
#
#				if [ $CURSOR -gt 0 ]; then
#					let CURSOR--
#				fi
#			;;
			$'\e[A')
				# (($VERBOSE)) && echo "up arrow"

				let  CURSOR--
				echo  -n ${STACK[$CURSOR]}
			;;

			$'\e[B')
				# (($VERBOSE)) && echo "down arrow"
				
				let CURSOR++

				echo  -n ${STACK[$CURSOR]}
			;;

		esac

		
	done
}


# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function iterate_navigation_list () {

	index=0
	for element in "${STACK[@]}" ; do
		echo $index $element
		let index++
	done
}

# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function navigation_back () {

		((1)) && {
			echo "Previous Location:  $PREVIOUSLOCATION"
			echo "Current Location:   $CURRENTLOCATION"
		} > /dev/stderr

		cd $PREVIOUSLOCATION	
		PREVIOUSLOCATION=$CURRENTLOCATION
		CURRENTLOCATION=$PWD
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function navigation_tui () {

	# We've got to use the keyboard to do this

	navigation_kboard


}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function navigation_goto () {
  
	if [ -d ${STACK[$1]} ]; then

		CURRENTLOCATION=${STACK[$1]}
		PREVIOUSLOCATION=$PWD
		cd ${STACK[$1]}
	fi
}

# End User functions

# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

# Note: A bunch of if/fi due to fluid nature of development at this stage

function nav () {

	OP_IS_COMPLETED=0

	if [ $# -eq 0 ] || [ "$1" == 'view' ] || [ "$1" == 'v' ] ; then 

		iterate_navigation_list
		OP_IS_COMPLETED=1
	fi 


	if [ "$1" == 'help' ] || [ "$1" == 'h' ] ; then 

		navigation_help
		OP_IS_COMPLETED=1
	fi 

	if [ "$1" == 'back' ] || [ "$1" == 'b' ] ; then 

		navigation_back
		OP_IS_COMPLETED=1
	fi 

	if [ "$1" == 'tui' ] || [ "$1" == 't' ] ; then 
	
        	navigation_tui
		COMPLETE=1
        fi 


	if [ $# -eq 1 ] && [ $OP_IS_COMPLETED -eq 0 ]; then

		isnum $1 
		val=$?

		echo "Is number: $val" 

		if [ $val -eq 0 ]; then 
			navigation_goto $1
		fi 
	fi


}




# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

stack_cursor () {
	echo $SCURSOR
}


### primative stack interface
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

stack() {
	index=0
	for element in "${STACK[@]}" ; do
		echo $index $element
		let index++
	done
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

stack_push () {

	# ARG="\"$1\""
	# echo ARG: $ARG
	
	# IFS=$'\n'
	STACK=( "$1" ${STACK[@]} )

	# STACK[0]="hello world"
	# IFS=$' \n\t'
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

stack_pop () {
	STACK[0]=''

	STACK=( ${STACK[@]} )

	:
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

stack_top () {

	echo ${STACK[0]}
}

### advanced stack interface
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

stack_goto () {

	if [ $# -eq 0 ];then 
		cd ${STACK[0]}
	else 
		cd ${STACK[$1]}
	fi
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

stack_retrieve () {

	:

}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

stack_stow () {

	echo "DEBUG (sandbox.sh), stack_stow (): entering"

	$ROCKET --delete

	echo "DEBUG (sandbox.sh)"
	for path in ${STACK[@]}; do 

		echo "DEBUG (sandbox.sh) \$path: $path"
		$ROCKET --push  $path
	done

	echo "DEBUG (sandbox.sh), stack_stow (): leaving"
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

mypath () {

  if [ $# -eq 0 ]; then
    echo $MPATH
  elif [ $# -eq 1 ]; then
    MPATH=$1
  fi
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

mypath_accend () {
	:
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

mypath_decend () {
	:
}



# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function keyboard_navigation () {

COMPLETE=0
EXITONCOMPLETE=0



if [ $1 == '--help' ]; then

	echo "Keyboard_navigation help"
fi

# echo $PWD | sed -n 's#/#%%%*%%%#gp'
# echo $PWD | sed -n 's#/#\n#gp'
OLDIFS=$IFS
IFS=$'\n'

MYPATH=(`echo $PWD | sed -n 's#/#\n#gp'`)
CURRENTPATH=$PWD
CURSOR=${#MYPATH[@]}

if [ $CURSOR -gt 0 ]; then
	let CURSOR--
fi

INDEX=0
for directory in ${MYPATH[@]}; do
	echo $INDEX $directory
	let INDEX++
done

IFS=$OLDIFS
# while  read -sN1 key
while [[ $COMPLETE -eq 0 ]]; do # 1 char (not delimiter), silent


	read -sN1 key

	unset complete_key_sequence

	# catch multi-char special key sequences
	read -sN1 -t 0.0001 k1
	read -sN1 -t 0.0001 k2
	read -sN1 -t 0.0001 k3
	complete_key_sequence+=${key}${k1}${k2}${k3}



	(($BUGGY)) && {
		echo "Initial byte: $key"
		echo " Second byte: $k1"
		echo "  Third byte: $k2"
		echo " Fourth byte: $k3"
		echo "Complete key string: "
		echo $complete_key | od 
		# printf "%x\n" $key
	}


	case "$complete_key_sequence" in 
		$'' )
			(($VERBOSE)) && echo "Enter"
		;;


		$'\e' )
			(($VERBOSE)) && echo "escape key"
		;;

		$'\e[D')
			(($VERBOSE)) && echo "left arrow"

			(($EXITONCOMPLETE)) && COMPLETE=1

			if [ $CURSOR -lt ${#MYPATH[@]} ]; then
				let CURSOR++
			fi
		;;


		$'\e[C')
			(($VERBOSE)) && echo "right arrow"

			(($EXITONCOMPLETE)) && COMPLETE=1

			if [ $CURSOR -gt 0 ]; then
				let CURSOR--
			fi
		;;


		$'\e[A')
			(($VERBOSE)) && echo "up arrow"

			cd /home/condor/devel/bash/read
			(($EXITONCOMPLETE)) && COMPLETE=1
		;;

		$'\e[B')
			(($VERBOSE)) && echo "down arrow"
			(($EXITONCOMPLETE)) && COMPLETE=1
			cd /home/condor/devel/bash/read
			# COMPLETE=1
		;;

		$'q')
			(($VERBOSE)) && echo "lower case q"
			(($EXITONCOMPLETE)) && COMPLETE=1
		
			COMPLETE=1
		;;






		i|j|$'\e[A'|$'\e0A'|$'\e[D'|$'\e0D')
 		# cursor up, left: previous item
		# ((cur > 1)) && ((cur--));;
			echo "cursor up, .eft: previous item"
		;;


	esac


	echo "Cursor: ${MYPATH[$CURSOR]}"

	CURRENTPATH=""
	for (( x = 0 ; $x <= $CURSOR; x++ )); do

		CURRENTPATH="${CURRENTPATH}/${MYPATH[$x]}"
	done

		DIRECTORYCONTENTS=(`ls $CURRENTPATH`)

		DC_CURSOR=${#DIRECTORYCONTENTS[@]}

	echo -en "Current path: $CURRENTPATH"

	echo

	for file in ${DIRECTORYCONTENTS[@]}; do
		echo $file
	done	


done

}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function keyNav () {
	keyboard_navigation
}



### The sandbox interface should remain  compact and complete.
### We don't want to alter this interface should it be found
### useful down the road for some other purpose.

function sandbox () {


	. /home/condor/devel/bash/read/box.sh 


	keyboard_navigation
}
# Function: 
# Purpose:  
# Date:     8/4/14
# Author:   condor

function sandbox_help () {

	keyboard_navigation --help

}




function billboard () {

fret=1

if [ $1 == off ]; then 
  return $fret
fi

cat > $HEREDOC_DESTINATION <<EOD

	###########################################################################################
	###########################################################################################
	File: /home/condor/devel/bash/read/sandbox.sh
	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

	There are as of Friday July 7, 2014 to entrances to functionality provided by this script.


	Navigation 
	__________
	nav      - with no command line options or arguments produces a list destinations.

		digits corresponding to available destinations

		help
			---------------------------------------------------------------------------

		back
                        ---------------------------------------------------------------------------

		tui
                        ---------------------------------------------------------------------------





	Stack
        __________

	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
	###########################################################################################
	###########################################################################################

EOD
return $fret
}


#
#                            *** Userland ***
#
# #############################################################################


verbose_out "VERBOSE Entering Userland"
init_rocket "$ABSOLUTE_DATABASE_PATH"

verbose_out "VERBOSE 2"
if [ $? -eq 0 ]; then

verbose_out "VERBOSE 3"
  # init_rocket() was successful, error would have ben caught within function
  # body!
  
  if [ ! -f "${USERINTERFACE}" ]; then
  
verbose_out "VERBOSE 4"
    error_out "ERROR (sandbox.sh), Line: $LINENO, The value of \$USERINTERFACE: $USERINTERFACE is not valid!"
  else
  
verbose_out "VERBOSE 5"
    init_ui "${USERINTERFACE}"
    if [ $? -eq 0 ]; then
  
verbose_out "VERBOSE 6"
      STACK=( `$ROCKET --populate` )
      SCURSOR=0 
      MPATH=${STACK[0]}

      CURRENTLOCATION=$PWD
      PREVIOUSLOCATION=$PWD

      billboard off
    
    fi
  fi
fi


verbose_out "VERBOSE 7"
### ###########################################################################

function innards () {
	# catch multi-char special key sequences
	read -sN1 -t 0.0001 k1
	read -sN1 -t 0.0001 k2
	read -sN1 -t 0.0001 k3
	key+=${k1}${k2}${k3}


	case "$key" in
		i|j|$'\e[A'|$'\e0A'|$'\e[D'|$'\e0D')
 		# cursor up, left: previous item
		((cur > 1)) && ((cur--));;

		k|l|$'\e[B'|$'\e0B'|$'\e[C'|$'\e0C')
 		# cursor down, right: next item
		((cur < $#-1)) && ((cur++));;

		$'\e[1~'|$'\e0H'|$'\e[H')
 		# home: first item
		cur=0;;

		$'\e[4~'|$'\e0F'|$'\e[F')
 		# end: last item
		((cur=$#-1));;

		' ') # space: mark/unmark item
		array_contains ${cur} "${sel[@]}" && \
		sel=($(array_remove $cur "${sel[@]}"))|| sel+=($cur);; \

		q|'') # q, carriage return: quit
		echo "${sel[@]}" && return;;
	esac

	# draw_menucursor_updone
	# $cur$

}
