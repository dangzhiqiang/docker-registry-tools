#!/bin/bash

REGISTRY="127.0.0.1:5000"

usage() {
	echo "
Usage:
	$0 list [REGISTRY]          # list all images from current REGISTRY, default is $REGISTRY
	$0 show IMAGE [REGISTRY]    # list all tags form IMAGE
	$0 show --all [REGISTRY]    # list all tags form all images

	$0 -h or --help             # show this help info
"
}

which docker >/dev/null 2>&1
if [ $? != 0 ]; then
	echo "Error: No docker command is found"
	exit 1
fi

show_images() {
	local images_str=`curl http://$REGISTRY/v2/_catalog 2>/dev/null | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $2}'`
	local images=${images_str//\,/\ }
	for image in $images; do
		echo $image
	done
}

check_image() {
	images=$(show_images)
	for images in $images; do
		if [ "$images" = "$1" ]; then
			i_find=1
		fi
	done
	if [ "$i_find" != "1" ]; then
		echo "Args error, can not find image: $1"
		exit 1
	fi
}

show_tags() {
	local image=$1
	local tags_str=`curl http://$REGISTRY/v2/$image/tags/list 2>/dev/null | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'`
	local tags=${tags_str//\,/\ }
	for tag in $tags; do
		echo $tag
	done
}

show_all_tags() {
	images=$(show_images)
	for images in $images; do
		show_tags $images | awk '{print "'"$images:"'" $0}'
	done
}

check_registry() {
	if [ "$1" != "" ]; then
		REGISTRY=$1
	fi
	curl -m 2 http://$REGISTRY/v2/_catalog >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "Error: REGISTRY $REGISTRY is invalid"
		exit 1
	fi
}

if [ "$1" = "-h" -o "$1" = "--help"  -o "$1" == "" ]; then
	usage
	exit 0
fi

if [ "$1" = "list" ]; then
	check_registry $2
	show_images
	exit 0
fi

if [ "$1" = "show" -a "$2" != "" ]; then
	check_registry $3
	if [ "$2" = "--all" ]; then
		show_all_tags
	else
		check_image $2
		show_tags $2 | awk '{print "'"$2:"'" $0}'
		exit 0
	fi
else
	echo "Arg error!"
	usage
fi