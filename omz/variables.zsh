# If not running interactively, don't do anything
[[ $- != *i* ]] && return
[[ -z "$TERM" ]] && return

# background color using ANSI escape
(( ${+bgBlack} ))     || { bgBlack=$(tput setab 0)    && declare -rx bgBlack }     # black
(( ${+bgRed} ))       || { bgRed=$(tput setab 1)      && declare -rx bgRed }       # red
(( ${+bgGreen} ))     || { bgGreen=$(tput setab 2)    && declare -rx bgGreen }     # green
(( ${+bgYellow} ))    || { bgYellow=$(tput setab 3)   && declare -rx bgYellow }    # yellow
(( ${+bgBlue} ))      || { bgBlue=$(tput setab 4)     && declare -rx bgBlue }      # blue
(( ${+bgMagenta} ))   || { bgMagenta=$(tput setab 5)  && declare -rx bgMagenta }   # magenta
(( ${+bgCyan} ))      || { bgCyan=$(tput setab 6)     && declare -rx bgCyan }      # cyan
(( ${+bgWhite} ))     || { bgWhite=$(tput setab 7)    && declare -rx bgWhite }     # white
(( ${+bgPurple} ))    || { bgPurple=$(tput setab 99)  && declare -rx bgPurple }    # purple
(( ${+bgPink} ))      || { bgPink=$(tput setab 171)   && declare -rx bgPink }      # pink
(( ${+bgOrange} ))    || { bgOrange=$(tput setab 172) && declare -rx bgOrange }    # orange
(( ${+bgDkGrey} ))    || { bgDkGrey=$(tput setab 237) && declare -rx bgDkGrey }    # dark grey
(( ${+bgGrey} ))      || { bgGrey=$(tput setab 243)   && declare -rx bgGrey }      # grey
(( ${+bgLtGrey} ))    || { bgLtGrey=$(tput setab 249) && declare -rx bgLtGrey }    # light grey

# foreground color using ANSI escape
(( ${+fgBlack} ))     || { fgBlack=$(tput setaf 0)    && declare -rx fgBlack }     # black
(( ${+fgRed} ))       || { fgRed=$(tput setaf 1)      && declare -rx fgRed }       # red
(( ${+fgGreen} ))     || { fgGreen=$(tput setaf 2)    && declare -rx fgGreen }     # green
(( ${+fgYellow} ))    || { fgYellow=$(tput setaf 3)   && declare -rx fgYellow }    # yellow
(( ${+fgBlue} ))      || { fgBlue=$(tput setaf 4)     && declare -rx fgBlue }      # blue
(( ${+fgMagenta} ))   || { fgMagenta=$(tput setaf 5)  && declare -rx fgMagenta }   # magenta
(( ${+fgCyan} ))      || { fgCyan=$(tput setaf 6)     && declare -rx fgCyan }      # cyan
(( ${+fgWhite} ))     || { fgWhite=$(tput setaf 7)    && declare -rx fgWhite }     # white
(( ${+fgPurple} ))    || { fgPurple=$(tput setaf 99)  && declare -rx fgPurple }    # purple
(( ${+fgPink} ))      || { fgPink=$(tput setaf 171)   && declare -rx fgPink }      # pink
(( ${+fgOrange} ))    || { fgOrange=$(tput setaf 172) && declare -rx fgOrange }    # orange
(( ${+fgDkGrey} ))    || { fgDkGrey=$(tput setaf 237) && declare -rx fgDkGrey }    # dark grey
(( ${+fgGrey} ))      || { fgGrey=$(tput setaf 243)   && declare -rx fgGrey }      # grey
(( ${+fgLtGrey} ))    || { fgLtGrey=$(tput setaf 249) && declare -rx fgLtGrey }    # light grey

# podman fzf-helper (fp*) table formats, consumed by the autoloaded fp* functions
(( ${+_FP_CONTAINER_FORMAT} )) || typeset -gr _FP_CONTAINER_FORMAT=$'{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
(( ${+_FP_IMAGE_FORMAT} ))     || typeset -gr _FP_IMAGE_FORMAT=$'{{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}'

# text attributes using ANSI escape
(( ${+txBold} ))      || { txBold=$(tput bold)        && declare -rx txBold }      # bold
(( ${+txHalf} ))      || { txHalf=$(tput dim)         && declare -rx txHalf }      # half-bright
(( ${+txUnderline} )) || { txUnderline=$(tput smul)   && declare -rx txUnderline } # underline
(( ${+txEndUnder} ))  || { txEndUnder=$(tput rmul)    && declare -rx txEndUnder }  # exit underline
(( ${+txReverse} ))   || { txReverse=$(tput rev)      && declare -rx txReverse }   # reverse
(( ${+txStandout} ))  || { txStandout=$(tput smso)    && declare -rx txStandout }  # standout
(( ${+txEndStand} ))  || { txEndStand=$(tput rmso)    && declare -rx txEndStand }  # exit standout
(( ${+txReset} ))     || { txReset=$(tput sgr0)       && declare -rx txReset }     # reset attributes
