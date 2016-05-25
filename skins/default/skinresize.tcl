#!/usr/local/bin/tclsh 

proc fast_write_open {fn parms} {
    set f [open $fn $parms]
    fconfigure $f -blocking 0
    fconfigure $f -buffersize 1000000
    return $f
}

proc write_file {filename data} {
    set fn [fast_write_open $filename w]
    puts $fn $data 
    close $fn
    return 1
}

proc read_file {filename} {
    set fn [open $filename]
    set data [read $fn]
    close $fn
    return $data
}

proc regsubex {regex in replace} {
	set escaped [string map {\[ \\[ \] \\] \$ \\$ \\ \\\\} $in]
	regsub -all $regex $escaped $replace result
	set result [subst $result]
	return $result
}

puts "Resizing skin 2560x1600 -> 1280x800"
cd 2560x1600
exec convert nothing_on.png -resize 1280x800!  ../1280x800/nothing_on.png
exec convert espresso_on.png -resize 1280x800!  ../1280x800/espresso_on.png
exec convert settings_on.png -resize 1280x800!  ../1280x800/settings_on.png
exec convert splash.png -resize 1280x800!  ../1280x800/splash.png
exec convert steam_on.png -resize 1280x800!  ../1280x800/steam_on.png
exec convert tea_on.png -resize 1280x800!  ../1280x800/tea_on.png

set newskin [read_file "skin.tcl"]
set newskin [regsubex {add_de1_button_text (".*?") ([0-9]+) ([0-9]+) } $newskin {add_de1_button_text \1 [expr {\2/2}] [expr {\3/2}] }]
set newskin [regsubex {add_de1_command (".*?") (.*?) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)\n} $newskin {add_de1_command \1 \2 [expr {\3/2}] [expr {\4/2}] [expr {\5/2}] [expr {\6/2}]\n}]
set newskin [regsubex {\-width ([0-9]+)} $newskin {-width [expr {\1/2}]}]
write_file "../1280x800/skin.tcl" $newskin 

cd ..

cd 2560x1440
puts "Resizing skin 2560x1440 -> 1280x720"
exec convert nothing_on.png -resize 1280x720!  ../1280x720/nothing_on.png
exec convert espresso_on.png -resize 1280x720!  ../1280x720/espresso_on.png
exec convert settings_on.png -resize 1280x720!  ../1280x720/settings_on.png
exec convert splash.png -resize 1280x720!  ../1280x720/splash.png
exec convert steam_on.png -resize 1280x720!  ../1280x720/steam_on.png
exec convert tea_on.png -resize 1280x720!  ../1280x720/tea_on.png

set newskin [read_file "skin.tcl"]
set newskin [regsubex {add_de1_button_text (".*?") ([0-9]+) ([0-9]+) } $newskin {add_de1_button_text \1 [expr {\2/2}] [expr {\3/2}] }]
set newskin [regsubex {add_de1_command (".*?") (.*?) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)\n} $newskin {add_de1_command \1 \2 [expr {\3/2}] [expr {\4/2}] [expr {\5/2}] [expr {\6/2}]\n}]
set newskin [regsubex {\-width ([0-9]+)} $newskin {-width [expr {\1/2}]}]
write_file "../1280x720/skin.tcl" $newskin 


puts "Resizing skin 2560x1440 -> 1920x1080"
exec convert nothing_on.png -resize 1920x1080!  ../1920x1080/nothing_on.png
exec convert espresso_on.png -resize 1920x1080!  ../1920x1080/espresso_on.png
exec convert settings_on.png -resize 1920x1080!  ../1920x1080/settings_on.png
exec convert splash.png -resize 1920x1080!  ../1920x1080/splash.png
exec convert steam_on.png -resize 1920x1080!  ../1920x1080/steam_on.png
exec convert tea_on.png -resize 1920x1080!  ../1920x1080/tea_on.png

set newskin [read_file "skin.tcl"]
set newskin [regsubex {add_de1_button_text (".*?") ([0-9]+) ([0-9]+) } $newskin {add_de1_button_text \1 [expr {int(\2/1.33)}] [expr {int(\3/1.33)}] }]
set newskin [regsubex {add_de1_command (".*?") (.*?) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)\n} $newskin {add_de1_command \1 \2 [expr {int(\3/1.33)}] [expr {int(\4/1.33)}] [expr {int(\5/1.33)}] [expr {int(\6/1.33)}]\n}]
set newskin [regsubex {\-width ([0-9]+)} $newskin {-width [expr {int(\1/1.33)}]}]
write_file "../1920x1080/skin.tcl" $newskin 

cd ..

puts "done"