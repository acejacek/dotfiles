###############################
#      SYSTEM SPECIFIC        #
###############################

# Non-interactive mode
[[ -z "$PS1" ]] && return

# Default values defined in system-specific rc-files - "L_" for "LOCAL"
[[ -z "$(which vim)" ]] && export L_VIM="vi" || export L_VIM="vim"

export L_PS1_HOST_COLOR="44" # Green by default
export L_PS1_ALREADY_SET=""

# Load OS-specific rc files
#
if [[ "$(uname)" == 'Darwin' ]]; then # Leopard
    source ~/.bashrc_mac
elif [[ "$(uname)" == 'Linux' ]]; then # Linux
    source ~/.bashrc_linux
fi

# This one is only for local stuff
if [[ -e ~/.bashrc_misc ]]; then
    source ~/.bashrc_misc
fi

###############################
#           PROMPT            #
###############################

export GIT_PS1_SHOWDIRTYSTATE=true # *: unstaged changes, +: staged changes
export GIT_PS1_SHOWSTASHSTATE=true # $: something is stashed
# export GIT_PS1_SHOWUNTRACKEDFILES=true # %: untracked files exist
export GIT_PS1_SHOWUPSTREAM="auto" # <: behind upstream, >: ahead upstream, <>: diverged
L_Z_PROMPT_CMD=${L_Z_PROMPT_CMD:-true}

# then you can add \`jobs_count\` to the end of your PS1 like this
export PS1="\[\e[32m\]\u\[\e[m\]@\[\e[32m\]\h\[\e[m\]:\[\e[34m\]\w\[\e[m\]\`git_branch\`\`jobs_count\`\n\$ "

# Nice, complete prompt
function __rc_prompt_command() {
    local EXIT="$?"  # This needs to be first

    local C_RST='\[\e[0m\]'
    local C_RED='\[\e[0;31m\]'
    local C_GREEN='\[\e[0;32m\]'
    local C_BLUE='\[\e[01;34m\]'
    local C_YELLOW='\[\e[01;93m\]'
    local C_USER='\[\e[38;5;${L_PS1_HOST_COLOR}m\]'
    local C_VENV=$C_GREEN
    local C_DATE='\[\e[38;5;166m\]'
    local C_GIT='\[\e[38;5;63m\]'

    local PS_EXIT=""
    if [[ $EXIT != 0 ]]; then
        PS_EXIT="${C_RED}[$EXIT]${C_RST} "
    fi

    local job_count=$(jobs -l | grep 'Running' | wc -l)
    local job_count_prompt
    if [[ $job_count -gt 0 ]]; then
        job_count_prompt="${C_YELLOW}[${job_count}]${C_RST} "
    fi

    PS1=""
    PS1+="$job_count_prompt"
    [[ -n $VIRTUAL_ENV ]] && PS1+="${C_VENV}(venv)${C_RST} "
    PS1+="${C_GIT}$(__git_ps1 "(%s) ")${C_USER}\u@\h${C_RST}"
#    PS1+="${C_DATE}$(date +%H:%M)${C_BLUE}${_P_SSH} ${PS_EXIT}${C_BLUE}\w ${C_RST}"
    PS1+="${C_BLUE}${_P_SSH} ${PS_EXIT}${C_BLUE}\w ${C_RST}"

    # Z (autojump like thing) - defined in other .bashrc_xxx
    "$L_Z_PROMPT_CMD" --add "$(command pwd -P 2>/dev/null)" 2>/dev/null
}
# Smaller prompt, good for presentations
function __rc_prompt_command2() {
    local EXIT="$?"  # This needs to be first

    local C_RST='\[\e[0m\]'
    local C_RED='\[\e[0;31m\]'
    local C_BLUE='\[\e[01;34m\]'
    local C_USER='\[\e[38;5;${L_PS1_HOST_COLOR}m\]'
    local C_DATE='\[\e[38;5;166m\]'
    local C_GIT='\[\e[38;5;63m\]'

    local PS_EXIT=""
    if [[ $EXIT != 0 ]]; then
        PS_EXIT="${C_RED}[$EXIT]${C_RST} "
    fi

    PS1=""
    PS1+="${C_DATE}$(date +%H:%M) ${PS_EXIT}${C_BLUE}\W \$${C_RST} "

    # Z (autojump like thing) - defined in other .bashrc_xxx
    "$L_Z_PROMPT_CMD" --add "$(command pwd -P 2>/dev/null)" 2>/dev/null
}

