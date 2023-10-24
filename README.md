# Bootstrap Enwicklungsumgebung - Funktionsumfang

##### Erzeugung SSH Keys, wenn nicht vorhanden 

##### Erstellung erweiterte sudo role für den M-User

##### Konfiguration Shell Umgebung (bash)
```
	- ~/.gitconfig
	- ~/.vimrc
	- ~/.bashrc
	- ~/.bash_aliases
```

##### Setup virtuelles Python Environment (venv) 
```
	- ~/.pyv
```

##### Installation Ansible-Core und relevanter Packages (pip) in das virtuelles Python Environment 
```
	- wheel
	- pip
	- ansible
	- ansible-lint
	- ansible-navigator
	- flake8
	- tox
	- pylint
	- pre-commit
	- sphinx
	- sphinx-rtd-theme
```

##### Installation relevanter Packages (rpm) in die VM
```
	- apt-file 
	- wget
	- bind9-dnsutils
	- vim
	- sysstat
	- dstat
```

##### Installation docker/docker-cli/containerd

##### Konfigurationsfiles
```

data/files	->	Hier abgelegte Files werden nach ${HOME} kopiert

data/packages	->	Hier können zu installierende Linux-Pkg's hinterlegt werden

data/pip	->	Hier können in das Python Venv zu installierende Pakete hinterlegt werden 

data/templates	->	Hier abgelegte Templates (Jinja2) werden interpretiert und nach ${HOME} kopiert

```

#### Ausführung Bootstrap 
```
git clone https://gisu669.gisamgmt.global/bitbucket/scm/G-POS/pos_ansible_init .init && .init/bootstrap.sh
```

#### Aktivierung virtuelles Python Environment
```
. ~/.pyv/bin/activate
```

#### Deaktivierung virtuelles Python Environment
```
deactivate
```
