# the idea of this theme is to contain a lot of info in a small string, by
# compressing some parts and colorcoding, which bring useful visual cues,
# while limiting the amount of colors and such to keep it easy on the eyes.
# When a command exited >0, the timestamp will be in red and the exit code
# will be on the right edge.
# The exit code visual cues will only display once.
# (i.e. they will be reset, even if you hit enter a few times on empty command prompts)
typeset -A host_repr
# translate hostnames into shortened, colorcoded strings
host_repr=('dieter-ws-a7n8x-arch' "%{$fg_bold[green]%}ws" 'dieter-p4sci-arch' "%{$fg_bold[blue]%}p4")
# local time, color coded by last return code
time_enabled="%(?.%{$fg[red]%}.%{$fg[red]%})%*%{$reset_color%}"
time_disabled="%{$fg[red]%}%*%{$reset_color%}"
time=$time_enabled
# user part, color coded by privileges
local user="%(!.%{$fg[blue]%}.%{$fg[blue]%})%n%{$reset_color%}"
# Hostname part.  compressed and colorcoded per host_repr array
# if not found, regular hostname in default color
local host="@${host_repr[$HOST]:-$HOST}%{$reset_color%}"
# Compacted $PWD
local pwd="%{$fg[yellow]%}%c%{$reset_color%}"
function cmtUp() {
    [ ! -d .git ] && return
    up="$( git log --oneline `git rev-parse --abbrev-ref --symbolic-full-name @{u}` ^HEAD | wc -l | sed -e 's/[[:space:]]//g')"
    if [ $up -gt 0 ]; then
        echo -n "%{$fg[red]%}" 
        echo -n '↓'
        echo -n $up
        echo -n "%{$reset_color%} "
    fi
}
function cmtDwn() {
    [ ! -d .git ] && return
    local dwn="$( git log --oneline ^`git rev-parse --abbrev-ref --symbolic-full-name @{u}` HEAD | wc -l | sed -e 's/[[:space:]]//g')"
    if [ $dwn -gt 0 ]; then
        echo -n "%{$fg[red]%}" 
        echo -n '↑'
        echo -n $dwn
        echo -n "%{$reset_color%} "
    fi
}
PROMPT='${time} ${pwd} $(git_prompt_info)$(cmtDwn)$(cmtUp)$ '
# i would prefer 1 icon that shows the "most drastic" deviation from HEAD,
# but lets see how this works out
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}] %{$fg[yellow]%}%{$fg[green]%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="] %{$fg[green]%}"
# elaborate exitcode on the right when >0
return_code_enabled="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
return_code_disabled=
return_code=$return_code_enabled
RPS1='${return_code}'
function accept-line-or-clear-warning () {
    if [[ -z $BUFFER ]]; then
        time=$time_disabled
        return_code=$return_code_disabled
    else
        time=$time_enabled
        return_code=$return_code_enabled
    fi
    zle accept-line
}
zle -N accept-line-or-clear-warning
bindkey '^M' accept-line-or-clear-warning

