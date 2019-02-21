#基础镜像使用ubuntu:16.04
FROM 47.52.134.236/basis_images/openresty:v2

MAINTAINER Rancher

######定义配置文件路径######
#nginx配置文件
ENV NGINX_PATH /usr/local/openresty/nginx/conf/
#web配置文件
ENV WEB_PATH /usr/local/openresty/nginx/conf/web/
#redis_lua库文件
ENV REDIS_PATH /usr/local/openresty/lualib/resty/upstream/
#waf_lua模块文件
ENV  WAF_PATH /usr/local/openresty/lualib/resty/upstream/
#证书文件位置
ENV CERT_PATH /usr/local/openresty/nginx/cert.d/
#防御规则路径
#ENV RULE_PATH /usr/local/openresty/nginx/conf/rule-config
######定义配置文件路径 结束######

######修改时区######
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
######修改时区 结束######

# ######复制证书######
# #创建证书文件夹
RUN mkdir -p /usr/local/openresty/nginx/cert.d/
# #复制证书
COPY cert.d/* $CERT_PATH
# ######复制证书 结束######

######复制防御规则######
#创建防御规则文件夹
RUN mkdir -p /usr/local/openresty/nginx/conf/rule-config
#复制规则
COPY conf/rule-config/ /usr/local/openresty/nginx/conf/rule-config

######复制配置文件######
#删除原有的nginx.conf
RUN rm $NGINX_PATH/nginx.conf
#用定制的nginx.conf
COPY conf/nginx.conf $NGINX_PATH
#创建配置文件目录
RUN mkdir -p $WEB_PATH
#将新的conf文件放入指定位置
COPY conf/hc.conf $WEB_PATH
#复制Redis_lua库文件
COPY conf/redis.lua $REDIS_PATH
#复制CC_waf防御模块文件
COPY conf/*.lua $WAF_PATH
######复制配置文件 end######


#暴露端口
EXPOSE 80
EXPOSE 443
EXPOSE 81
#启动NGINX
CMD ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]

