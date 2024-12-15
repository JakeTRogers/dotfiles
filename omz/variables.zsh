# background color using ANSI escape
[ -z $bgBlack ]     && declare -r bgBlack=$(tput setab 0)   && export bgBlack       # black
[ -z $bgRed ]       && declare -r bgRed=$(tput setab 1)     && export bgRed         # red
[ -z $bgGreen ]     && declare -r bgGreen=$(tput setab 2)   && export bgGreen       # green
[ -z $bgYellow ]    && declare -r bgYellow=$(tput setab 3)  && export bgYellow      # yellow
[ -z $bgBlue ]      && declare -r bgBlue=$(tput setab 4)    && export bgBlue        # blue
[ -z $bgMagenta ]   && declare -r bgMagenta=$(tput setab 5) && export bgMagenta     # magenta
[ -z $bgCyan ]      && declare -r bgCyan=$(tput setab 6)    && export bgCyan        # cyan
[ -z $bgWhite ]     && declare -r bgWhite=$(tput setab 7)   && export bgWhite       # white

# foreground color using ANSI escape
[ -z $fgBlack ]     && declare -r fgBlack=$(tput setaf 0)   && export fgBlack       # black
[ -z $fgRed ]       && declare -r fgRed=$(tput setaf 1)     && export fgRed         # red
[ -z $fgGreen ]     && declare -r fgGreen=$(tput setaf 2)   && export fgGreen       # green
[ -z $fgYellow ]    && declare -r fgYellow=$(tput setaf 3)  && export fgYellow      # yellow
[ -z $fgBlue ]      && declare -r fgBlue=$(tput setaf 4)    && export fgBlue        # blue
[ -z $fgMagenta ]   && declare -r fgMagenta=$(tput setaf 5) && export fgMagenta     # magenta
[ -z $fgCyan ]      && declare -r fgCyan=$(tput setaf 6)    && export fgCyan        # cyan
[ -z $fgWhite ]     && declare -r fgWhite=$(tput setaf 7)   && export fgWhite       # white

# text attributes using ANSI escape
[ -z $txBold ]      && declare -r txBold=$(tput bold)       && export txBold        # bold
[ -z $txHalf ]      && declare -r txHalf=$(tput dim)        && export txHalf        # half-bright
[ -z $txUnderline ] && declare -r txUnderline=$(tput smul)  && export txUnderline   # underline
[ -z $txEndUnder ]  && declare -r txEndUnder=$(tput rmul)   && export txEndUnder    # exit underline
[ -z $txReverse ]   && declare -r txReverse=$(tput rev)     && export txReverse     # reverse
[ -z $txStandout ]  && declare -r txStandout=$(tput smso)   && export txStandout    # standout
[ -z $txEndStand ]  && declare -r txEndStand=$(tput rmso)   && export txEndStand    # exit standout
[ -z $txReset ]     && declare -r txReset=$(tput sgr0)      && export txReset       # reset attributes
