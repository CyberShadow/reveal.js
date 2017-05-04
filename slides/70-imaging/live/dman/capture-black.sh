sleep 5
for x in $(seq 0 24)
do
	xdotool key space
	sleep 0.5 
	maim -g210x333+212+62 > black-$(printf '%02d' $x).png
	sleep 0.5
done
