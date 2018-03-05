#!/bin/bash
#build go envirment

VERSION=1.10

function build() {
	tag="ubuntu_go:$VERSION"
	wkd="."
	dkf="./Dockerfile_for_go"
	cmd="docker build -t $tag --build-arg VERSION=$VERSION $wkd -f $dkf"
	echo $cmd
	$cmd
}

function init() {
	url="https://dl.google.com/go/go$VERSION.linux-amd64.tar.gz"
	pkg=${url##*/}

	if [ ! -e $pkg ]; then
		curl -o $pkg $url 
	fi
	echo "init down!"
}

function run() {
	dkn="ubuntu_go_$VERSION"
	gph="/root/gopath"
	dki="ubuntu_go:$VERSION"
	cmd="docker run -it --rm --name $dkn -v $GOPATH:$gph $dki bash"
	echo $cmd
	$cmd
}

function main() {
	if [ $# -ge 2 ]; then
		VERSION=$2
	fi
	case $1 in
		"init")
			init
			;;
		"build")
			build
			;;
		"run")
			run
			;;
		*)
			echo "Usage: $0 [init|build|run] version"
			;;
	esac
}

main $*
