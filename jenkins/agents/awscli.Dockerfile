FROM robertoasir/base-jenkins-agent

RUN apt update && apt install unzip && \
    wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"  && \
    unzip awscli-exe-linux-x86_64.zip && \
    ./aws/install



EXPOSE 22

