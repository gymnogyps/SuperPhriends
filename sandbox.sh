#!/bin/bash

# Feature:  Navigator 
#  Purpose: Provides fast directory structure transversal with persistance provided by Sqlite3.
#           This is a drop in replacement for bash directory stack.  
#     Date:  6/7/14
#   Author:  Joseph Pesco
#     GUFI:  53a625c4622263.37230699:53930d86598882.90283896:20140622:024100UTC


# Multibyte key squence work derived from Stack Overflow "Casing arrow keys in bash"

# Sunday, 20140622 9:55 UTC
#         Goal: Use sqlite_rocket to populate the STACK array.   

BUGGY=1
VERBOSE=1

# Function: init_rocket () 
# Purpose:  Find the sqlite database manager.
# Author:   condor
# Date:     07/29/14
init_rocket () {

	fret=0

	ROCKETLOCATIONS[0]=$PWD/sqlite_rocket
	# ROCKETLOCATIONS[1]=/home/condor/devel/bash/read/sqlite_rocket 
	# ROCKETLOCATIONS[2]=/run/media/condor/567fba76-1c0a-49d5-9373-710fc2a5b85c/home/condor/devel/bash/read/sqlite_rocket

	INDEX=0
	for rocket in ${ROCKETLOCATIONS[@]}; do 

		(($BUGGY)) && echo "DEBUG: init_rocket() \$INDEX: $INDEX: rocket location: $rocket" > /dev/stdout
		if [ -f $rocket ]; then

			ROCKET=$rocket
			break
		fi
		let INDEX++
	done

	if [ -f $ROCKET ]; then

		(($BUGGY)) && echo "DEBUG: init_rocket() rocket has been assigned to: $ROCKET" > /dev/stdout
		fret=1
		# Handshake the sqlite database manager, pole the results and set the state of the 
		# function return value after configure and not before.
		$ROCKET --configure
	else

		(($BUGGY)) && echo "DEBUG: init_rocket() rocket has not been assigned." > /dev/stdout
	fi

	return $fret
}


init_ui () {

	USERINTERFACE=bash_tui
	fret=0

	if [ -f $USERINTERFACE ]; then
		fret=1
		. $USERINTERFACE
		
	fi
	return $fret

}

# STACK=( '/home/condor' '/home/condor/devel/bash/read' '/usr/local/bin' )

# Obsolete, replace the following line of script with a call to stack_retrieve ()
function isnum () {


        echo "DEBUG: isnum" > /dev/stderr
        len=${#1}

        for (( y=0; $y < $len; y++ )) ; do 

                char=${1:${y}:1}

                # echo -n $char 


                if ! [[ $char =~ [[:digit:]] ]]; then 
                        return 1
                fi
        done
        return 0
}



# New Primatives based on disatisfaction with with functions:
function navigation_help () {

	:

}


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



function iterate_navigation_list () {

	index=0
	for element in "${STACK[@]}" ; do
		echo $index $element
		let index++
	done
}


function navigation_back () {

		((1)) && {
			echo "Previous Location:  $PREVIOUSLOCATION"
			echo "Current Location:   $CURRENTLOCATION"
		} > /dev/stderr

		cd $PREVIOUSLOCATION	
		PREVIOUSLOCATION=$CURRENTLOCATION
		CURRENTLOCATION=$PWD
}

function navigation_tui () {

	# We've got to use the keyboard to do this

	navigation_kboard


}

function navigation_goto () {
  
	if [ -d ${STACK[$1]} ]; then

		CURRENTLOCATION=${STACK[$1]}
		PREVIOUSLOCATION=$PWD
		cd ${STACK[$1]}
	fi
}

# End User functions

function nav () {

	COMPLETE=0

	if [ $# -eq 0 ] || [ "$1" == 'view' ] || [ "$1" == 'v' ] ; then 

		iterate_navigation_list
		COMPLETE=1
	fi 


	if [ "$1" == 'help' ] || [ "$1" == 'h' ] ; then 

		navigation_help
		COMPLETE=1
	fi 

	if [ "$1" == 'back' ] || [ "$1" == 'b' ] ; then 

		navigation_back
		COMPLETE=1
	fi 

	if [ "$1" == 'tui' ] || [ "$1" == 't' ] ; then 
	
        	navigation_tui
		COMPLETE=1
        fi 


	if [ $# -eq 1 ] && [ $COMPLETE -eq 0 ]; then

		isnum $1 
		val=$?

		echo "Is number: $val" 

		if [ $val -eq 0 ]; then 
			navigation_goto $1
		fi 
	fi


}





stack_cursor () {
	echo $SCURSOR
}


### primative stack interface
stack() {
	index=0
	for element in "${STACK[@]}" ; do
		echo $index $element
		let index++
	done
}

stack_push () {

	# ARG="\"$1\""
	# echo ARG: $ARG
	
	# IFS=$'\n'
	STACK=( "$1" ${STACK[@]} )

	# STACK[0]="hello world"
	# IFS=$' \n\t'
}

stack_pop () {
	STACK[0]=''

	STACK=( ${STACK[@]} )

	:
}
stack_top () {

	echo ${STACK[0]}
}

### advanced stack interface

stack_goto () {

	if [ $# -eq 0 ];then 
		cd ${STACK[0]}
	else 
		cd ${STACK[$1]}
	fi
}

stack_retrieve () {

	:

}

stack_stow () {

	$ROCKET --delete

	for path in ${STACK[@]}; do 
		$ROCKET --push  $path
	done

}
mypath () {

	if [ $# -eq 0 ]; then
		echo $MPATH
	elif [ $# -eq 1 ]; then
		MPATH=$1
	fi
}

mypath_accend () {
	:
}

mypath_decend () {
	:
}




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

function keyNav () {
	keyboard_navigation
}




init_rocket

(($?)) && init_ui

(($?)) && STACK=( `$ROCKET --populate` )

SCURSOR=0 
MPATH=${STACK[0]}

CURRENTLOCATION=$PWD
PREVIOUSLOCATION=$PWD


cat > /dev/null <<EOD

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
