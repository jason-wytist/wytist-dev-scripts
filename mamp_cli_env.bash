#!/bin/bash

# Setting MAMP CLI ENV
#
alias mamp-current='echo "[ PATH ]";echo $PATH;echo "";echo "[ MAMP_STACK_VERSION_NAME ]";echo $MAMP_STACK_VERSION_NAME;echo "";echo "[ /tmp/current_mamp_cli_env ]";cat /tmp/current_mamp_cli_env'

## mamp ctl script aliases (Add new versions here) ##
# MAMP 5.6
alias mamp-ctl-5.6='/Applications/mampstack-5.6/ctlscript.sh'
alias mamp-status-5.6='mamp-ctl-5.6 status'
alias mamp-cli-on-5.6='start_mamp mampstack-5.6'
alias mamp-cli-off-5.6='stop_mamp mampstack-5.6'

# MAMP 7.1
alias mamp-ctl-7.1='/Applications/mampstack-7.1/ctlscript.sh'
alias mamp-status-7.1='mamp-ctl-7.1 status'
alias mamp-cli-on-7.1='start_mamp mampstack-7.1'
alias mamp-cli-off-7.1='stop_mamp mampstack-7.1'

## MAIN ##
# gloval variable
MAMP_STACK_VERSION_NAME=""

# initialize mamp cli environment using /tmp/current_mamp_cli_env
if [ -e /tmp/current_mamp_cli_env ]; then
	echo "===================================================================="
	echo "[INFO] Initialize MAMP CLI Env w/ /tmp/current_mamp_cli_env         "
	cat /tmp/current_mamp_cli_env
	echo "===================================================================="
	source /tmp/current_mamp_cli_env
fi

# set_mamp_cli_env() function
function set_mamp_cli_env() {
	stack_version=$1

	# Start Message
	echo "======================================================="
	echo "    SET mamp $stack_version cli env                    "
	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"

	# Check Current MAMP CLI Env Setup
	if [ -e /tmp/current_mamp_cli_env ]; then
		echo "[Error] Check Current MAMP CLI Env Setup"
		echo "======================================================="
		return 1
	fi

	# Core
	PATH=/Applications/$stack_version/php/bin:$PATH
	PATH=/Applications/$stack_version/mysql/bin:$PATH
	export PATH

	# if [ ! -L /tmp/mysql.sock ]; then
	# 	ln -s /Applications/$stack_version/mysql/tmp/mysql.sock /tmp/mysql.sock
	# else
	# 	rm /tmp/mysql.sock
	# 	ln -s /Applications/$stack_version/mysql/tmp/mysql.sock /tmp/mysql.sock
	# fi

	echo "export PATH=/Applications/$stack_version/php/bin:/Applications/$stack_version/mysql/bin:\$PATH;MAMP_STACK_VERSION_NAME=$stack_version" > /tmp/current_mamp_cli_env

	# Log Message
	echo "[LOG]"
	echo $PATH
	cat /tmp/current_mamp_cli_env
	# ls -al /tmp/mysql.sock
	echo "======================================================="

	return 0
}

# unset_mamp_cli_env() function
function unset_mamp_cli_env() {
	stack_version=$1

	# Start Message
	echo "======================================================="
	echo "    UNSET mamp $stack_version cli env                  "
	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"

	# Core
	mamp_php_path="/Applications/$stack_version/php/bin:"
	mamp_mysql_path="/Applications/$stack_version/mysql/bin:"
	PATH=${PATH//$mamp_php_path/}
	PATH=${PATH//$mamp_mysql_path/}
	export PATH

	# if [ -L /tmp/mysql.sock ]; then
	# 	rm /tmp/mysql.sock
	# fi

	if [ -e /tmp/current_mamp_cli_env ]; then
		rm /tmp/current_mamp_cli_env
	fi

	# Log Message
	echo "[LOG]"
	echo $PATH
	# ls -al /tmp/mysql.sock
	ls -al /tmp/current_mamp_cli_env
	# if [ -L /tmp/mysql.sock ]; then
	# 	echo "REMOVE /tmp/mysql.sock file manually"
	# fi
	if [ -e /tmp/current_mamp_cli_env ]; then
		echo "[Warning] REMOVE /tmp/current_mamp_cli_env"
	fi
	echo "======================================================="
}

# start_mamp() function
function start_mamp() {
	MAMP_STACK_VERSION_NAME=$1

	if [ ! -d /Applications/$MAMP_STACK_VERSION_NAME ]; then
		echo "[Error] $MAMP_STACK_VERSION_NAME version not installed"
		return 2
	fi

	set_mamp_cli_env $MAMP_STACK_VERSION_NAME
	res=$?

	if [ $res -eq  1 ]; then
		echo "[INFO] Stop MAMP"
		/bin/bash /Applications/$MAMP_STACK_VERSION_NAME/ctlscript.sh stop
	else
		echo "[INFO] Restart MAMP"
		/bin/bash /Applications/$MAMP_STACK_VERSION_NAME/ctlscript.sh restart
	fi
}

# stop_mamp() function
function stop_mamp() {
	MAMP_STACK_VERSION_NAME=$1

	if [ ! -d /Applications/$MAMP_STACK_VERSION_NAME ]; then
		echo "[Error] $MAMP_STACK_VERSION_NAME version not installed"
		return 2
	fi

	echo "[INFO] Stop MAMP"
	/bin/bash /Applications/$MAMP_STACK_VERSION_NAME/ctlscript.sh stop
	unset_mamp_cli_env $MAMP_STACK_VERSION_NAME

	MAMP_STACK_VERSION_NAME=""
}
