#!/bin/bash

# ---------------- REQUIRED ----------------
task_id="$1"

if [[ -z "$task_id" ]]; then
	echo "Usage: $0 <task_id>"
	exit 1
fi

# ---------------- COLORS ----------------
reset="\e[0m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
cyan="\e[36m"

# ---------------- SAFE HELPERS ----------------

safe_num() {
	local val="$1"
	[[ -z "$val" ]] && echo 0 && return
	echo $((10#$val))
}

# ---------------- STATE ----------------

description=""
priorities=("H" "M" "L")
priority=""
project=""

scheduled=()
due=()

scheduled_set=false
due_set=false

date_index=0
main_index=0

main_options=("Description" "Project" "Priority" "Scheduled" "Due" "Modify Task")

mapfile -t projects < <(task _projects)
projects=("<< Create New Project >>" "${projects[@]}")
project_index=0

mode="main"
editing_date="scheduled"

# ---------------- LOAD TASK ----------------

load_task() {
	local id="$1"

	task_json=$(task "$id" export)

	if [[ -z "$task_json" || "$task_json" == "[]" ]]; then
		echo "❌ Task not found"
		exit 1
	fi

	description=$(echo "$task_json" | jq -r '.[0].description // ""')
	project=$(echo "$task_json" | jq -r '.[0].project // ""')
	priority=$(echo "$task_json" | jq -r '.[0].priority // ""')

	sch=$(echo "$task_json" | jq -r '.[0].scheduled // empty')
	if [[ -n "$sch" ]]; then
		mapfile -t tmp < <(date -d "$sch" "+%Y %m %d %H %M" 2>/dev/null)
		if [[ ${#tmp[@]} -eq 5 ]]; then
			scheduled=("${tmp[@]}")
			scheduled_set=true
		fi
	fi

	du=$(echo "$task_json" | jq -r '.[0].due // empty')
	if [[ -n "$du" ]]; then
		mapfile -t tmp < <(date -d "$du" "+%Y %m %d %H %M" 2>/dev/null)
		if [[ ${#tmp[@]} -eq 5 ]]; then
			due=("${tmp[@]}")
			due_set=true
		fi
	fi
}

load_task "$task_id"

# ---------------- INPUT ----------------

read_key() {
	IFS= read -rsn1 key
	[[ $key == "" ]] && echo "ENTER" && return
	echo "$key"
}

# ---------------- FORMAT ----------------

format_date() {
	local d=("$@")
	printf "%04d-%02d-%02dT%02d:%02d" \
		"$(safe_num "${d[0]}")" \
		"$(safe_num "${d[1]}")" \
		"$(safe_num "${d[2]}")" \
		"$(safe_num "${d[3]}")" \
		"$(safe_num "${d[4]}")"
}

format_date_ui() {
	local d=("$@")
	printf "%04d-%02d-%02d ${red}%02d:%02d${reset}" \
		"$(safe_num "${d[0]}")" \
		"$(safe_num "${d[1]}")" \
		"$(safe_num "${d[2]}")" \
		"$(safe_num "${d[3]}")" \
		"$(safe_num "${d[4]}")"
}

# ---------------- UI ----------------

draw_main() {
	clear
	echo "=== Edit Task (#$task_id) ==="
	echo

	for i in "${!main_options[@]}"; do
		prefix="  "
		[[ $i -eq $main_index ]] && prefix="> "

		case $i in
		0) echo -e "$prefix Description: ${cyan}${description:-<>}${reset}" ;;
		1) echo -e "$prefix Project:    ${cyan}${project:-<>}${reset}" ;;
		2) echo -e "$prefix Priority:   ${cyan}${priority:-<>}${reset}" ;;
		3)
			if $scheduled_set; then
				echo -e "$prefix Scheduled: ${green}$(format_date_ui "${scheduled[@]}")${reset}"
			else
				echo -e "$prefix Scheduled: ${cyan}<>${reset}"
			fi
			;;
		4)
			if $due_set; then
				echo -e "$prefix Due:       ${green}$(format_date_ui "${due[@]}")${reset}"
			else
				echo -e "$prefix Due:       ${cyan}<>${reset}"
			fi
			;;
		5) echo -e "$prefix ${green}[< Modify Task >]${reset}" ;;
		esac
	done
}

# ---------------- DATE ----------------

adjust_date() {
	local -n ref=$1

	case $date_index in
	0) ((ref[0] += $2)) ;;
	1) ((ref[1] += $2)) ;;
	2) ((ref[2] += $2)) ;;
	3) ((ref[3] += $2)) ;;
	4) ((ref[4] += $2)) ;;
	esac
}

# ---------------- LOOP ----------------

while true; do

	draw_main
	key=$(read_key)

	case "$key" in

	j)
		((main_index++))
		[[ $main_index -ge ${#main_options[@]} ]] && main_index=0
		;;

	k)
		((main_index--))
		[[ $main_index -lt 0 ]] && main_index=$((${#main_options[@]} - 1))
		;;

	l)
		case $main_index in
		0) read -p "Description: " description ;;
		1) read -p "Project: " project ;;
		2) read -p "Priority (H/M/L): " priority ;;
		3)
			read -p "Scheduled (YYYY-MM-DD HH:MM): " input
			mapfile -t scheduled < <(date -d "$input" "+%Y %m %d %H %M" 2>/dev/null)
			[[ ${#scheduled[@]} -eq 5 ]] && scheduled_set=true || echo "❌ Invalid date"
			;;
		4)
			read -p "Due (YYYY-MM-DD HH:MM): " input
			mapfile -t due < <(date -d "$input" "+%Y %m %d %H %M" 2>/dev/null)
			[[ ${#due[@]} -eq 5 ]] && due_set=true || echo "❌ Invalid date"
			;;
		5)
			echo "Updating task..."

			if [[ -z "$description" ]]; then
				echo "❌ Description cannot be empty"
				sleep 1
				continue
			fi

			cmd=(task "$task_id" modify "$description")

			[[ -n "$project" ]] && cmd+=(project:"$project")
			[[ -n "$priority" ]] && cmd+=(priority:"$priority")

			$scheduled_set && cmd+=(scheduled:"$(format_date "${scheduled[@]}")")
			$due_set && cmd+=(due:"$(format_date "${due[@]}")")

			"${cmd[@]}"
			exit 0
			;;
		esac
		;;

	q) exit 0 ;;
	esac
done
