.PHONY: init


init:
	cp .sbclrc ~/
	if [ -e ~/quicklisp/local-projects ]; then  mv ~/quicklisp/local-projects ~/quicklisp/local-projects.bak.`date +%s` ; fi
	ln -fs $$PWD/local-projects $$HOME/quicklisp/local-projects
