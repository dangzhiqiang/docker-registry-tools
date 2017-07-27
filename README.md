# docker-registry-tools
docker私有仓库管理工具

## 项目说明
当自己维护私有镜像仓库时，最大的痛点可能就是批量上传本地镜像到指定的私有仓库，当量很多时，操作比较麻烦；在命令行模式下，查看私有仓库提供有哪些镜像也是一个重要问题，同时查看私有镜像仓库中的镜像有哪些版本也是一个痛点；在命令行删除私有仓库上废弃的镜像也是一个需求。

为解决这些问题，本项目提供docker-register工具，该工具可以查看指定仓库中的所有镜像列表，可以查看所有镜像的tag信息，也可以将本地的所有镜像上传至指定的私有docker仓库中，同时也支持删除私有镜像仓库中指定镜像功能。

### 待添加功能

1、push上传指定镜像到私有docker仓库。（已完成）

2、push上传支持模式匹配。（已完成）

3、删除私有仓库中指定镜像。

### 支持平台

在centos7/RHEL7环境测试通过，要求系统安装docker环境，并且docker服务处于正常运行状态。
理论上也支持其他安装docker环境的linux操作系统，但未测试，在其他linux平台使用的用户，可帮忙反馈测试结果。

如果需要通过http方式上传docker镜像，要在docker配置文件中添加如下参数：

    --insecure-registry IP:port

## 用法

1、下载源码

    git clone https://github.com/dangzhiqiang/docker-registry-tools.git
    
    或者直接下载安装包
    
    wget https://github.com/dangzhiqiang/docker-registry-tools/archive/master.zip

2、安装

    cd docker-registry-tools
    sudo ./install.sh

3、使用方法

详见--help信息

    Usage:
        /bin/docker-register list [REGISTRY]                       # list all images from current REGISTRY
        /bin/docker-register show IMAGE [REGISTRY]                 # list all tags form REGISTRY IMAGE
        /bin/docker-register show --all [REGISTRY]                 # list all tags form all images
        /bin/docker-register show --all --grep PATTERN [REGISTRY]  # list all tags form all images which grep by PATTERN
        /bin/docker-register tags DOCKER_IMAGE                     # list all tags form DOCKER_IMAGE, can found by "docker images"(REPOSITORY)
        /bin/docker-register push IMAGE REGISTRY                   # auto tag and push local images to remote registry
        /bin/docker-register push --all REGISTRY                   # auto tag and push all local images to remote registry
        /bin/docker-register push --all --grep PATTERN REGISTRY    # auto tag and push all local images to remote registry which grep by PATTERN
    
        /bin/docker-register -h or --help                          # show this help info
    
        REGISTRY:
            registry default is 127.0.0.1:5000
    
    Note:
        Push images must set REGISTRY, and REGISTRY is not support 127.0.0.1:*

        SOURCE: https://github.com/dangzhiqiang/docker-registry-tools.git
