FROM openjdk:22-jdk-slim-bullseye

RUN apt update -y && apt install -y neovim psmisc procps python3 python3-flask

COPY minecraft-init.py /minecraft-init.py

# ENTRYPOINT [ "/minecraft-init.py" ]