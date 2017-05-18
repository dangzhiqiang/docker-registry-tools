#!/bin/bash

REGISTRY="127.0.0.1:5000"

usage() {
	echo "
Usage:
	$0 list [REGISTRY]          # list all images from current REGISTRY, default is $REGISTRY
	$0 show IMAGE [REGISTRY]    # list all tags form IMAGE
	$0 show --all [REGISTRY]    # list all tags form all images
	$0 push --all REGISTRY      # auto tag and push all local images to remote REGISTRY registry

	$0 -h or --help             # show this help info

Note:
	Push images must set REGISTRY, and REGISTRY is not support 127.0.0.1:*
"
}

check_cmd() {
	which docker >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "Error: No docker command is found"
		exit 1
	fi
}

show_images() {
	local IP=$REGISTRY

	str1=$(curl https://$REGISTRY/v2/_catalog 2>/dev/null)
	if [ "${PIPESTATUS[0]}" = "35" ]; then
		str1=$(curl http://$REGISTRY/v2/_catalog 2>/dev/null)
	fi
	str2=$(echo ${str1##*\"repositories\"\:})
	tags=$(echo ${str2//[\[|\]|\,|\"|\}]/ })

	for tag in $tags; do
		echo $tag
	done
}

check_image() {
	local images=$(show_images)
	for images in $images; do
		if [ "$images" = "$1" ]; then
			i_find=1
		fi
	done
	if [ "$i_find" != "1" ]; then
		if [ "$images" != "" ]; then
			echo "Error: can not find image \"$1\" from catalog"
			exit 1
		else
			echo "Warning: can not find image \"$1\" from catalog, may UNAUTHORIZED"
		fi
	fi
}

show_tags() {
	local IMAGE=$1
	local IP=$REGISTRY

	str1=$(curl https://$IP/v2/$IMAGE/tags/list 2>/dev/null)
	if [ "${PIPESTATUS[0]}" = "35" ]; then
		str1=$(curl http://$IP/v2/$IMAGE/tags/list 2>/dev/null)
	fi
	str2=$(echo ${str1##*\"tags\"\:})
	tags=$(echo ${str2//[\[|\]|\,|\"|\}]/ })

	for tag in $tags; do
		echo $tag
	done
}

show_all_tags() {
	local images=$(show_images)
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

tag_and_push_local_images() {
        local IMAGES=$(docker images |grep -v "$REGISTRY" |awk 'NR!=1 {print $1 ":" $2 }')

        for image in $IMAGES; do
                docker tag $image $REGISTRY/$image
                docker push $REGISTRY/$image
                docker rmi  $REGISTRY/$image
        done
}

if [ "$1" = "-h" -o "$1" = "--help"  -o "$1" == "" ]; then
	usage
	exit 0
fi

check_cmd

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
elif [ "$1" = "push" -a "$2" != "" ]; then
	registry=$3
	if [ "$registry" = "" -o "${registry%%:*}" = "127.0.0.1" ]; then
		echo "Error: Push images must set REGISTRY, and REGISTRY is not support 127.0.0.1:*"
		exit 1
	fi
	check_registry $registry
	if [ "$2" = "--all" ]; then
		tag_and_push_local_images
	else
		echo "Arg error!"
		usage
		exit 1
	fi
else
	echo "Arg error!"
	usage
	exit 1
fi
