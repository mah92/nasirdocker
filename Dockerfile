# Minimal docker container to build project

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

# gitlab-runner
RUN apt-get update
RUN apt-get install -y --no-install-recommends curl
RUN curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
RUN chmod +x /usr/local/bin/gitlab-runner
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
RUN gitlab-runner start
RUN gitlab-runner register \
  --non-interactive \
  --url "https://hamgit.ir/" \
  --registration-token "GR1348941kqbDiym8dnKHz83hmxf-" \
  --executor "shell" \
  --description "hamravesh-runner-munner-tester" \
  --locked="false"

CMD ["/bin/sh","-c","sudo gitlab-runner start; sudo gitlab-runner verify; while true; do echo Alhamdolellah; sleep 5;done"]
