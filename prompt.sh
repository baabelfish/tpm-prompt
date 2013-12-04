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
    echo -ne "$BG[$1]"
}

fC() {
    echo -ne "$FG[$1]"
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

    # Show virtual environment
    VENV=$(echo $VIRTUAL_ENV|rev|cut -f1 -d'/'|rev)
    if [[ -z "$VENV" ]]; then
        VENV="»"
    fi

    # Git info
    d=$(pwd)
    INGIT=false
    while [[ ! -z "$d" ]] && [[ "$d" != "/" ]]; do
        [[ -d "$d"/.git ]] && INGIT=true && break
        d=${d%/*}
    done
    if [[ $INGIT == true ]]; then
        GBRANCH=$(git branch|grep '^*'|cut -f2 -d' ') 2> /dev/null
        [[ "$GBRANCH" == "master" ]] && GBRANCH="M"
        [[ "$GBRANCH" == "develop" ]] && GBRANCH="D"
        [[ -z $GBRANCH ]] && GBRANCH="-"
        git diff --quiet || GBRANCH="⚡ "$GBRANCH
    fi

    [[ -z $BPROMPT_SEP_LEFT ]] && BPROMPT_SEP_LEFT="▶"
    [[ -z $BPROMPT_SEP_RIGHT ]] && BPROMPT_SEP_RIGHT="◀"
    # BPROMPT_=237
    # BPROMPT_=237
    # BPROMPT_=082
    # BPROMPT_=082

    RPROMPT="\
%{$reset_color%}%{$(fC 237)%} $BPROMPT_SEP_RIGHT\
%{$(bC 237)%}%{$(fC 082)%} %~%b\
%{$(bC 237)%}%{$(fC 082)%} $BPROMPT_SEP_RIGHT\
%{$(bC 082)%}%{$(fC 232)%} %B$GBRANCH %b\
%{$reset_color%}%{$(fC 082)%}$BPROMPT_SEP_LEFT \
%{$reset_color%}%{$(fC 076)%}%B%T%b%{$reset_color%}"

    PROMPT="\
%{$(bC 237)%}%{$(fC 082)%} %B%m %b\
%{$(bC 235)%}%{$(fC 237)%}$BPROMPT_SEP_LEFT\
%{$(bC 235)%}%{$(fC 112)%} %B$VENV \
%{$reset_color%}%{$(fC 235)%}$BPROMPT_SEP_LEFT\
%{$reset_color%}%b "

    if [[ ! -z $ERR ]]; then
        PROMPT="%{$(bC 234)%}%{$(fC 196)%} %B$ERR %b\
%{$(bC 237)%}%{$(fC 234)%}$BPROMPT_SEP_LEFT\
$PROMPT"
    fi
}
