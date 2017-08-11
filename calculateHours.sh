#!/bin/bash

sed -i .bak 's/AM/ &/g' hours.txt

sed -i .bak 's/PM/ &/g' hours.txt

sed -i .bak 's/  */ /g' hours.txt

# fixes a hard to notice mistake
sed -i .bak 's/;/:/g' hours.txt

awk '
function time_to_hours(hours, mins, am_pm) {
    return_hours = hours + (mins / 60);

    add_hours_bool = 0;
    if ((toupper(am_pm) == "AM") && (hours == 12) && (mins == 0)) {
        add_hours_bool = 1; # midnight
    } else if ((toupper(am_pm) == "PM") && (hours != 12)) {
        add_hours_bool = 1; # afternoon
    }

    if (add_hours_bool) {
        return_hours = return_hours + 12;
    }

    return return_hours;
}
BEGIN {
    # config
    hours_decimal_precision = 2;

	total_hours = 0;
	i = 0;
	start_hours = 0;
    end_hours = 0;
}
{
    while (match($0, /((1[0-2]|0?[1-9]):([0-5][0-9]) ([AaPp][Mm]))/)) {
        time = substr($0, RSTART, RLENGTH);

        split(time,hours_and_rest,":");
        split(hours_and_rest[2],minutes_and_am_pm," ");

        if (i % 2) {
            end_hours = time_to_hours(hours_and_rest[1], minutes_and_am_pm[1], minutes_and_am_pm[2]);
            total_hours = total_hours + (end_hours - start_hours);

            # set to 0 for clarity
            start_hours = 0;
            end_hours = 0;
        } else {
            start_hours = time_to_hours(hours_and_rest[1], minutes_and_am_pm[1], minutes_and_am_pm[2]);
        }

        $0 = substr($0, RSTART + RLENGTH);

        i = i + 1;
    }
}
END {
	printf("%."hours_decimal_precision"f\n", total_hours);
}' hours.txt