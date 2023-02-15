#!/data/data/com.termux/files/usr/bin/bash

## ANSI Colors (FG & BG)
RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"

## Reset terminal colors
reset_color() {
	printf '\033[37m'
}

## Script Termination
exit_on_signal_SIGINT() {
    { printf "${RED}\n\n%s\n\n" "[!] Program Interrupted." 2>&1; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM() {
    { printf "${RED}\n\n%s\n\n" "[!] Program Terminated." 2>&1; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Update, X11-repo, Program Installation
_pkgs=(curl fsmon git openssl-tool startup-notification termux-api vim make wget zsh librsvg nodejs yarn build-essential bash-completion build-essential binutils pkg-config python nodejs-lts gnupg ndk-sysroot)

setup_base() {
	echo -e ${RED}"\n[*] Installing Visual Studio Code..."
	echo -e ${CYAN}"\n[*] Updating Termux Base... \n"
	{ reset_color; pkg autoclean; pkg update; pkg upgrade -y; }
	echo -e ${CYAN}"\n[*] Enabling Termux repo... \n"
	{ 
		reset_color; 
		pkg install -y x11-repo; 
		pkg install -y unstable-repo; 
		pkg install -y game-repo;
		pkg install -y science-repo;
		pkg install -y tur-repo;
	}
	echo -e ${CYAN}"\n[*] Update repo... \n"
	{ 
		pkg update; 
		pkg upgrade -y; 
	}
	echo -e ${CYAN}"\n[*] Installing required programs... \n"
	for package in "${_pkgs[@]}"; do
		{ reset_color; pkg install -y "$package"; }
		_ipkg=$(pkg list-installed $package 2>/dev/null | tail -n 1)
		_checkpkg=${_ipkg%/*}
		if [[ "$_checkpkg" == "$package" ]]; then
			echo -e ${GREEN}"\n[*] Package $package installed successfully.\n"
			continue
		else
			{ pkg autoclean; pkg update; pkg upgrade -y; }
			echo -e ${RED}"\n[!] Error installing $package, Terminating...\n"
			echo -e ${MAGENTA}"\n[!] Run pkg upgrade -y and ./setup.sh agian \n"
			{ reset_color; exit 1; }
		fi
	done
	reset_color
}

## Install ZSH
install_zsh() {
	{ echo ${ORANGE}" [*] Installing ZSH..."${CYAN}; echo; }
	if [[ -f $PREFIX/bin/zsh ]]; then
		{ echo ${GREEN}" [*] ZSH is already Installed!"; echo; }
	else
		{ pkg update -y; pkg install -y zsh; }
		(type -p zsh &> /dev/null) && { echo; echo ${GREEN}" [*] Succesfully Installed!"; echo; } || { echo; echo ${RED}" [!] Error Occured, ZSH is not installed."; echo; reset_color; exit 1; }
	fi
}
## Setup OMZ and Termux Configs
setup_omz() {
	# backup previous termux and omz files
	echo -e ${GREEN}"[*] Setting up OMZ and termux configs..."
	omz_files=(.oh-my-zsh .termux .zshrc)
	for file in "${omz_files[@]}"; do
		echo -e ${CYAN}"\n[*] Backing up $file..."
		if [[ -f "$HOME/$file" || -d "$HOME/$file" ]]; then
			{ reset_color; mv -u ${HOME}/${file}{,.old}; }
		else
			echo -e ${MAGENTA}"\n[!] $file Doesn't Exist."			
		fi
	done
	# installing omz
	echo -e ${CYAN}"\n[*] Installing Oh-my-zsh... \n"
	{ reset_color; git clone https://github.com/robbyrussell/oh-my-zsh.git --depth 1 $HOME/.oh-my-zsh; }
	cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc
	sed -i -e 's/ZSH_THEME=.*/ZSH_THEME="aditya"/g' $HOME/.zshrc
	sed -i -e 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' $HOME/.zshrc
	sed -i -e 's|# export PATH=.*|export PATH=$HOME/.local/bin:$PATH|g' $HOME/.zshrc
	# ZSH theme
	cat > $HOME/.oh-my-zsh/custom/themes/aditya.zsh-theme <<- _EOF_
		# Default OMZ theme
		if [[ "\$USER" == "root" ]]; then
		  PROMPT="%(?:%{\$fg_bold[red]%}%{\$fg_bold[yellow]%}%{\$fg_bold[red]%} :%{\$fg_bold[red]%} )"
		  PROMPT+='%{\$fg[cyan]%}  %c%{\$reset_color%} \$(git_prompt_info)'
		else
		  PROMPT="%(?:%{\$fg_bold[red]%}%{\$fg_bold[green]%}%{\$fg_bold[yellow]%} :%{\$fg_bold[red]%} )"
		  PROMPT+='%{\$fg[cyan]%}  %c%{\$reset_color%} \$(git_prompt_info)'
		fi
		ZSH_THEME_GIT_PROMPT_PREFIX="%{\$fg_bold[blue]%}  git:(%{\$fg[red]%}"
		ZSH_THEME_GIT_PROMPT_SUFFIX="%{\$reset_color%} "
		ZSH_THEME_GIT_PROMPT_DIRTY="%{\$fg[blue]%}) %{\$fg[yellow]%}✗"
		ZSH_THEME_GIT_PROMPT_CLEAN="%{\$fg[blue]%})"
	_EOF_
	# Append some aliases
	cat >> $HOME/.zshrc <<- _EOF_
		#------------------------------------------
		alias l='ls -lh'
		alias ll='ls -lah'
		alias la='ls -a'
		alias ld='ls -lhd'
		alias p='pwd'
		#alias rm='rm -rf'
		alias u='cd $PREFIX'
		alias h='cd $HOME'
		alias :q='exit'
		alias grep='grep --color=auto'
		alias open='termux-open'
		alias lc='lolcat'
		alias xx='chmod +x'
		alias rel='termux-reload-settings'
		#------------------------------------------
		# SSH Server Connections
		# linux (Arch)
		alias arch='ssh UNAME@IP -i ~/.ssh/id_rsa.DEVICE'
		# linux sftp (Arch)
		alias archfs='sftp -i ~/.ssh/id_rsa.DEVICE UNAME@IP'
	_EOF_

	# configuring termux
	echo -e ${CYAN}"\n[*] Configuring Termux..."
	reset_color
	if [[ ! -d "$HOME/.termux" ]]; then
		mkdir $HOME/.termux
	fi
	# button config
	cat > $HOME/.termux/termux.properties <<- _EOF_
		extra-keys = [ \\
		 ['ESC','|', '/', '~','HOME','UP','END'], \\
		 ['CTRL', 'TAB', '=', '-','LEFT','DOWN','RIGHT'] \\
		]	
	_EOF_
	# change shell and reload configs
	{ chsh -s zsh; termux-reload-settings; termux-setup-storage; }
	if [[ ! -d "$HOME/Downloads" ]]; then
		mkdir $HOME/Downloads 
	fi
	if [[ ! -d "$HOME/Templates" ]]; then
		mkdir $HOME/Templates 
	fi
	if [[ ! -d "$HOME/Public" ]]; then
		mkdir $HOME/Public
	fi
	if [[ ! -d "$HOME/Documents" ]]; then
		mkdir $HOME/Documents 
	fi
	if [[ ! -d "$HOME/Pictures" ]]; then
		mkdir $HOME/Pictures 
	fi
	if [[ ! -d "$HOME/Video" ]]; then
		mkdir $HOME/Video 
	fi
	if [[ ! -d "$HOME/Pictures/backgrounds" ]]; then
		mkdir $HOME/Pictures/backgrounds
	fi
}
## Install adb
install_adb() {
	echo -e ${GREEN}"\n[*] install ADB file..."
	echo -e ${CYAN}"\n[*] Download from github... "
	reset_color
	{ curl https://github.com/MasterDevX/Termux-ADB/raw/master/InstallTools.sh -o InstallTools.sh; bash InstallTools.sh; rm InstallTools.sh;}
}

## Install Visual Code
install_vsc_repo() {
	echo -e ${GREEN}"\n[*] install Visual Sutdio Code Source..."
	reset_color
	{
	  wget https://packages.microsoft.com/keys/microsoft.asc -q;
	  apt-key add microsoft.asc;
	  gpg --dearmor microsoft.asc > packages.microsoft.gpg;
	  cp -rf packages.microsoft.gpg $PREFIX/etc/apt/trusted.gpg.d/
	  rm -rf microsoft.asc;
	  rm -rf packages.microsoft.gpg;
	}
	echo -e ${GREEN}"\n[*] install GCC Source..."
	reset_color
	{
	  wget https://its-pointless.github.io/setup-pointless-repo.sh -q;
	  chmod +x setup-pointless-repo.sh; 
	  bash setup-pointless-repo.sh;
	  rm setup-pointless-repo.sh;
	}
}

configure_vsc(){
	echo -e ${GREEN}"\n[*] Configure Visual Studio Code...\n"	
	reset_color
	{ pkg install code-server; }
	echo -e ${GREEN}"\n[*] Configure port and password...\n"	
	reset_color
		{ 
			wget https://raw.githubusercontent.com/afonsoft/termux-vsc/main/config.yaml -q;
			cp -rf config.yaml  ~/.config/code-server/config.yaml;
		}
}

setup_net() {
	echo -e ${GREEN}"[*] Install Mono and DotNet... \n"
	reset_color
	{ 
			pkg update;
			pkg upgrade -y;
			pkg install mono -y;
			wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -q;
			chmod +x dotnet-install.sh;
			./dotnet-install.sh -c LTS;
			./dotnet-install.sh -c STS;
			echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
			echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools' >> ~/.bashrc
		}
	

}
setup_finaly() {
	echo -e ${ORANGE}"\n[*] Installation successfully completed....."
	echo -e ${GREEN}"\n[*] Default Port is: $RED 8091 "	
	echo -e ${GREEN}"\n[*] Default password is: $RED 123qwe "	
	echo -e ${GREEN}"[*] Run $RED code-server $GREEN for start."
}

install_vsc() {
	clear
	setup_base
	clear
	install_zsh
	setup_omz
	install_vsc_repo
	setup_net
	install_adb
	configure_vsc
	setup_finaly
}

## Main
install_vsc
