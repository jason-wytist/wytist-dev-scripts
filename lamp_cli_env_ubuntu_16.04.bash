#!/bin/bash

# Setting LAMP CLI ENV
#
alias lamp-current='echo "[ PATH ]";echo $PATH;echo "";echo "[ LAMP_STACK_VERSION_NAME ]";echo $LAMP_STACK_VERSION_NAME;echo "";echo "[ /tmp/current_lamp_cli_env ]";cat /tmp/current_lamp_cli_env'

## lamp ctl script aliases (Add new versions here) ##
# LAMP 5.6.29
alias lamp-ctl-5.6.29='sudo /opt/lampstack-5.6.29/ctlscript.sh'
alias lamp-status-5.6.29='lamp-ctl-5.6.29 status'
alias lamp-cli-on-5.6.29='start_lamp lampstack-5.6.29'
alias lamp-cli-off-5.6.29='stop_lamp lampstack-5.6.29'

## MAIN ##
# gloval variable
LAMP_STACK_VERSION_NAME=""

# initialize lamp cli environment using /tmp/current_lamp_cli_env
if [ -e /tmp/current_lamp_cli_env ]; then
	echo "===================================================================="
	echo "[INFO] Initialize LAMP CLI Env w/ /tmp/current_lamp_cli_env         "
	cat /tmp/current_lamp_cli_env
	echo "===================================================================="
	source /tmp/current_lamp_cli_env
fi

# set_lamp_cli_env()
function set_lamp_cli_env() {
	stack_version=$1

	# Start Message
	echo "======================================================="
	echo "    SET lamp $stack_version cli env                    "
	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"

	# Check Current LAMP CLI Env Setup
	if [ -e /tmp/current_lamp_cli_env ]; then
		echo "[Error] Check Current LAMP CLI Env Setup"
		echo "======================================================="
		return 1
	fi

	# Core
	PATH=/opt/$stack_version/php/bin:$PATH
	PATH=/opt/$stack_version/mysql/bin:$PATH
	export PATH

	# if [ ! -L /tmp/mysql.sock ]; then
	# 	ln -s /opt/$stack_version/mysql/tmp/mysql.sock /tmp/mysql.sock
	# else
	# 	rm /tmp/mysql.sock
	# 	ln -s /opt/$stack_version/mysql/tmp/mysql.sock /tmp/mysql.sock
	# fi

	echo "export PATH=/opt/$stack_version/php/bin:/opt/$stack_version/mysql/bin:\$PATH;LAMP_STACK_VERSION_NAME=$stack_version" > /tmp/current_lamp_cli_env

	# Log Message
	echo "[LOG]"
	echo $PATH
	cat /tmp/current_lamp_cli_env
	# ls -al /tmp/mysql.sock
	echo "======================================================="

	return 0
}

# core function2
function unset_lamp_cli_env() {
	stack_version=$1

	# Start Message
	echo "======================================================="
	echo "    UNSET lamp $stack_version cli env                  "
	echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"

	# Core
	lamp_php_path="/opt/$stack_version/php/bin:"
	lamp_mysql_path="/opt/$stack_version/mysql/bin:"
	PATH=${PATH//$lamp_php_path/}
	PATH=${PATH//$lamp_mysql_path/}
	export PATH

	# if [ -L /tmp/mysql.sock ]; then
	# 	rm /tmp/mysql.sock
	# fi

	if [ -e /tmp/current_lamp_cli_env ]; then
		rm /tmp/current_lamp_cli_env
	fi

	# Log Message
	echo "[LOG]"
	echo $PATH
	# ls -al /tmp/mysql.sock
	ls -al /tmp/current_lamp_cli_env
	# if [ -L /tmp/mysql.sock ]; then
	# 	echo "REMOVE /tmp/mysql.sock file manually"
	# fi
	if [ -e /tmp/current_lamp_cli_env ]; then
		echo "[Warning] REMOVE /tmp/current_lamp_cli_env manually"
	fi
	echo "======================================================="
}

# lamp
function start_lamp() {
	LAMP_STACK_VERSION_NAME=$1

	if [ ! -d /opt/$LAMP_STACK_VERSION_NAME ]; then
		echo "[Error] $LAMP_STACK_VERSION_NAME version not installed"
		return 2
	fi

	set_lamp_cli_env $LAMP_STACK_VERSION_NAME
	res=$?

	if [ $res -eq  1 ]; then
		echo "[INFO] Stop LAMP"
		sudo /bin/bash /opt/$LAMP_STACK_VERSION_NAME/ctlscript.sh stop
	else
		echo "[INFO] Restart LAMP"
		sudo /bin/bash /opt/$LAMP_STACK_VERSION_NAME/ctlscript.sh restart
	fi
}

function stop_lamp() {
	LAMP_STACK_VERSION_NAME=$1

	if [ ! -d /opt/$LAMP_STACK_VERSION_NAME ]; then
		echo "[Error] $LAMP_STACK_VERSION_NAME version not installed"
		return 2
	fi

	echo "[INFO] Stop LAMP"
	sudo /bin/bash /opt/$LAMP_STACK_VERSION_NAME/ctlscript.sh stop
	unset_lamp_cli_env $LAMP_STACK_VERSION_NAME

	LAMP_STACK_VERSION_NAME=""
}
