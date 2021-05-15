FROM qaware/zulu-centos-payara-micro:8u162-5.181

COPY build/activemq/activemq-rar-5.15.3.rar /opt/payara/deployments/
COPY build/opentracing/* /opt/payara/libs/
COPY keycloak.json /opt/payara/resources/keycloak.json
COPY post-deploy.asadmin /opt/payara/post-deploy.asadmin

CMD ["--maxHttpThreads", "25", "--addjars", "/opt/payara/libs/", "--noCluster", "--postdeploycommandfile", "/opt/payara/post-deploy.asadmin", "--name", "dashboard-service"]

COPY build/libs/dashboard-service.war /opt/payara/deployments/
