
declare -A maze
declare -A WALLS_MAP=( [-1,0]=s [1,0]=n [0,-1]=e [0,1]=w )
declare -A cell_stack
declare -a CELL_PATTERNS=("#%s#" "%s %s" "#%s#")
declare -a neighbours_array
visited_counter=0

if [ $# -ne 2 ]
then
	echo "Script invocation:"
	echo "sh maze_gen.sh <number_of_rows> <number_of_columns>"
	exit 1
fi

ROW_COUNT=$1
COLUMN_COUNT=$2

function display_maze {
	#clear
	for ((i=0;i<ROW_COUNT;i++)) do
		for ((k=0;k<3;k++)) do
			for ((j=0;j<COLUMN_COUNT;j++)) do
				
				# Reaaally ugly
				
				local char_west=" "
				local char_east=" "
				
				if [ $k -eq 0 ]
				then
					if [[ ${maze[$i,$j]} == *"n"* ]]
					then
						char_west="▒"
					fi
					printf "▒%s▒" "${char_west}"
				fi
				
				if [ $k -eq 1 ]
				then
				
					if [[ ${maze[$i,$j]} == *"w"* ]]
					then
						char_west="▒"
					fi
					
					if [[ ${maze[$i,$j]} == *"e"* ]]
					then
						char_east="▒"
					fi
					
					printf "%s %s" "${char_west}" "${char_east}"
				fi
				
				if [ $k -eq 2 ]
				then
					if [[ ${maze[$i,$j]} == *"s"* ]]
					then
						char_west="▒"
					fi
					printf "▒%s▒" "${char_west}"
				fi
			done
			echo ""
		done
	done
}

function visit_cell {
	local cell_val=${maze[$1]}
	maze[$1]="${cell_val//v}"
	visited_counter=$((visited_counter + 1))
}

function remove_walls {
	local cell_A=$1
	local cell_B=$2
	local coords_A=(${cell_A//,/ })
	local coords_B=(${cell_B//,/ })
	local diff_x=$((${coords_A[1]} - ${coords_B[1]}))
	local diff_y=$((${coords_A[0]} - ${coords_B[0]}))
	local cell_val=${maze[$cell_A]}
	local wall=${WALLS_MAP[$diff_y,$diff_x]}
	maze[$cell_A]="${cell_val//$wall}"
	cell_val=${maze[$cell_B]}
	wall=${WALLS_MAP[$(( -1 * diff_y )),$(( -1 * diff_x ))]}
	maze[$cell_B]="${cell_val//$wall}"
}

function get_unvisited_neighbours {
	local cell_ind=$1
	local coords=(${cell_ind//,/ })
	local indx=$((${coords[0]}))
	local indy=$((${coords[1]}))
	unset neighbours_array
	local arr_len=0
	
	if [[ ${maze[$((indx - 1)),$indy]} == *"v"* ]]
	then
		neighbours_array[$arr_len]="$((indx - 1)),$indy"
		arr_len=$((arr_len + 1))
	fi
	
	if [[ ${maze[$((indx + 1)),$indy]} == *"v"* ]]
	then
		neighbours_array[$arr_len]="$((indx + 1)),$indy"
		arr_len=$((arr_len + 1))
	fi
	
	if [[ ${maze[$indx,$((indy - 1))]} == *"v"* ]]
	then
		neighbours_array[$arr_len]="$indx,$((indy - 1))"
		arr_len=$((arr_len + 1))
	fi
	
	if [[ ${maze[$indx,$((indy + 1))]} == *"v"* ]]
	then
		neighbours_array[$arr_len]="$indx,$((indy + 1))"
		arr_len=$((arr_len + 1))
	fi
	
}

if [ $ROW_COUNT -lt 2 ]
then
	echo "Number of rows must be at least 2!"
	exit 1
fi

if [ $COLUMN_COUNT -lt 2 ]
then
	echo "Number of columns must be at least 2!"
	exit 1
fi

CELL_COUNT=$(( ROW_COUNT * COLUMN_COUNT ))

for ((i=0;i<ROW_COUNT;i++)) do
	for ((j=0;j<COLUMN_COUNT;j++)) do
		maze[$i,$j]="neswv"
	done
done

current_cell="0,0"
cell_stack[$current_cell]="none"
visit_cell $current_cell

#if [ ]; then

while [ $visited_counter -lt $CELL_COUNT ]
do

	get_unvisited_neighbours $current_cell
	ncount=${#neighbours_array[@]}
	next_cell=$current_cell
	
	if [ $ncount -gt 0 ]
	then

		next_cell=${neighbours_array[$((RANDOM % $ncount))]}
		visit_cell $next_cell
		remove_walls $current_cell $next_cell
		cell_stack[$next_cell]=$current_cell

	else

		next_cell=${cell_stack[$current_cell]}
		unset cell_stack[$current_cell]
	
	fi

	current_cell=$next_cell

done

#fi

display_maze

#for ((i=0;i<ROW_COUNT;i++)) do
#	for ((j=0;j<COLUMN_COUNT;j++)) do
#		printf "%s " ${maze[$i,$j]}
#	done
#	echo ""
#done

echo "Number of rows "$ROW_COUNT
echo "Number of columns "$COLUMN_COUNT