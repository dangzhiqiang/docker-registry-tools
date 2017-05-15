# docker-registry-tools
docker私有仓库管理工具

## 功能说明
docker-register.sh 可以查看指定仓库中的所有镜像列表，可以查看所有镜像的tag信息，也可以将本地的所有镜像上传至指定的私有docker仓库中。

### 待添加功能
1、push上传指定镜像到私有docker仓库。

2、push上传支持模式匹配。

3、删除私有仓库指定镜像功能。

## 用法
详见--help信息

    ./docker-register.sh --help

    Usage:
      ./docker-register.sh list [REGISTRY]          # list all images from current REGISTRY, default is 127.0.0.1:5000
      ./docker-register.sh show IMAGE [REGISTRY]    # list all tags form IMAGE
      ./docker-register.sh show --all [REGISTRY]    # list all tags form all images
      ./docker-register.sh push --all [REGISTRY]    # auto tag and push all local images to remote REGISTRY registry

      ./docker-register.sh -h or --help             # show this help info

