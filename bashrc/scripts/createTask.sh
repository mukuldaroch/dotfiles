#!/bin/bash

# ---------------- COLORS ----------------
# RESET
reset="\e[0m"

# BASIC COLORS
black="\e[30m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
magenta="\e[35m"
cyan="\e[36m"
white="\e[37m"

# BRIGHT COLORS
bright_black="\e[90m"
bright_red="\e[91m"
bright_green="\e[92m"
bright_yellow="\e[93m"
bright_blue="\e[94m"
bright_magenta="\e[95m"
bright_cyan="\e[96m"
bright_white="\e[97m"

# ---------------- STATE VARIABLES ----------------
#

# Task fields
description="" # task description (string)
priorities=("H" "M" "L")
priority="" # default priority=""

project="" # selected project

# Date stored as array: [year month day hour minute]
now=($(date "+%Y %m %d %H %M"))

scheduled=("${now[@]}")
due=("${now[@]}")

#flags to chedk if the scheduled or due date are edited or not
scheduled_set=false
due_set=false

date_mode="full" # full | quick

# Which part of date we are editing (0=year, 1=month, etc.)
date_index=0

# Main menu options
main_options=("Description" "Project" "Priority" "Scheduled" "Due" "Create Task" "leadtime")

# Current cursor position in main menu
main_index=0

# Fetch existing projects from taskwarrior
mapfile -t projects < <(task _projects)

# Add option to create new project at top
projects=("<< Create New Project >>" "${projects[@]}")

# Cursor position inside project list
project_index=0

# App mode (controls which screen is shown)
mode="main" # possible: main | project_select | date_edit | priority_select

# Which date we are editing
editing_date="scheduled"

# ---------------- INPUT HANDLING ----------------

read_key() {
	# Read a single character silently
	IFS= read -rsn1 key

	# Ctrl + K (ASCII vertical tab)
	if [[ $key == $'\x0b' ]]; then
		echo "CTRL_K"
		return
	fi

	# Ctrl + J OR Enter (both send newline)
	if [[ $key == "" ]]; then
		# Try to distinguish (not perfect)
		read -rsn1 -t 0.001 next

		if [[ -z "$next" ]]; then
			echo "ENTER"
		else
			echo "CTRL_J"
		fi
		return
	fi

	# Normal key (j, k, h, l, etc.)
	echo "$key"
}

# ---------------- UI HELPERS ----------------

format_date() {
	# Convert array -> readable format
	local d=("$@")

	# Format: YYYY-MM-DD HH:MM
	printf "%04d-%02d-%02dT%02d:%02d" \
		"${d[0]}" "${d[1]}" "${d[2]}" "${d[3]}" "${d[4]}"
}
format_date_ui() {
	# Convert array -> readable format
	local d=("$@")

	# Format: YYYY-MM-DD HH:MM
	printf "%04d-%02d-%02d ${red}%02d:%02d${reset}" \
		"$((10#${d[0]}))" \
		"$((10#${d[1]}))" \
		"$((10#${d[2]}))" \
		"$((10#${d[3]}))" \
		"$((10#${d[4]}))"
}

leadtime() {
	local s=("$1" "$2" "$3" "$4" "$5")
	local d=("$6" "$7" "$8" "$9" "${10}")

	# Convert to epoch seconds
	local s_epoch=$(date -d "${s[0]}-${s[1]}-${s[2]} ${s[3]}:${s[4]}" +%s)
	local d_epoch=$(date -d "${d[0]}-${d[1]}-${d[2]} ${d[3]}:${d[4]}" +%s)

	# Difference (scheduled - due)
	local diff=$((s_epoch - d_epoch))

	# Sign handling
	local sign=""
	if ((diff < 0)); then
		sign="${red}-"
		diff=$((-diff))
	else
		sign="${yellow} "
	fi

	# Convert seconds → days, hours, minutes
	local days=$((diff / 86400))
	local hours=$(((diff % 86400) / 3600))
	local mins=$(((diff % 3600) / 60))

	printf "%s%dd %02d:%02d\n" "$sign" "$days" "$hours" "$mins"
}

