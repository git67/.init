#!/usr/bin/env bash 
#set -euo pipefail

# ident "@(#)<bootstrap> <1.0>"
#
# desc          : <Bootstrap User Env>
# version       : <0.9>
# dev           : <heiko.stein@etomer.com>
#
# changelog:
# ...

# var
PATH="${PATH}:/:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin"
SILENT=${1:+'>/dev/null 2>&1'}

export HOSTN=$(uname -n)
export USERN=$(whoami|cut -d \\ -f2)

# shell
S_BASEDIR="$(dirname $(realpath $0))"
S_DATADIR="${S_BASEDIR}/data"
S_TA_PLDIR="${S_DATADIR}/shell"
S_FILEDIR="${S_DATADIR}/files"
S_PIPDIR="${S_DATADIR}/pip"

# python venv
VENVN=".pyv"
VENV="$(cd;pwd)/${VENVN}"
V_PIPCONFDIR="$(cd;pwd)/.config/pip"
V_PIPCONFFILE="pip.conf"

# ansible
A_PLDIR="${S_BASEDIR}"
A_INVDIR="${A_PLDIR}/inventories"
A_INVENTORY="${A_INVDIR}/hosts"
A_INVENTORYTPL="${S_TA_PLDIR}/hosts.tpl"
A_DATADIR="${A_PLDIR}/data"
A_PLAYBOOK="p_bootstrap.yml"

# helper
CMD=""
FOUND="NONE"
PUB="NONE"

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

_help()
{
	clear
	[ -f ./README.md ] && cat ./README.md | sed -e '/^`/d' | more
}

_init()
{
	[ $(locale -a | grep -w "en_US.utf8")  ] && export LANG="en_US.utf8"
	trap "_help;exit 1" 2
}

_create_ssh_key()
{
	_print "Erzeuge SSH Keypair, soweit noetig ..."
	
	[ -d ${HOME}/.ssh ] && PUB=$(ls ~/.ssh/ | grep '.pub')

	if [ "${PUB}" == "NONE" ];then
		_print "Erzeuge SSH Keypair ..."
		CMD="ssh-keygen -t rsa -b 4096  -f ~/.ssh/id_rsa -q -N '' <<< n ${SILENT}"
		eval "${CMD}"

		[ $? != 0 ] && _print "... Fehler bei ${CMD}" && exit 1	
	
		_print "Schreibe ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys ..."
		cat  ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
		chmod 600 ~/.ssh/authorized_keys
	else
		_print "SSH Keypair bereits vorhanden ..."
		for PUB_KEY in ${PUB}
		do
			if [ -f ${HOME}/.ssh/authorized_keys ];then
				FOUND=$(grep "$(cat ${HOME}/.ssh/${PUB_KEY} |awk '{print $2}')" ${HOME}/.ssh/authorized_keys)
				if [ "x${FOUND}" == "x" ]; then
					_print "Schreibe ~/.ssh/${PUB_KEY} >> ~/.ssh/authorized_keys ..."
					cat  ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
					chmod 600 ~/.ssh/authorized_keys
				fi
			else
				_print "Schreibe ~/.ssh/${PUB_KEY} >> ~/.ssh/authorized_keys ..."
				cat  ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
				chmod 600 ~/.ssh/authorized_keys
			fi
		done
	fi

	_print "... ok"
}

_copy_pip_config()
{
	_print "Kopiere pip Konfig File ..."
	cd 

	if [ ! -d ${V_PIPCONFDIR} ]; then
		mkdir -p ${V_PIPCONFDIR}
	fi

	if [ ! -f ${V_PIPCONFDIR}/${V_PIPCONFFILE} ]; then
		cp ${S_PIPDIR}/${V_PIPCONFFILE} ${V_PIPCONFDIR}
	fi

	_print "... ok"
}

_create_python_venv()
{
	_print "Erzeuge Python 3 ${VENV} ..."
	python3 -m venv ${VENV}

	_print "Aktiviere Python3 ${VENV} ..."
	source ${VENV}/bin/activate

	if [ ! -f ${S_PIPDIR}/requirements.pip ] || [ ! -r ${S_PIPDIR}/requirements.pip ];then
        	_print "Datei requirements.pip nicht vorhanden bzw. nicht lesbar."
        	exit 1
	else
		_print "Installiere ${S_PIPDIR}/requirements.pip in ${VENV} ..."
		pip install -qUr ${S_PIPDIR}/requirements.pip
	fi

	deactivate

	_print "... ok"
}

_template_ansible_inventory()
{
	_print "Template Ansible Inventory ..."
	
	mkdir -p ${A_INVDIR}
	
	envsubst < ${A_INVENTORYTPL} > ${A_INVENTORY} 	

	_print "... ok"
}



_run_playbook()
{
	PL=${1:-"undef"}
	_print "Starte Ansible playbook ${PL} ..."


	if [ ! -f ${A_PLDIR}/${PL} ]; then
		_print "Playbook ${A_PLDIR}/${PL} nicht vorhanden."
                exit 1
	fi
	
	source ${VENV}/bin/activate

	cd ${A_PLDIR}
	
	mkdir -p ${A_PLDIR}/log

	CMD="ansible-playbook ${PL} -i ${A_INVENTORY} -e group_name=bootstrapnode --ask-become-pass ${SILENT}"
	eval "${CMD}"

	[ $? != 0 ] && _print "... Fehler bei ${CMD}" && exit 1	

	deactivate

	_print "... ok"
}

_probe_mn()
{
	_print "Pruefe eingegebenen Node ${MN[${INDEX}]} ..."

	local PINGHOST=${1:-"NO_HOST_GIVEN"}
	local DEADLINE=${2:-"1"}
	local TIMEOUT=${3:-"10"}

	ping ${PINGHOST} -w ${DEADLINE} -W ${TIMEOUT} > /dev/null 2>&1 
	[ $? != 0 ] && _print "... managed Node ${PINGHOST} ist nicht verfügbar oder nicht erreichbar" && return 1	
	
	_print "... ok"
}
	
_add_managed_nodes_2_inventory()
{
	local NODELIST=${1:-"NO_NODES"}	
	_print "Erweitere Ansible Inventory ${A_INVENTORY} um Nodes: ${NODELIST} ..."
}

_get_managed_nodes()
{
	_print "Zu nutzende managed Nodes eingeben ..."
	_print "Beendigung mit Leereingabe ... "
	declare -A MN_LIST
	local INDEX=1
	local NOT_FOUND="0"

	while read -p "Managed Node ${INDEX}: " MN_LIST[${INDEX}]
	do
		if [ "${MN_LIST[${INDEX}]}" == "" ]; then
			break
		fi
		
		if [ "$(echo "${LAST_MN_LIST}"| grep -F -w ${MN_LIST[${INDEX}]})" != "" ]; then
			_print "Managed Node ${MN_LIST[${INDEX}]} wurde bereits erfasst ..."
			NOT_FOUND="1"
		else
			_probe_mn ${MN_LIST[${INDEX}]} 
			NOT_FOUND="$?"
		fi
		
		if [ "${NOT_FOUND}" == "0" ]; then 
			LAST_MN_LIST=${MN_LIST[*]}
			((INDEX+=1))
		fi
	done

	_add_managed_nodes_2_inventory "${MN_LIST[*]}"
}


# main
[ ! "${-#*i}" == "$-" ] && _print "usage: $(basename ./$0)" && exit 1
clear 

_line

_init

#_create_ssh_key  

#_copy_pip_config

#_create_python_venv 

#_template_ansible_inventory

#_run_playbook ${A_PLAYBOOK} 

_get_managed_nodes

_line

exit 0
