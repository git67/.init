#!/usr/bin/env bash 

set -euo pipefail

# ident "@(#)<bootstrap> <1.0>"
#
# desc          : <Bootstrap User Env>
# version       : <0.9>
# dev           : <heiko.stein@etomer.com>
#
# changelog:
# ...

# var
# globals
PATH="${PATH}:/:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin"
SILENT=${1:-'>/dev/null 2>&1'}
export HOSTN=$(uname -n)
export USERN=$(whoami|cut -d \\ -f2)

# shell
BASEDIR="$(dirname $(realpath $0))"
TPLDIR="${BASEDIR}/templates"

# python venv
VENVN=".pyv"
VENV="$(cd;pwd)/${VENVN}"

# ansible
PLDIR="${BASEDIR}/playbooks"
INVDIR="${PLDIR}/inventories"
INVENTORY="${INVDIR}/hosts"
INVENTORYTPL="${TPLDIR}/hosts.tpl"
DATA="${PLDIR}/data"
PLAYBOOK="p_bootstrap.yml"

# helper
CMD=""
FOUND=""

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

_create_ssh_key()
{
	_print "Erzeuge SSH Keys, soweit noetig ..."
	if [ ! -f "${HOME}/.ssh/id_rsa" ];then
		_print "Erzeuge SSH Keys ..."
		CMD="ssh-keygen -t rsa -b 4096  -f ~/.ssh/id_rsa -q -N '' <<< n ${SILENT}"
		eval "${CMD}"

		[ $? != 0 ] && _print "...Fehler bei ${CMD}" && exit 1	

	fi

	if [ -f ${HOME}/.ssh/authorized_keys ];then
		FOUND=$(grep "$(cat  ${HOME}/.ssh/id_rsa.pub |awk '{print $2}')" ${HOME}/.ssh/authorized_keys)
	fi

	if [ "x${FOUND}" == "x" ]; then
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

	if [ ! -f ${DATA}/pip/requirements.pip ] || [ ! -r ${DATA}/pip/requirements.pip ];then
        	_print "Datei requirements.pip nicht vorhanden bzw. nicht lesbar."
        	exit 1
	else
		_print "Installiere ${DATA}/pip/requirements.pip in ${VENV} ..."
		pip install -qUr ${DATA}/pip/requirements.pip
	fi

	deactivate

	_print "... ok"
}

_template_ansible_inventory()
{
	_print "Template Ansible Inventory ..."
	
	mkdir -p ${INVDIR}
	
	envsubst < ${INVENTORYTPL} > ${INVENTORY} 	

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
	
	mkdir -p ${PLDIR}/log

	CMD="ansible-playbook ${PL} -i ${INVENTORY} -e group_name=bootstrapnode --ask-become-pass ${SILENT}"
	eval "${CMD}"

	[ $? != 0 ] && _print "...Fehler bei ${CMD}" && exit 1	

	deactivate

	_print "... ok"
}


# main
[ ! "${-#*i}" == "$-" ] && _print "usage: $(basename ./$0)" && exit 1

_line

_create_ssh_key  

_create_python_venv 

_template_ansible_inventory

_run_playbook ${PLAYBOOK}

_line

exit 0