# ---------------- UI SCREENS ----------------

draw_main() {
	clear
	echo "=== Task Creator ==="
	echo

	# Loop through menu items
	for i in "${!main_options[@]}"; do
		prefix="  "

		# Highlight current selection
		[[ $i -eq $main_index ]] && prefix="> "

		case $i in
		0) echo -e "$prefix Description:${cyan} ${description:-<>} ${reset}" ;;
		1) echo -e "$prefix Project:    ${red} ${project:-${cyan}<>} ${reset}" ;;
		2) echo -e "$prefix Priority:   ${red} ${priority:-${cyan}<>} ${reset}" ;;
		3)
			if $scheduled_set; then
				echo -e "$prefix Scheduled:   ${green} $(format_date_ui "${scheduled[@]}") ${reset}"
			else
				echo -e "$prefix Scheduled:   ${cyan}<> ${reset}"
			fi
			;;
		4)
			if $due_set; then
				echo -e "$prefix Due:         ${green} $(format_date_ui "${due[@]}") ${reset}"
			else
				echo -e "$prefix Due:         ${cyan}<> ${reset}"
			fi
			;;
		5)
			if $due_set; then
				echo -e "${cyan}$prefix                     ${cyan} $(leadtime "${due[@]}" "${scheduled[@]}") ${reset}"
			else
				echo -e "${cyan}$prefix              00:00 ${reset}"
			fi
			;;
		6) echo -e "$prefix ${green}[< Create Task >]${reset}" ;;
		esac
	done

	# echo
	# echo "j/k: move | Enter: select | q: quit"
}

draw_priority_select() {
	clear
	echo "=== Select Priority ==="
	echo

	for i in "${!priorities[@]}"; do
		prefix="  "
		[[ $i -eq $priority_index ]] && prefix="> "

		echo "$prefix ${priorities[$i]}"
	done
}

draw_project_select() {
	clear
	echo "=== Select Project ==="
	echo

	for i in "${!projects[@]}"; do
		prefix="  "
		[[ $i -eq $project_index ]] && prefix="> "

		# Show each project
		echo "$prefix ${projects[$i]}"
	done
}

draw_full_date_editor() {
	clear

	# Get reference to array passed (scheduled or due)
	local arr=("${!1}")
	labels=("Year  " "Month " "Date  " "Hour  " "Minute")

	echo "=== Editing $editing_date ==="
	echo

	# Show each date component
	for i in "${!arr[@]}"; do
		if [[ $i -eq $date_index ]]; then
			# Highlight current field
			printf "> %s: %02d\n" "${labels[$i]}" "${arr[$i]}"
		else
			printf "  %s: %02d\n" "${labels[$i]}" "${arr[$i]}"
		fi
	done
}

draw_quick_date_editor() {
	clear

	local arr=("${!1}")

	# Mapping indexes: hour(3), day(2), month(1)
	indices=(3 4 2)
	labels=("Hour  " "Minute" "Date  ")

	echo "=== Editing $editing_date (QUICK) ==="
	echo

	for i in "${!indices[@]}"; do
		actual_index=${indices[$i]}

		if [[ $i -eq $date_index ]]; then
			printf "> %s: %02d\n" "${labels[$i]}" "$((10#${arr[$actual_index]}))"
		else
			printf "  %s: %02d\n" "${labels[$i]}" "$((10#${arr[$actual_index]}))"
		fi
	done
}

# ---------------- DATE LOGIC ----------------

