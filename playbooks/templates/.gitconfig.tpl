[user]
	name = ${USERN}
	email = ${USERN}@${HOSTN}.gisa.intern
	username = ${USERN}
[core]
	editor = vim
	whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
	pager = delta
[credential]
	helper = store
[alias]
    	aa = add --all
    	bv = branch -vv
    	ba = branch -ra
    	bd = branch -d
    	ca = commit --amend
    	cb = checkout -b
    	cm = commit -a --amend -C HEAD
    	ci = commit -a -v
    	co = checkout
    	di = diff
    	lo = log
    	ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
    	ld = log --pretty=format:"%C(yellow)%h\\ %C(green)%ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short --graph
    	ls = log --pretty=format:"%C(green)%h\\ %C(yellow)[%ad]%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative
    	mm = merge --no-ff
    	st = status --short --branch
    	tg = tag -a 
    	pu = push --tags
    	un = reset --hard HEAD  
    	uh = reset --hard HEAD^
[color]  
    	diff = auto  
    	status = auto  
    	branch = auto 
[branch]  
    	autosetuprebase = always
