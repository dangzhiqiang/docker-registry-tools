#!/bin/bash

REGISTRY="127.0.0.1:5000"

usage() {
	echo "
Usage:
	$0 list [REGISTRY]                       # list all images from current REGISTRY
	$0 show IMAGE [REGISTRY]                 # list all tags form REGISTRY IMAGE
	$0 show --all [REGISTRY]                 # list all tags form all images
	$0 show --all --grep PATTERN [REGISTRY]  # list all tags form all images which grep by PATTERN
	$0 tags DOCKER_IMAGE                     # list all tags form DOCKER_IMAGE, can found by \"docker images\"(REPOSITORY)
	$0 push IMAGE REGISTRY                   # auto tag and push local images to remote registry
	$0 push --all REGISTRY                   # auto tag and push all local images to remote registry
	$0 push --all --grep PATTERN REGISTRY    # auto tag and push all local images to remote registry which grep by PATTERN

	$0 -h or --help                          # show this help info

	REGISTRY:
		registry default is $REGISTRY

Note:
	Push images must set REGISTRY, and REGISTRY is not support 127.0.0.1:*

	SOURCE: https://github.com/dangzhiqiang/docker-registry-tools.git
"
}

arg_error() {
	echo "Arg error! $@"
	usage
	exit 1
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
	echo $str1 |grep errors |grep UNAUTHORIZED >/dev/null 2>&1
	if [ "$?" = "0" ]; then
		return 1
	fi

	str2=$(echo ${str1##*\"repositories\"\:})
	tags=$(echo ${str2//[\[|\]|\,|\"|\}]/ })

	for tag in $tags; do
		echo $tag
	done
}

check_image() {
	local images=$(show_images)
	for image in $images; do
		if [ "$image" = "$1" ]; then
			i_find=1
		fi
	done
	if [ "$i_find" != "1" ]; then
		if [ "$images" != "" ]; then
			echo "Error: can not find image \"$1\" from catalog"
			exit 1
		else
			echo "Warning: can not find image \"$1\" from catalog, UNAUTHORIZED"
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
	for image in $images; do
		show_tags $image | awk '{print "'"$image:"'" $0}'
	done
}

show_all_tags_grep() {
	local pattern=$1
	local images=$(show_images)
	for image in $images; do
		echo $image | grep $pattern >/dev/null 2>&1
		if [ "$?" == "0" ]; then
			show_tags $image | awk '{print "'"$image:"'" $0}'
		fi
	done
}

set_registry() {
	if [ "$1" != "" ]; then
		REGISTRY=$1
	fi
	curl -m 2 http://$REGISTRY/v2/_catalog >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "Error: REGISTRY $REGISTRY is invalid"
		exit 1
	fi
}

set_push_registry() {
	registry=$1
	if [ "$registry" = "" -o "${registry%%:*}" = "127.0.0.1" ]; then
		echo "Error: Push images must set REGISTRY, and REGISTRY is not support 127.0.0.1:*"
		exit 1
	fi
	set_registry $registry
}

get_local_images() {
	IMAGES=$(docker images |awk 'NR!=1 {print $0}' |grep -v "$REGISTRY" |awk '{print $1 ":" $2 }')
}

get_local_images_by_pattern() {
	IMAGES=$(docker images |awk 'NR!=1 {print $0}' |grep -v "$REGISTRY" |grep "$1" |awk '{print $1 ":" $2 }')
}

del_ip_registry_in_image_str() {
	IP=$(echo $1 | cut -d / -f 1)
	tmp=${IP//[0-9]/}
	if [ "$tmp" == "..." -o "$tmp" = "...:" ]; then
		new_str=$(echo $1 | cut -d / -f 2-)
	else
		new_str=$1
	fi
	echo $new_str
}

push_local_images() {
	if [ "$IMAGES" = "" ]; then
		echo "WARNING: No image was found, do nothing"
		exit 0
	fi

	for image in $IMAGES; do
		new_image=$(del_ip_registry_in_image_str $image)
		echo -e "WILL PUSH: $image \t ==> $REGISTRY/$new_image"
	done
	
	read -p "Is this ok [y/N]: " -i y -e answer
	if [ "$answer" != "y" -a "$answer" != "yes" ]; then
		echo "Exiting on user command"
		exit 0
	fi

	for image in $IMAGES; do
		new_image=$(del_ip_registry_in_image_str $image)
		docker tag $image $REGISTRY/$new_image
		docker push $REGISTRY/$new_image
		docker rmi  $REGISTRY/$new_image
	done
}

check_local_image() {
	get_local_images
	for image in $IMAGES; do
		if [ "$1" = "$image" ]; then
			find_it=true
		fi
	done
	if [ ! $find_it ]; then
		arg_error "\"$1\" is not found"
	else
		IMAGES=$1
	fi
}

if [ "$1" = "-h" -o "$1" = "--help" -o "$1" == "" ]; then
	usage
	exit 0
fi

check_cmd

if [ "$1" = "list" ]; then
	set_registry $2
	show_images
	if [ "$?" != "0" ]; then
		echo "Error: No valid credential was supplied, UNAUTHORIZED"
		exit 1
	fi
	exit 0
fi

if [ "$1" = "show" -a "$2" != "" ]; then
	if [ "$3" == "--grep" ]; then
		if [ "$4" == "" ]; then
			echo "Arg error: lost arg, PATTERN cannot be blank"
			exit 1
		fi
		set_registry $5
		show_all_tags_grep $4
		exit 0
	fi
	set_registry $3
	if [ "$2" = "--all" ]; then
		show_all_tags
	else
		check_image $2
		show_tags $2 | awk '{print "'"$2:"'" $0}'
		exit 0
	fi
elif [ "$1" = "tags" -a "$2" != "" ]; then
	IP=$(echo $2 | cut -d / -f 1)
	IMAGE=$(echo $2 |cut -d / -f 2- | cut -d : -f 1)
	if [ "$IP" != "" -a "$IMAGE" != "" ]; then
		set_registry $IP
		show_tags $IMAGE | awk '{print "'"$IP/$IMAGE:"'" $0}'
	else
		echo "Arg error!"
		exit 1
	fi
elif [ "$1" = "push" -a "$2" != "" ]; then
	if [ "$2" = "--all" ]; then
		if [ "$3" = "--grep" ]; then
			if [ "$4" != "" -a "$5" != "" ]; then
				set_push_registry $5
				get_local_images_by_pattern $4
				push_local_images
			else
				arg_error
			fi
		elif [ "$4" = "" ]; then
			set_push_registry $3
			get_local_images
			push_local_images
		else
			arg_error
		fi
	elif [ "$3" != "" ]; then
		set_push_registry $3
		IMAGES=$2
		check_local_image $2
		push_local_images
	else
		arg_error
	fi
else
	arg_error
fi