adjust_date() {
	# Reference to actual array (scheduled/due)
	local -n ref=$1

	# Increment/decrement selected field
	case $date_index in
	0) ((ref[0] += $2)) ;; # year
	1) ((ref[1] += $2)) ;; # month
	2) ((ref[2] += $2)) ;; # day
	3) ((ref[3] += $2)) ;; # hour
	4) ((ref[4] += $2)) ;; # minute
	5) ((ref[5] += $2)) ;; # seconds
	esac

	# Basic bounds correction

	# Month (1–12)
	[[ ${ref[1]} -lt 1 ]] && ref[1]=12
	[[ ${ref[1]} -gt 12 ]] && ref[1]=1

	# Day (1–31) (simplified)
	[[ ${ref[2]} -lt 1 ]] && ref[2]=31
	[[ ${ref[2]} -gt 31 ]] && ref[2]=1

	# Hour (0–23)
	[[ ${ref[3]} -lt 0 ]] && ref[3]=23
	[[ ${ref[3]} -gt 23 ]] && ref[3]=0

	# Minute (0–59)
	[[ ${ref[4]} -lt 0 ]] && ref[4]=59
	[[ ${ref[4]} -gt 59 ]] && ref[4]=0
}
quick_date_adjust() {
	# Reference to actual array (scheduled/due)
	local -n ref=$1

	# Increment/decrement selected field
	case $date_index in
	0) ((ref[3] += $2)) ;; # hour
	1) ((ref[4] += $2)) ;; # minute
	2) ((ref[2] += $2)) ;; # day
	esac

	# Basic bounds correction

	# Hour (0–23)
	[[ ${ref[3]} -lt 0 ]] && ref[3]=23
	[[ ${ref[3]} -gt 23 ]] && ref[3]=0

	# Minute (0–59)
	[[ ${ref[4]} -lt 0 ]] && ref[4]=59
	[[ ${ref[4]} -gt 59 ]] && ref[4]=0

	# Day (1–31) (simplified)
	[[ ${ref[2]} -lt 1 ]] && ref[2]=31
	[[ ${ref[2]} -gt 31 ]] && ref[2]=1

}

# ---------------- MAIN LOOP ----------------

