#!/usr/local/bin/tclsh


# decent doser UI based on Morphosis graphics
cd "[file dirname [info script]]/"
source "gui.tcl"

array set translation [read_binary_file "translation.tcl"]

##############################

array set page_images {
	"off" "nothing_on.png" \
	"espresso" "espresso_on.png" \
	"steam" "steam_on.png" \
	"water" "tea_on.png" \
	"settings" "settings_on.png" \
}


#set screen_size_width 1280
#set screen_size_height 800
#set screen_size_width 1280
#set screen_size_height 720
#set screen_size_width 2560
#set screen_size_height 1600
#set screen_size_width 1920
#set screen_size_height 1080

proc language {} {
	# the UI language for Decent Espresso is set as the UI language that Android is currently operating in
	global current_language
	if {[info exists current_language] == 0} {
		array set loc [borg locale]
		set current_language $loc(language)
	}

	return $current_language
	#return "en"
	#return "fr"
}

proc translate {english} {

	if {[language] == "en"} {
		return $english
	}

	global translation

	if {[info exists translation($english)] == 1} {
		# this word has been translated
		array set available $translation($english)
		if {[info exists available([language])] == 1} {
			# this word has been translated into the desired non-english language
			return $available([language])
		}
	} 

	# if no translation found, return the english text
	return $english
}

proc setup_environment {} {
	global screen_size_width
	global screen_size_height

	global android
	set android 0
	catch {
		package require ble
		set android 1
	}


	if {$android == 1} {
		package require BLT
		namespace import blt::*
		namespace import -force blt::tile::*

		borg systemui 0x1E02
		borg screenorientation landscape

		wm attributes . -fullscreen 1
		sdltk screensaver off

		set width [winfo screenwidth .]
		set height [winfo screenheight .]

		# sets immersive mode

		#array set displaymetrics [borg displaymetrics]
		if {$width > 2300} {
			set screen_size_width 2560
			if {$height > 1450} {
				set screen_size_height 1600
			} else {
				set screen_size_height 1440
			}
		} elseif {$height > 2300} {
			set screen_size_width 2560
			if {$width > 1440} {
				set screen_size_height 1600
			} else {
				set screen_size_height 1440
			}
		} elseif {$width == 1920} {
			set screen_size_width 1920
			set screen_size_height 1080
		} elseif {$width == 1280} {
			set screen_size_width 1280
			if {$width > 720} {
				set screen_size_height 800
			} else {
				set screen_size_height 720
			}
		} else {
			# unknown resolution type, go with smallest
			set screen_size_width 1280
			set screen_size_height 720
		}



		set helvetica_font [sdltk addfont "HelveticaNeue Light.ttf"]
		puts "helvetica_font: $helvetica_font"
		
		set helvetica_bold_font [sdltk addfont "helvetica-neue-bold.ttf"]
		puts "helveticab_font: $helvetica_bold_font"
		
		set sourcesans_font [sdltk addfont "SourceSansPro-Regular.ttf"]
		puts "sourcesans: $sourcesans_font"

	    font create Helv_4 -family "HelveticaNeue" -size 4
	    font create Helv_8 -family "HelveticaNeue" -size 8
	    font create Helv_10_bold -family "Helvetica Neue" -size 10

		font create Sourcesans_30 -family "Source Sans Pro" -size 10
	    font create Sourcesans_20 -family "Source Sans Pro" -size 6

		sdltk touchtranslate 0
		wm maxsize . $screen_size_width $screen_size_height
		wm minsize . $screen_size_width $screen_size_height

		source "bluetooth.tcl"

	} else {
		set screen_size_width 1280
		set screen_size_height 800
		set screen_size_width 2560
		set screen_size_height 1600

		package require Tk
		package require tkblt
		namespace import blt::*

		wm maxsize . $screen_size_width $screen_size_height
		wm minsize . $screen_size_width $screen_size_height

		font create Helv_4 -family {Helvetica Neue Regular} -size 10
		font create Helv_8 -family {Helvetica Neue Regular} -size 18
		font create Helv_10_bold -family {Helvetica Neue Bold} -size 23
		#font create Helvb_10 -family [list "HelveticaNeue" 5 bold] -size 19
		#font create Helvb_10 -family {Helvetica Neue Regular} -size 19
		#font create Helv_20 -family {Helvetica Neue Regular} -size 20
		
		font create Sourcesans_30 -family {Source Sans Pro Bold} -size 50
		font create Sourcesans_20 -family {Source Sans Pro Bold} -size 22

		proc ble {args} { puts "ble $args" }
		proc borg {args} { 
			if {[lindex $args 0] == "locale"} {
				return [list "language" "en"]
			} elseif {[lindex $args 0] == "log"} {
				# do nothing
			} else {
				puts "borg $args"
			}
		}
		proc de1_send {x} { puts "de1_send '$x'" }
		proc de1_read {} { puts "de1_read" }
		proc app_exit {} { exit	}		

	}
	. configure -bg black 


	############################################
	# define the canvas
	canvas .can -width $screen_size_width -height $screen_size_height -borderwidth 0 -highlightthickness 0
	############################################
}

proc skin_directory {} {

	global screen_size_width
	global screen_size_height

	set dir "skins/default/${screen_size_width}x${screen_size_height}"
	return $dir

}

