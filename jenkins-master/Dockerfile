FROM jenkins/jenkins:lts-alpine-jdk25

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Djava.awt.headless=true" \
    CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc.yaml

USER root
RUN mkdir -p /var/log/jenkins && chown -R jenkins:jenkins /var/log/jenkins

USER jenkins

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY --chown=jenkins:jenkins casc.yaml /usr/share/jenkins/ref/casc.yaml
COPY --chown=jenkins:jenkins jobs /usr/share/jenkins/ref/jobs