while true; do

	# Render UI based on mode
	case $mode in
	main) draw_main ;;
	project_select) draw_project_select ;;
	priority_select) draw_priority_select ;;
	date_edit)
		if [[ "$editing_date" == "scheduled" ]]; then
			draw_full_date_editor scheduled[@]
		else
			draw_full_date_editor due[@]
		fi
		;;
	quick_date_edit)
		if [[ "$editing_date" == "scheduled" ]]; then
			draw_quick_date_editor scheduled[@]
		else
			draw_quick_date_editor due[@]
		fi
		;;
	esac

	# Read user input
	key=$(read_key)

	case "$mode" in

	# -------- MAIN SCREEN --------
	main)
		case "$key" in

		# Move down
		j)
			((main_index++))
			[[ $main_index -ge ${#main_options[@]} ]] && main_index=0
			;;

		# Move up
		k)
			((main_index--))
			[[ $main_index -lt 0 ]] && main_index=$((${#main_options[@]} - 1))
			;;

		# Select option
		l)
			case $main_index in
			0) read -p "Enter description: " description ;;
			1) mode="project_select" ;;
			2) mode="priority_select" ;;
			3)
				mode="quick_date_edit"
				editing_date="scheduled"
				;;
			4)
				mode="quick_date_edit"
				editing_date="due"
				;;
			6)
				echo "Creating task..."

				cmd=(task add "$description")

				[[ -n "$project" ]] && cmd+=(project:"$project")
				[[ -n "$priority" ]] && cmd+=(priority:"$priority")

				if $scheduled_set; then
					sch=$(format_date "${scheduled[@]}")
					cmd+=(scheduled:"$sch")
				fi

				if $due_set; then
					du=$(format_date "${due[@]}")
					cmd+=(due:"$du")
				fi

				"${cmd[@]}"

				exit 0
				;;
			esac
			;;
		e)
			case $main_index in
			3)
				mode="date_edit"
				editing_date="scheduled"
				;;
			4)
				mode="date_edit"
				editing_date="due"
				;;
			esac
			;;
		c)
			case $main_index in
			# 0) read -p "Enter description: " description ;;
			# 1) mode="project_select" ;;
			# 2) mode="priority_select" ;;
			3)
				scheduled_set=false
				;;
			4)
				due_set=false
				;;
			esac
			;;
		s)
			case $main_index in
			3)
				mode="main"
				[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
				;;
			4)
				mode="main"
				[[ "$editing_date" == "due" ]] && due_set=true
				;;
			esac
			;;

		ENTER)
			echo "Creating task..."

			cmd=(task add "$description")

			[[ -n "$project" ]] && cmd+=(project:"$project")
			[[ -n "$priority" ]] && cmd+=(priority:"$priority")

			if $scheduled_set; then
				sch=$(format_date "${scheduled[@]}")
				cmd+=(scheduled:"$sch")
			fi

			if $due_set; then
				du=$(format_date "${due[@]}")
				cmd+=(due:"$du")
			fi

			"${cmd[@]}"

			exit 0
			;;

		q) exit 0 ;;
		esac
		;;

	# -------- PROJECT SELECT --------
	project_select)
		case "$key" in
		j)
			((project_index++))
			[[ $project_index -ge ${#projects[@]} ]] && project_index=0
			;;
		k)
			((project_index--))
			[[ $project_index -lt 0 ]] && project_index=$((${#projects[@]} - 1))
			;;
		l)
			if [[ $project_index -eq 0 ]]; then
				read -p "New project: " project
			else
				project="${projects[$project_index]}"
			fi
			mode="main"
			;;
		ENTER)
			if [[ $project_index -eq 0 ]]; then
				read -p "New project: " project
			else
				project="${projects[$project_index]}"
			fi
			mode="main"
			;;
		h) mode="main" ;;
		q) mode="main" ;;
		esac
		;;

	# -------- PROJECT SELECT --------
	priority_select)
		case "$key" in
		j)
			((priority_index++))
			[[ $priority_index -ge ${#priorities[@]} ]] && priority_index=0
			;;
		k)
			((priority_index--))
			[[ $priority_index -lt 0 ]] && priority_index=$((${#priorities[@]} - 1))
			;;
		l)
			priority="${priorities[$priority_index]}"
			mode="main"
			;;
		h)
			mode="main"
			;;
		q)
			mode="main"
			;;
		esac
		;;

	# -------- DATE EDITOR --------
	date_edit)
		if [[ "$editing_date" == "scheduled" ]]; then
			ref="scheduled"
		else
			ref="due"
		fi
		case "$key" in
		i)
			adjust_date "$ref" 1
			[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
			[[ "$editing_date" == "due" ]] && due_set=true
			;;
		d)
			adjust_date "$ref" -1
			[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
			[[ "$editing_date" == "due" ]] && due_set=true
			;;

		k)
			((date_index--))
			[[ $date_index -lt 0 ]] && date_index=4
			;;
		j)
			((date_index++))
			[[ $date_index -gt 4 ]] && date_index=0
			;;
		h)
			mode="main"
			;;
		ENTER)
			mode="main"
			[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
			[[ "$editing_date" == "due" ]] && due_set=true
			;;

		l)
			mode="main"
			[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
			[[ "$editing_date" == "due" ]] && due_set=true
			;;
		esac
		;;

	quick_date_edit)
		if [[ "$editing_date" == "scheduled" ]]; then
			ref="scheduled"
		else
			ref="due"
		fi
		case "$key" in
		i)
			quick_date_adjust "$ref" 1
			[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
			[[ "$editing_date" == "due" ]] && due_set=true
			;;
		d)
			quick_date_adjust "$ref" -1
			[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
			[[ "$editing_date" == "due" ]] && due_set=true
			;;

		k)
			((date_index--))
			[[ $date_index -lt 0 ]] && date_index=2
			;;
		j)
			((date_index++))
			[[ $date_index -gt 2 ]] && date_index=0
			;;
		h)
			mode="main"
			;;
		ENTER)
			mode="main"
			[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
			[[ "$editing_date" == "due" ]] && due_set=true
			;;

		l)
			mode="main"
			[[ "$editing_date" == "scheduled" ]] && scheduled_set=true
			[[ "$editing_date" == "due" ]] && due_set=true
			;;
		esac
		;;
	esac
done
