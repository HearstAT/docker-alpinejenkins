FROM alpine

MAINTAINER Hearst Automation Team "noemail@noemail.com"

# Environment Variables
ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_SHARE /usr/share/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV JENKINS_UC https://updates.jenkins-ci.org
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

RUN apk update
RUN apk add \
bash \
ruby \
git \
zip \
curl \
wget \
openjdk7-jre \
&& rm -rf /var/cache/apk/*

# Add jenkins user
RUN adduser -S jenkins

# Use tini as subreaper in Docker container to adopt zombie processes
RUN curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

ENV JENKINS_VERSION 1.625.1

# could use ADD but this one does not check Last-Modified header 
# see https://github.com/docker/docker/issues/8331
RUN curl -fL http://mirrors.jenkins-ci.org/war-stable/$JENKINS_VERSION/jenkins.war -o $JENKINS_SHARE/jenkins.war

# Install ChefDK
#RUN curl -LO https://www.chef.io/chef/install.sh && bash ./install.sh -P chefdk -p && rm install.sh

# Setup Directories
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
RUN mkdir -p /var/lib/gems

# Copy additional files needed from repo into container
COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
COPY Gemfile $JENKINS_HOME/Gemfile
COPY gemrc $JENKINS_HOME/.gemrc
COPY jenkins.sh /usr/local/bin/jenkins.sh

# Setup plugin update command
COPY plugins.sh /usr/local/bin/plugins

# Volumes
VOLUME /var/lib/jenkins

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

# Gives Jenkins user ownership over all files copied
RUN chown -R jenkins \
"$JENKINS_HOME" \
"$JENKINS_SHARE" \
/var/lib/gems \
/usr/local/bin

RUN chmod -R 755 \
$JENKINS_HOME \
$JENKINS_SHARE \
/var/lib/gems \
/usr/local/bin

## Downgrade user to install the rest
USER jenkins

# Install Bundler
#RUN gem install bundler

# Install Gemfile
#WORKDIR $JENKINS_HOME
#RUN bundle install

# Install a plugins using script above
COPY plugins.txt $JENKINS_SHARE/plugins.txt
#RUN /usr/local/bin/plugins $JENKINS_SHARE/plugins.txt

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
