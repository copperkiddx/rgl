#!/bin/bash

# Random Game Launcher
# by copperkiddx <copperkiddx@gmail.com>

#=========   USER OPTIONS   =========

fat_or_usb0="usb0" # Location of your ROMS: Use "fat" for microSD or "usb0" for hard drive
hide_rom_name_on_launch="1" # Use "0" to display the game name upon launch OR "1" to display "???" instead of the game name

#=========   END USER OPTIONS   =========

#=========   FUNCTIONS   =========

checkDependencies () {
    config_folder="/media/fat/Scripts/.rgl"
    [ ! -d "$config_folder" ] && mkdir "$config_folder" # If config folder doesn't exist, create it
    cd $config_folder
    
    if [[ ! -f "/media/fat/Scripts/.mister_batch_control/mbc" ]] # If mbc does not exist, download it
    then
        clear
        ping -c 1 8.8.8.8 &>/dev/null; [ "$?" != "0" ] && clear && printf "ERROR: No internet connection - Missing dependencies cannot be installed. Please try again\n\n" && exit 126 # Test internet
        printf "Installing missing dependencies from Github (mbc)..."
        mkdir /media/fat/Scripts/.mister_batch_control
        #wget -qP /media/fat/Scripts/.mister_batch_control "https://github.com/pocomane/MiSTer_Batch_Control/releases/download/untagged-533dda82c9fd24faa6f1/mbc"
        wget -qP /media/fat/Scripts/.mister_batch_control "https://github.com/pocomane/MiSTer_Batch_Control/releases/download/untagged-c2d04013d6822212fd25/mbc"
        sleep 1
        #if md5sum --status -c <(echo ea32cf0d76812a9994b27365437393f2 /media/fat/Scripts/.mister_batch_control/mbc) # Check md5sum with exact mbc file
        if md5sum --status -c <(echo 9c86b26ae28b266ab5f7b63e95020158 /media/fat/Scripts/.mister_batch_control/mbc) # Check md5sum with exact mbc file
        then
            clear
            printf "SUCCESS! Installed to \"/media/fat/Scripts/.mister_batch_control\""
            sleep 2
        else
            clear
            printf "ERROR: md5sum for MiSTer_Batch_Control binary is bad, exiting\n\n"
            exit 126
        fi
    fi
}

