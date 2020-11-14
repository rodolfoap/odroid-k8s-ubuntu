# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then debian_chroot=$(cat /etc/debian_chroot); fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*)
	;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

####################################################################
# Aliases

=(){ popd; }
alias +='pushd'
alias apt.install='sudo apt install'
alias apt.log='cat <(zcat $(ls -St /var/log/apt/history.log.*)) /var/log/apt/history.log'
alias apt.list.installed='sudo apt list --installed'
alias apt.pkg.details='apt-cache show'
alias apt.pkg.files='dpkg-query -L'
alias apt.remove='apt-get remove'
alias apt.search='apt-cache search'
alias apt.update='apt-get update; apt-get dist-upgrade'
alias bc='/bin/bc -l'
alias bin='cd ~/bin'
alias big="du -h *|grep -P '^(\d|,)+(M|G)'|sort -h"
alias chow='/usr/bin/sudo /bin/chown -R $(/usr/bin/id -un): .'
alias dmesg.watch="watch -n 0.1 'dmesg|tail -40'"
alias du0='du --max-depth=0'
alias du1='du --max-depth=1'
alias du1h='du --max-depth=1 -h'
alias duh1='du --max-depth=1 -h'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='egrep -i --color=auto'
alias i0='sudo shutdown -h now'
alias i6='sudo reboot'
alias igrep='grep -i --color=auto'
alias l='ls -lhFtr --color=tty --group-directories-first --literal'
alias la='ls -lahFtr --color=tty --group-directories-first'
alias ll='/bin/exa -lg --group-directories-first -s mod -m -@ --git'
alias less='less -R'
alias mci='mvn clean install'
alias mci.skiptests='mvn clean install -Dmaven.test.skip=true'
alias rc='source ~/.bashrc'
alias rm='rm --interactive=never'
alias sur='sudo su -'
alias viO='vi -O'
alias vio='vi -o'
alias v='vi -p'
alias vip='vi -p'
alias virc='/usr/bin/vi -p ~/.bashrc*; . ~/.bashrc'
alias vihosts='sudo vi /etc/hosts'
alias which='type -p'

####################################################################
# Docker