# stalker: purple - slacker: bordeaux - kollok: orange - blinker: 'skin'
if [[ -z $L_PS1_ALREADY_SET ]]; then
    if [[ -n $SSH_CLIENT ]]; then export _P_SSH=" (ssh)" ; fi
    export PROMPT_COMMAND=__rc_prompt_command  # Func to gen PS1 after CMDs
fi

alias prompt_default='export PROMPT_COMMAND=__rc_prompt_command'
alias prompt_simple='export PROMPT_COMMAND=__rc_prompt_command2'

###############################
#          OPTIONS            #
###############################

# Binaries in home
export PATH=~/bin/local:~/bin:~/bin/scripts:$PATH

# General
export EDITOR=vim
export VISUAL=vim

# Bash
export HISTCONTROL=ignoredups
export HISTFILESIZE=100000
export HISTSIZE=10000

# Go
export GOPATH="$HOME/go"
export PATH=$PATH:$GOPATH/bin

# Rsync and others transfer apps
export UPLOAD_BW_LIMIT=400

# App-specific
export MPD_HOST=localhost
export TEXMFHOME=~/.texmf

if [ -f "$HOME/.dircolors" ] ; then
    # Works for Mac - does it for others?
    eval "$(dircolors "$HOME/.dircolors")"
fi

# GPG settings
export GPG_TTY=$(tty)

###############################
#           ALIASES           #
###############################

# Summary: cd, ls, t[a] (tree), mkcd, ,, (cd ..), e (edit), f, g gi gr gri (grep), lna, sr, sls

## Bookmarks
alias cdms='cd ~/Media/series'
alias cdmf='cd ~/Media/films'
alias cdma='cd ~/Media/animes'
alias cdmm='cd ~/Media/music_new'

# Git bookmarks begin with cdg
alias cdgd='cd ~/dotfiles'
alias cdg='cd ~/git'

# gradle
gw() { # Run gradle if found in the current or parent directories
    for i in . .. ../.. ../../.. ../../../..; do
        if [[ -x $i/gradlew ]]; then
            (cd $i && ./gradlew "$@") ; return
        fi
    done
    echo "No gradlew found in current or parent directories"
}

# git
alias gg='git log --graph --full-history --all --color --pretty=format:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s"'
alias gg2='git log --graph --full-history --all --color --pretty=format:"%x1b[31m%h%x09%x20%x1b[0m%s%x1b[32m%d%x1b[0m"'
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --abbrev-commit --date=local"
alias gl2="git log --pretty=format:'* %Cred%h%Creset - %s %n%w(76,4,4)%b' --abbrev-commit"
alias gl3="git log --pretty=format:'* %h - %s %n%w(76,4,4)%b' --abbrev-commit"
alias gra='git remote add'
alias grr='git remote rm'
alias grv='git remote -v'
alias gco='git checkout'
alias gci='git commit'
alias gre='git rebase'
alias grei='git rebase -i'
alias grec='git rebase --cont'
alias grea='git rebase --abort'
alias grea='git rebase --abort'
alias gpullod='git pull origin dev'
alias gpullom='git pull origin master'
alias gpullud='git pull upstream dev'
alias gpullum='git pull upstream master'
alias gpushod='git push origin dev'
alias gpushom='git push origin master'
alias gpushud='git push upstream dev'
alias gpushum='git push upstream master'

# Core
alias ls='ls --color=auto'
alias sl='ls'
alias l='ls'
alias ll='ls -ahl'

lsd() { ls -F "$@" |grep '/$'  ; }
lsl() { ls -F "$@" |grep '@$'  ; }
lsx() { ls -F "$@" |grep '\*$' ; }

