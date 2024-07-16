# alpine-php-8.3.9-swow
## 构建命令
```
docker build -t registry.cn-hongkong.aliyuncs.com/stevennight-test/alpine-php-8.3.9-swow .
```

## 运行命令
```
docker run -d -p 8080:80 --name test registry.cn-hongkong.aliyuncs.com/stevennight-test/alpine-php-8.3.9-swow
```

## 进入容器
```
docker exec -it test sh
```

## 推送仓库
```
docker push registry.cn-hongkong.aliyuncs.com/stevennight-test/alpine-php-8.3.9-swow
```

# alpine-php-8.3.9-swow-dev

## 构建命令
```
docker build -f Dockerfile-dev -t registry.cn-hongkong.aliyuncs.com/stevennight-test/alpine-php-8.3.9-swow:dev-latest .
```

## 运行命令
```
docker run -d -p 8080:80 --name test registry.cn-hongkong.aliyuncs.com/stevennight-test/alpine-php-8.3.9-swow:dev-latest
```

## 进入容器
```
docker exec -it test sh
```

## 推送仓库
```
docker push registry.cn-hongkong.aliyuncs.com/stevennight-test/alpine-php-8.3.9-swow:dev-latest
```