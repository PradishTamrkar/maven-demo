FROM tomcat:9.0
WORKDIR /usr/local/webapps
ADD **/*.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]