#!/bin/bash
for color in {000..$SUPPORT}; do
    FG[$color]="\e[38;5;${color}m"
    BG[$color]="\e[48;5;${color}m"
done

PS1=":"

if [[ "$TERM" == "linux" ]]; then
    promptinit
    prompt walters
    return
fi

bC() {
    if [[ $1 == "0" ]]; then
        echo -ne $reset_color
    else
        echo -ne "$BG[$1]"
    fi
}

fC() {
    if [[ $1 == "0" ]]; then
        echo -ne $reset_color
    else
        echo -ne "$FG[$1]"
    fi
}

prompt_part() {
    local fg_color=$(fC $1)
    local bg_color=$(bC $2)
    local sep_fg_color=$(fC $2)
    local sep_bg_color=$(bC $3)
    local stuff=$4
    PROMPT="$PROMPT%{$bg_color%}%{$fg_color%} $stuff"
    PROMPT="$PROMPT%{$sep_bg_color%}%{$sep_fg_color%}$BPROMPT_SEP_LEFT"
}

prompt_end() {
    PROMPT="$PROMPT%{$reset_color%}%b "
}

rprompt_part() {
    local fg_color=$(fC $1)
    local bg_color=$(bC $2)
    local sep_fg_color=$(fC $2)
    local sep_bg_color=$(bC $3)
    local stuff=$4
    RPROMPT="$RPROMPT%{$sep_bg_color%}%{$sep_fg_color%} $BPROMPT_SEP_RIGHT"
    RPROMPT="$RPROMPT%{$bg_color%}%{$fg_color%} $stuff"
}


precmd() {
    # Show return value
    ERR=$?
    if [[ "$ERR" != "0" ]]; then
        ERR="$ERR"
        # ERR="$(aC $WC)$ERR"
    else
        ERR=""
    fi

    mountpoint -q $(pwd)
    is_mountepoint=$?

    # Show first job
    PROMPT_JOB=$(jobs|head -n 1|awk '{ print $4 }')

    # Show virtual environment
    VENV=$(echo $VIRTUAL_ENV|rev|cut -f1 -d'/'|rev)
    if [[ -z "$VENV" ]]; then
        VENV="»"
    fi

    # Git info
    # d=$(pwd)
    git rev-parse --git-dir 2> /dev/null > /dev/null
    is_git=$?
    # INGIT=false
    # while [[ ! -z "$d" ]] && [[ "$d" != "/" ]]; do
        # [[ -d "$d"/.git ]] && INGIT=true && break
        # d=${d%/*}
    # done
    if [[ $is_git -eq 0 ]]; then
        GBRANCH=$(git branch|grep '^*'|cut -f2 -d' ') 2> /dev/null
        [[ "$GBRANCH" == "master" ]] && GBRANCH="M"
        [[ "$GBRANCH" == "develop" ]] && GBRANCH="D"
        git diff --quiet || GBRANCH=$GBRANCH
    else
        GBRANCH="-"
    fi

    [[ -z $BPROMPT_SEP_LEFT ]] && BPROMPT_SEP_LEFT="▶"
    [[ -z $BPROMPT_SEP_RIGHT ]] && BPROMPT_SEP_RIGHT="◀"
    # BPROMPT_=237
    # BPROMPT_=237
    # BPROMPT_=082
    # BPROMPT_=082

    PROMPT=""
    prompt_part 082 237 235 "%B%m %b"
    prompt_part 082 235 0 "%B$VENV %b"
    prompt_end

    right_last_char=082
    RPROMPT=""
    rprompt_part 082 235 0 "%~%b"
    rprompt_part 232 082 235 "%B$GBRANCH %b"
    if [[ ! -z "$PROMPT_JOB" ]]; then
        right_last_char=237
        rprompt_part 202 237 082 "%B$PROMPT_JOB %b"
    fi
    RPROMPT="$RPROMPT%{$reset_color%}%{$(fC $right_last_char)%}$BPROMPT_SEP_LEFT "
    RPROMPT="$RPROMPT%{$reset_color%}%{$(fC 076)%}%B%T%b%{$reset_color%}"

    if [[ ! -z $ERR ]]; then
        PROMPT="%{$(bC 234)%}%{$(fC 196)%} %B$ERR %b\
%{$(bC 237)%}%{$(fC 234)%}$BPROMPT_SEP_LEFT\
$PROMPT"
    fi
}
