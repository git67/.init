# Bootstrap Enwicklungsumgebung
#### Funktionsumfang
```
- Erzeugung SSH Keys 
- Ablage standardisierter Dot-Files
	- ~/.gitconfig
	- ~/.vimrc
	- ~/.bashrc
	- ~/.bash_aliases

- Setup Python venv
	- ~/.pyv

- Installation relevanter Packages (pip) in die venv
	- wheel
	- pip
	- ansible
	- ansible-lint
	- flake8
	- tox
	- pylint
	- pre-commit
	- sphinx
	- sphinx-rtd-theme

- Installation relevanter Packages (rpm) in die VM
	- apt-file 
	- wget
	- bind9-dnsutils
	- vim
	- sysstat
	- dstat
```

#### Ausführung Bootstrap 
```
git clone https://github.com/git67/.init.git && .init/bootstrap.sh
```