loadRandomRom () {
    total_roms="`cat rom_count_all.txt`"
    random_number="$(( $RANDOM % $total_roms + 1 ))"
    random_rom_path="`sed -n "$random_number"p rom_paths_all.txt`"
    random_rom_filename="`echo "${random_rom_path##*/}"`"
    random_rom_extension="`echo "${random_rom_filename##*.}"`"

    if [ $hide_rom_name_on_launch -eq 1 ]; then random_rom_filename="???"; fi
    clear
    printf "Now loading...\n\n$random_number / $total_roms: $random_rom_filename\n\n"
    sleep 2

    # load random ROM # https://raw.githubusercontent.com/pocomane/MiSTer_Batch_Control/master/mbc.c
    if [[ $random_rom_extension == "bin" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "MEGADRIVE.BIN" "$random_rom_path"
    elif [[ $random_rom_extension == "fds" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "NES.FDS" "$random_rom_path"
    elif [[ $random_rom_extension == "gb" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "GAMEBOY" "$random_rom_path"
    elif [[ $random_rom_extension == "gba" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "GBA" "$random_rom_path"
    elif [[ $random_rom_extension == "gbc" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "GAMEBOY.COL" "$random_rom_path"
    elif [[ $random_rom_extension == "gen" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "GENESIS" "$random_rom_path"
    elif [[ $random_rom_extension == "md" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "MEGADRIVE" "$random_rom_path"
    elif [[ $random_rom_extension == "neo" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "NEOGEO" "$random_rom_path"
    elif [[ $random_rom_extension == "nes" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "NES" "$random_rom_path"
    elif [[ $random_rom_extension == "pce" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "TGFX16" "$random_rom_path"        
    elif [[ $random_rom_extension == "sfc" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "SNES" "$random_rom_path"
    elif [[ $random_rom_extension == "smc" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "SNES" "$random_rom_path"
    elif [[ $random_rom_extension == "sms" ]]; then
        /media/fat/Scripts/.mister_batch_control/mbc load_rom "SMS" "$random_rom_path"
    else
        printf "Something went wrong... exiting";
        exit 1
    fi
}

scanRoms () {
    printf "\n\nScanning GAMEBOY ROMS... "
        find "/media/$fat_or_usb0/games/GAMEBOY" -iregex '.*\.\(gb\|gbc\)$' ! -name '*[Rr][Ee][Aa][Dd][Mm][Ee]*' -exec ls >> "rom_paths_all.txt" {} \;
    printf "Done\n\n"

    printf "Scanning GBA ROMS... "
        find "/media/$fat_or_usb0/games/GBA" -iregex '.*\.\(gba\)$' ! -name '*[Rr][Ee][Aa][Dd][Mm][Ee]*' -exec ls >> "rom_paths_all.txt" {} \;
    printf "Done\n\n"

    printf "Scanning Genesis ROMS... "
        find "/media/$fat_or_usb0/games/Genesis" -iregex '.*\.\(bin\|gen\|md\)$' ! -name '*[Rr][Ee][Aa][Dd][Mm][Ee]*' -exec ls >> "rom_paths_all.txt" {} \;
    printf "Done\n\n"

    printf "Scanning NEOGEO ROMS... "
        find "/media/$fat_or_usb0/games/NEOGEO" -iregex '.*\.\(neo\)$' ! -name '*[Rr][Ee][Aa][Dd][Mm][Ee]*' -exec ls >> "rom_paths_all.txt" {} \;
    printf "Done\n\n"

    printf "Scanning NES ROMS... "
        find "/media/$fat_or_usb0/games/NES" -iregex '.*\.\(nes\|fds\)$' ! -name '*[Rr][Ee][Aa][Dd][Mm][Ee]*' -exec ls >> "rom_paths_all.txt" {} \;
    printf "Done\n\n"

    printf "Scanning SMS ROMS... "
        find "/media/$fat_or_usb0/games/SMS" -iregex '.*\.\(sms\)$' ! -name '*[Rr][Ee][Aa][Dd][Mm][Ee]*' -exec ls >> "rom_paths_all.txt" {} \;
    printf "Done\n\n"

    printf "Scanning SNES ROMS... "
        find "/media/$fat_or_usb0/games/SNES" -iregex '.*\.\(sfc\|smc\)$' ! -name '*[Rr][Ee][Aa][Dd][Mm][Ee]*' -exec ls >> "rom_paths_all.txt" {} \;
    printf "Done\n\n"

    printf "Scanning TGFX16 ROMS... "
        find "/media/$fat_or_usb0/games/TGFX16" -iregex '.*\.\(pce\)$' ! -name '*[Rr][Ee][Aa][Dd][Mm][Ee]*' -exec ls >> "rom_paths_all.txt" {} \;
    printf "Done\n\n"

    # generate line count and export to rom_count_$console.txt
    cat "rom_paths_all.txt" | sed '/^\s*$/d' | wc -l > "rom_count_all.txt"
    total_roms="`cat rom_count_all.txt`"
    clear
    printf "Scan complete - ROMS found: $total_roms\n\n"
    sleep 1
    # create scanned_$console file to stop from scanning again (unless files are added/deleted)
    touch "scanned_all"
}

#=========   END FUNCTIONS   =========

#=========   BEGIN MAIN PROGRAM   =========

# If the console has already been scanned, check for new roms, then load game, Otherwise, run an initial scan and then load a random game
if [[ -f "scanned_all" ]]
then
    loadRandomRom
else
    checkDependencies
    clear
    printf "** INITIAL SCAN - Please be patient while ROMS are scanned **"
    sleep 1
    scanRoms
    loadRandomRom
fi

clear

exit 0

#=========   END MAIN PROGRAM   =========