alias ta='tree    --charset ascii -a        -I \.git*\|*\.\~*\|*\.pyc'
alias ta2='tree   --charset ascii -a  -L 2  -I \.git*\|*\.\~*\|*\.pyc'
alias ta3='tree   --charset ascii -a  -L 3  -I \.git*\|*\.\~*\|*\.pyc'

# alias pud='pushd -n "$args" &> /dev/null' # Push dir on stack
# alias pod='popd >& /dev/null'		 # Go back in time
# alias ds="dirs -v"       # Show DIRSTACK with array index

# Directory change functions
mkcd () {
    mkdir -p "$*" ; cd "$*"
}

function , ()    { cd .. ; }
function ,, ()   { cd ../.. ; }
function ,,, ()  { cd ../../.. ; }
function ,,,, () { cd ../../../.. ; }

# Utilities (grep, basename, dirname)
alias grep='grep --color'
alias gri='grep -rI'
grio() { grep -rIO "$@" 2>/dev/null ; }

alias ag='ag --ignore .venv --ignore tags --ignore TAGS'

# Find
f() {
    name="$1" ; shift
    find . -name '*'"$name"'*' "$@"
}
fl() {
    name="$1" ; shift
    find -L . -name '*'"$name"'*' "$@"
}

#alias d='docker'

# Disk use sorted, process list
alias dus='du -shm * .[^.]* | sort -n'
alias psa='ps aux'
alias pst='pstree -hAcpul'

# Rsync - Unison
alias unison='unison -ui text'
alias unismall='unison small_data'
alias unibig='unison big_data'
alias unifull='unismall && unibig'

# Screen
alias sls='screen -ls'
alias sr='screen -r'

# Docker
#alias dr='docker run -ti'
#alias di='docker images'

# Handy prefixes
#alias left='DISPLAY=:0.0'
#alias right='DISPLAY=:0.1'

# Editor related
alias e="$L_VIM"

# Bash, zsh, vim RC files
alias sob='source ~/.bashrc'
alias vimb="e ~/.bashrc"
alias vimbm="e ~/.bashrc_mac"
alias vimbs="e ~/.bashrc_slacker"
alias vimbl="e ~/.bashrc_linux"
alias vimbg="e ~/.bashrc_slacker"
alias vimbk="e ~/.bashrc_kollok"
alias vimz="e ~/.zshrc"
alias soz="source ~/.zshrc"
alias vimv="e ~/.vimrc"

alias ctags="ctags -R --totals=yes"

############################
#        BOOKMARKS         #
############################

# SSH
alias sshn='ssh neon'
alias sshg='ssh galium'
alias sshc='ssh cobalt'

# apt
alias aptu="sudo apt-get update"
alias aptg="sudo apt-get upgrade"

# MPD
alias mpds="mpd --no-daemon &"
alias mpdk="mpd --kill"
alias mpdr="mpdk && mpds"

# Other
alias restore_vim_session='vim $(find . -name ".*.swp" | while read f; do rm "$f"; echo "$f" | sed "s/\\.\\([^/]*\\).swp/\\1/"; done)'
alias vless='vim -u /usr/share/vim/vim72/macros/less.vim'
alias myports='netstat -alpe --ip'


## Python {{{
# Virtualenv activate
alias vv='virtualenv .venv && . .venv/bin/activate'
va() {
    if [[ -d .venv ]]; then
        . .venv/bin/activate
        echo "Activated virtualenv from .venv/"
    elif [[ -d venv ]]; then
        . venv/bin/activate
        echo "Activated virtualenv from venv/"
    else
        echo "No .venv or venv directory found in cwd."
        return 1
    fi
}
alias vd=deactivate

alias tip='touch __init__.py'

# Django
alias vimdjango="$L_VIM ../{urls,settings}.py models.py views/*.py forms/*.py templates/*.py"
alias drs='python manage.py runserver'
alias dsd='python manage.py syncdb'
alias dsh='python manage.py shell'
#}}}

if [ -n "$TERM" ] && [ -x "$(which keychain)" ] && \
    [ -f "$HOME/.ssh/id_rsa" ] ; then
    keychain -q $HOME/.ssh/id_rsa
    . $HOME/.keychain/$(hostname)-sh
fi


[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

#vim:foldmethod:marker
