FROM ubuntu:14.04

RUN apt-get update && \
  apt-get install -y python3-pip libssl-dev libacl1-dev libfuse-dev sshfs && \
  apt-get clean

RUN pip3 install attic

ADD run.sh /bin/run.sh
ADD backup.py /bin/backup.py
RUN chmod 755 /bin/*

RUN mkdir /mnt/backup && mkdir /root/.ssh

ENV SSH_PATH backup@example.com:path/
ENV BACKUP_NAME main.attic
ENV BACKUP_ROOT /b/
ENV BACKUP_PATHS path1 path2
ENV EXCLUDES /proc /dev /tmp /var/tmp /var/log /var/cache /media /lost+found

USER root

CMD ["run.sh"]