alias d='/usr/bin/docker'
alias dc='docker-compose'
alias dc.list.services='docker-compose config --services'
alias d.disable.pull='export NO_DOCKER_PULL=1'
alias d.rmi='docker rmi'
alias d.rename='docker rename'
alias d.stop='docker stop'
alias d.start='docker start'
alias d.pull='docker pull'
alias d.search='docker search'
alias d.stats='docker stats -a'
alias dockviz="docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz"
d.children(){ [ -n "$1" ] && for i in $(docker images -q); do docker history $i | grep -q $1 && echo $i; done | sort -u; }
dcl(){ [ -z "$1" ] && { docker-compose config --services; } || { docker-compose logs -f $1; }; }
dx(){	# This is the last d.ssh version, autoselects image/container
	[ -z "$1" ] && { echo "Usage: d.c [IMAGE_ID|CONTAINER_ID]"; return; }
	[ -n "$(docker image ls|sort|uniq|grep $1)" ] && {
	echo	docker run -ti --rm -v /dev/log:/dev/log --entrypoint=/bin/bash $1;
		docker run -ti --rm -v /dev/log:/dev/log --entrypoint=/bin/bash $1;
	}
	[ -n "$(docker ps -q|sort|uniq|grep $1)" ] && {
	echo	docker exec -it $1 /bin/bash;
		docker exec -it $1 /bin/bash;
	}
}
dl(){
	echo d images '(images)'
	docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}"|grep -f ~/.docker/ifilter|sed "s/^/\t/";
	echo d ps -a '(containers)'
	docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Networks}}\t{{.Ports}}"|grep -f ~/.docker/cfilter|sed "s/^/\t/"
}
dla(){
	echo d network ls '(volumes)'
	docker network ls|sed "s/^/\t/";
	echo d images '(images)'
	docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}"|sed "s/^/\t/";
	echo d ps -a '(containers)'
	docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Networks}}\t{{.Ports}}"|sed "s/^/\t/"
}
dlaa(){
	echo d network ls '(volumes)'
	docker network ls|sed "s/^/\t/";
	echo d volume ls '(volumes)'
	docker volume ls|sed "s/^/\t/";
	echo d images '(images)'
	docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}\t{{.Size}}"|sed "s/^/\t/";
	echo d ps -a '(containers)'
	docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Networks}}\t{{.Ports}}"|sed "s/^/\t/"
}
d.filter(){
	vi -o ~/.docker/ifilter ~/.docker/cfilter
}
d.inspect () {
	docker inspect --format '{{$e := . }}{{with .NetworkSettings}}=== {{$e.Name}} ===
	{{range $index, $net := .Networks}}{{$index}}
	{{.IPAddress}}{{end}}{{end}}' $(docker ps -q)
}
d.rm(){ [ -n "$1" ] && {
		set -x
		docker stop $@;
		docker rm $@;
		set +x
	} || {
		echo Usage: 'd.rm [CONTAINER_ID]';
	};
}
d.zap(){ docker stop $(docker ps -aq); docker rm $(docker ps -aq); }
d.zap.exited(){ docker rm $(docker ps -a|grep Exited|awk '{print $1;}'); }
d.zap.i(){
	docker stop $(docker ps -aq) 2>/dev/null;
	docker rm $(docker ps -aq) 2>/dev/null;
	docker images|egrep --color=auto -i --color=auto -v -f ~/.docker/ifilter|grep -v IMAGE|awk '{print $3}'|xargs docker rmi -f
}
d.clean(){
	echo Cleaning "'Exited'" containers...
	docker ps -aq									|xargs -r docker rm		2>/dev/null
	echo Cleaning dangling images...
	docker images -f dangling=true -q						|xargs -r docker rmi		2>/dev/null
	echo Cleaning images tagged '<none>'...
	docker images --digests|awk '{if($2=="<none>") print $1"@"$3;}'			|xargs -r docker rmi		2>/dev/null
	echo Cleaning messaging-build_* images...
	docker images registry.gtd-international.com/messaging-build_* -q		|xargs -r docker rmi		2>/dev/null
	echo Cleaning build_* images...
	docker images -q registry.smite2.gtd-international.com/build_*			|xargs -r docker rmi		2>/dev/null
	echo Cleaning LATEST gtd images...
	docker images|grep registry.gtd-international.com|grep latest|awk '{print $1}'	|xargs -r docker rmi		2>/dev/null
	echo Cleaning dangling volumes...
	docker volume ls -qf dangling=true						|xargs -r docker volume rm	2>/dev/null
	echo Cleaning unused networks...
	docker network ls --filter driver=bridge -q					|xargs -r docker network rm	2>/dev/null
	echo Done.
}
d.rmi.list(){ docker images --format "table d.rmi {{.Repository}}:{{.Tag}}"; }

####################################################################
# Functions

calc()	{ echo "scale=${2:-2}; $1" | bc -l; }
vix()	{ [ -f .x ] || cp ~/bin/_x_model .x ; vi .x ; }
vik()	{ vi ./.k; }
catx()	{ cat ./.x; }
catk()	{ cat ./.k; }
x()	{ [ -f .x ] && source .x $@; }
k()	{ [ -f .k ] && source .k $@; }
alias e='x e'
alias xb='x b'
alias xc='x c'
alias xl='x l'
cmake.build()	{ rm -rf build/; mkdir build; cd build; cmake .. -Wdev; make; }

####################################################################
# Git