proc add_visual_item_to_context {context label_name} {
	global existing_labels
	#set context [lindex $args 0]
	set existing_text_labels [ifexists existing_labels($context)]
	lappend existing_text_labels $label_name
	set existing_labels($context) $existing_text_labels
}

proc add_de1_command {bname tclcode x0 y0 x1 y1} {
	set btn_name ".btn_$bname"
	#set btn_name $bname
	.can create rect $x0 $y0 $x1 $y1 -fill {} -outline black -width 0 -tag $btn_name -state hidden
	.can bind $btn_name [platform_button_press] $tclcode
	add_visual_item_to_context $bname $btn_name
}

set add_de1_button_text_cnt 0
proc add_de1_button_text {args} {
	global add_de1_button_text_cnt
	incr add_de1_button_text_cnt

	set context [lindex $args 0]

	set label_name "${context}_$add_de1_button_text_cnt"

	# keep track of what labels are displayed in what contexts
	add_visual_item_to_context $context $label_name

	set torun [concat [list .can create text] [lrange $args 1 end] -tag $label_name -state hidden]
	#puts $torun
	eval $torun
}

proc setup_images_for_first_page {} {
	image create photo splash -file "[skin_directory]/splash.png"
	.can create image {0 0} -anchor nw -image splash  -tag splash -state normal
	pack .can
	update
	return
}




proc setup_images_for_other_pages {} {

	global screen_size_width
	global screen_size_height

	global page_images

	# load each of the PNGs that get displayed for each espresso machine achivity
	foreach {name pngfilename} [array get page_images] {
		image create photo $name -file "[skin_directory]/$pngfilename"
		.can create image {0 0} -anchor nw -image $name  -tag $name -state hidden
	}

	# debug log, will be invisible in release mode
	.can create text 10 10 -text "" -anchor nw -tag .t -fill #666666 -font Helv_4 -width 1000

	# set up the rectangles that define the finger tap zones and the associated command for each 
	source "[skin_directory]/skin.tcl"

	# rectangle to act as a button for the entire screen
	.can create rect 0 0 $screen_size_width $screen_size_height -fill {} -outline black -width 0 -tag .btn_screen -state hidden
}



proc run_de1_app {} {
	page_display_change "splash" "off"
}


proc do_steam {} {
	msg "Make steam"
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list steam_dismiss]
	page_display_change "off" "steam"
	de1_send "S"
}

proc steam_dismiss {} {
	msg "End steam"
	de1_send " "
	enable_all_four_buttons
	page_display_change "steam" "off"
}

proc do_espresso {} {
	msg "Make espresso"
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list espresso_dismiss]
	page_display_change "off" "espresso"
	de1_send "E"
}

proc espresso_dismiss {} {
	msg "End espresso"
	de1_send " "
	enable_all_four_buttons
	page_display_change "espresso" "off"
}

proc do_water {} {
	msg "Make water"
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list water_dismiss]
	page_display_change "off" "water"
	de1_send "H"
}

proc water_dismiss {} {
	msg "End water"
	de1_send " "
	enable_all_four_buttons
	page_display_change "water" "off"
}

proc do_settings {} {
	msg "Make settings"
	disable_all_four_buttons
	.can bind .btn_screen [platform_button_press] [list settings_dismiss]
	page_display_change "off" "settings"
}

proc settings_dismiss {} {
	msg "End settings"
	enable_all_four_buttons
	page_display_change "settings" "off"
}

proc disable_all_four_buttons {} {
	.can itemconfigure ".btn_steam" -state hidden
	.can itemconfigure ".btn_espresso" -state hidden
	.can itemconfigure ".btn_water" -state hidden
	.can itemconfigure ".btn_settings" -state hidden
	.can itemconfigure .btn_screen -state normal
}

proc enable_all_four_buttons {} {
	.can itemconfigure ".btn_steam" -state normal
	.can itemconfigure ".btn_espresso" -state normal
	.can itemconfigure ".btn_water" -state normal
	.can itemconfigure ".btn_settings" -state normal
	.can itemconfigure .btn_screen -state hidden
}

proc page_display_change {page_to_hide page_to_show} {
	foreach image $page_to_show	 {
		.can itemconfigure $image -state normal
	}	
	foreach image $page_to_hide	 {
		.can itemconfigure $image -state hidden
	}	

	global existing_labels
	foreach {context labels} [array get existing_labels] {

		foreach label $labels  {
			if {$context == $page_to_show || $page_to_show == "off"} {
				# leave these displayed
				.can itemconfigure $label -state normal
			} else {
				# hide these labels 
				.can itemconfigure $label -state hidden
			}
		}
	}

}

proc load_android_wifi_settings {} {
	borg toast "Tap the \u25C0BACK\u25B6 BUTTON to return to\nDecent Espresso." 1
	after 500 { borg activity android.settings.WIFI_SETTINGS {} {} {} {} {} }
}


setup_environment
setup_images_for_first_page
#msg "height: $height - width: $width"
#update
setup_images_for_other_pages
#update
if {$android == 1} {
	ble_connect_to_de1
	
} else {
	after 100 run_de1_app
}
#run_de1_app

#pack .can
vwait forever
