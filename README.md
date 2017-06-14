# docker-registry-tools
docker私有仓库管理工具

## 功能说明
docker-register.sh 可以查看指定仓库中的所有镜像列表，可以查看所有镜像的tag信息，也可以将本地的所有镜像上传至指定的私有docker仓库中。

### 待添加功能
1、push上传指定镜像到私有docker仓库。

2、push上传支持模式匹配。

3、删除私有仓库指定镜像功能。

## 用法

1、下载源码

    git clone https://github.com/dangzhiqiang/docker-registry-tools.git
    
    或者直接下载安装包
    
    wget https://github.com/dangzhiqiang/docker-registry-tools/archive/master.zip

2、安装

    cd docker-registry-tools
    ./install.sh

3、使用方法

详见--help信息

    Usage:
        /bin/docker-register list [REGISTRY]                       # list all images from current REGISTRY, default is 127.0.0.1:5000
        /bin/docker-register show IMAGE [REGISTRY]                 # list all tags form IMAGE, registry default is 127.0.0.1:5000
        /bin/docker-register show --all [REGISTRY]                 # list all tags form all images, registry default is 127.0.0.1:5000
        /bin/docker-register show --all --grep PATTERN [REGISTRY]  # list all tags form all images, registry default is 127.0.0.1:5000
        /bin/docker-register tags DOCKER_IMAGE                     # list all tags form DOCKER_IMAGE, DOCKER_IMAGE from docker images etc.
        /bin/docker-register push --all REGISTRY                   # auto tag and push all local images to remote registry

        /bin/docker-register -h or --help                          # show this help info

    Note:
        Push images must set REGISTRY, and REGISTRY is not support 127.0.0.1:*