alias b='git branch -avv'
alias gw='git whatchanged'
alias fetch='git fetch -p --all'
alias pull='git pull --all -vv'
alias push='git push -vv'
alias s='git status'
alias git.clean.xdf='git clean -xdf'
alias git.config='git config --list --show-origin'
alias git.diff.with.last='git diff HEAD^'
alias git.file.changes='git log -p'
alias git.list.ignored='git status --ignored'
alias git.list.tracked='git ls-tree -r $(git symbolic-ref --short HEAD) --name-only;'
alias git.list.untracked='git status -u'
alias git.files_objects='git ls-tree --full-tree -r HEAD'
alias git.merge.nocommit.ours='git merge --squash -X ours'
alias git.merge.nocommit.theirs='git merge --squash -X theirs'
alias git.merge.nocommit='git merge --squash'
alias git.m.init='git submodule update --init --recursive'
alias git.m.status='git submodule status'
alias git.m.update='git submodule update --recursive'
alias git.m.update.dev='git submodule foreach git pull origin dev'
alias git.m.reset.dev='git submodule update; git submodule foreach "git checkout dev; git pull"; git submodule foreach git reset --hard HEAD'
alias git.m.clean.xdf='git submodule foreach --recursive git clean -xdf'
alias git.m.reset.hard.HEAD='git submodule foreach --recursive git reset --hard HEAD'
alias git.ours='git checkout --ours'
alias git.remote='git remote -v'
alias git.remote.rename='git remote rename'
alias git.reset.hard.HEAD='git reset --hard HEAD'
alias git.rm.but.not.from.fs='git rm --cached'
alias git.rm.all='echo rm -r $(ls -A1|grep -v ^.git$)'
alias git.theirs='git checkout --theirs'
alias vi.gitignore='vi .gitignore'
a(){ git add -v .; git status; }
git.reset.to.remote(){ git fetch origin; git reset --hard origin/$(git symbolic-ref --short HEAD); }
alias tag='git tag -n'
alias tag.bydate='git log --tags --simplify-by-decoration --pretty="format:%ai %d"'
git.amend(){ git commit --amend --no-edit; git push --force; }
acommit(){ git add .; commit "$@"; }
commit(){
	CHANGEID=$(echo -e "\n\nChange-Id: I"$(cat /dev/urandom|tr -dc A-F0-9|tr A-Z a-z|head -c40));
	[ -z "$1" ] && { MESSAGE="Changes "$(date +%Y/%m/%d-%H:%M:%S); } || { MESSAGE="$*"; }
	echo -e "Message is:\n---\n${MESSAGE}${CHANGEID}\n---"
	git commit -m "${MESSAGE}${CHANGEID}"
	git push
}
git.show.activity(){ git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(authorname) %(refname:short)'; }

####################################################################
# Kubernetes

alias k.zap='kubectl delete all,pv,pvc --all'
alias krm='kubectl delete'
alias kdescribe='kubectl describe'
alias klog='kubectl logs -f'
kbash() {
	kubectl exec -it $1 /bin/bash;
}
kl()	{
	kubectl get pod,svc,deployments 2>/dev/null|sed "s/^/\t/"|sed "s/^\tNAME/>>\n\tNAME/"; echo
}
kla()	{
	kubectl get nodes,all,pv,pvc,ep,rs 2>/dev/null|sed "s/^/\t/"|sed "s/^\tNAME/>>\n\tNAME/"; echo
}
alias kc=/usr/bin/kubectl

# This takes a couple of seconds to load.
[ -f /usr/bin/kubectl ] && {
	. <(kubectl completion bash)
	complete -F __start_kubectl kc
}

####################################################################
# Config variables

export KUBECONFIG=/home/rodolfoap/.kube/config
export PATH=/home/rodolfoap/bin/:/usr/local/bin:/usr/bin:/bin
export PROMPT_COMMAND='PS1=$(echo "[\h] $(pwd) > ";)'

####################################################################
# Root

[ $UID -eq 0 ] && {
	export KUBECONFIG=/root/.kube/config
	export PATH=/root/bin/:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
	export PROMPT_COMMAND='PS1=$(echo "[\h] $(pwd) # ";)'
}

####################################################################
# Changedir aliases

alias g='cd ~/git'
