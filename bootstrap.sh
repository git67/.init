#!/usr/bin/env bash 

#set -x

# ident "@(#)<bootstrap> <1.0>"
#
# desc          : <Bootstrap User Env>
# version       : <0.9>
# dev           : <heiko.stein@etomer.com>
#
# changelog:
#

# var
CFG=".bootstrap.cfg"
FOUND=""
PLAYBOOK="p_bootstrap.yml"

# func
_line()
{
	CHAR=${1:-"-"}
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ${CHAR}
}

_print()
{
	STR=${1:-"undef"}
	printf '\t%s\n' "${STR}"
}

_get_cfg()
{
	_print "Konfig ..."

	FILE=${1:-"undef"}
	
	if [ ! -f ./${FILE} ] || [ ! -r ./${FILE} ];then
        	_print "Konfigfile ${FILE} nicht vorhanden bzw. nicht lesbar."
        	exit 1
	else
		_print "Lese ${CFG} ein ..."
		source ./${FILE}
	fi

	_print "... ok"
}

_create_ssh_key()
{
	_print "Erzeuge SSH Keys, soweit noetig ..."
	if [ ! -f "${HOME}/.ssh/id_rsa" ];then
		_print "Erzeuge SSH Keys ..."
		ssh-keygen -t rsa -b 4096  -f ~/.ssh/id_rsa -q -N '' <<< n >/dev/null 2>&1
	fi

	if [ -f ${HOME}/.ssh/authorized_keys ];then
		FOUND=$(grep "$(cat  ${HOME}/.ssh/id_rsa.pub |awk '{print $2}')" ${HOME}/.ssh/authorized_keys)
	fi

	if [ "x${FOUND}" == "x" ]; then
		echo "rein"
		cat  ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
		chmod 600 ~/.ssh/authorized_keys
	fi

	_print "... ok"
}

_create_python_venv()
{
	_print "Erzeuge Python 3 ${VENV} ..."
	python3 -m venv ${VENV}

	_print "Aktiviere Python3 ${VENV} ..."
	source ${VENV}/bin/activate

	if [ ! -f ${BASEDIR}/requirements.pip ] || [ ! -r ${BASEDIR}/requirements.pip ];then
        	_print "Datei requirements.pip nicht vorhanden bzw. nicht lesbar."
        	exit 1
	else
		_print "Installiere ${BASEDIR}/requirements.pip in ${VENV} ..."
		pip install -qUr ${BASEDIR}/requirements.pip
	fi

	deactivate

	_print "... ok"
}

_run_playbook()
{
	PL=${1:-"undef"}
	_print "Starte Ansible playbook ${PL} ..."


	if [ ! -f ${PLDIR}/${PL} ]; then
		_print "Playbook ${PLDIR}/${PL} nicht vorhanden."
                exit 1
	fi
	
	source ${VENV}/bin/activate

	cd ${PLDIR}
	#ansible-playbook ${PL} >/dev/null 2>&1
	ansible-playbook ${PL} -e group_name=bootstrapnode --ask-become-pass >/dev/null 2>&1

	deactivate

	_print "... ok"
}


# main
[ ! "${-#*i}" == "$-" ] && _print "usage: $(basename ./$0)" && exit 1

_line

_get_cfg ${CFG}

_create_ssh_key  

_create_python_venv 

_run_playbook ${PLAYBOOK}

_line

exit 0
