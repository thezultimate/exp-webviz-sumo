FROM ubuntu:focal

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git python3-pip

RUN groupadd -g 1001 radix-non-root-group && useradd --create-home -u 1001 -g radix-non-root-group -s /bin/sh radix-non-root-user
WORKDIR /home/radix-non-root-user

COPY . .

EXPOSE 5000

ARG EXP_WEBVIZ_SUMO_PRIVATE_KEY
# ARG SUMO_WRAPPER_PRIVATE_KEY
# ARG SUMO_VIZ_PROTO_PRIVATE_KEY

RUN mkdir ~/.ssh
RUN touch ~/.ssh/id_rsa
RUN echo "${EXP_WEBVIZ_SUMO_PRIVATE_KEY}" | base64 --decode > ~/.ssh/id_rsa
RUN chmod 600 ~/.ssh/id_rsa

# RUN mkdir ~/.ssh
# RUN touch ~/.ssh/id_rsa
# RUN echo "${SUMO_WRAPPER_PRIVATE_KEY}" | base64 --decode > ~/.ssh/id_rsa
# RUN chmod 600 ~/.ssh/id_rsa

# RUN touch ~/.ssh/id_rsa_sumo_viz_proto
# RUN echo "${SUMO_VIZ_PROTO_PRIVATE_KEY}" | base64 --decode > ~/.ssh/id_rsa_sumo_viz_proto
# RUN chmod 600 ~/.ssh/id_rsa_sumo_viz_proto

RUN touch ~/.ssh/known_hosts
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install webviz-config
RUN python3 -m pip install webviz-config-equinor
# RUN python3 -m pip install webviz-subsurface
# RUN python3 -m pip install xtgeo
RUN python3 -m pip install gunicorn
# RUN python3 -m pip install libecl
# RUN python3 -m pip install opm

RUN export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa" && \
    echo $GIT_SSH_COMMAND && \
    python3 -m pip install git+ssh://git@github.com/thezultimate/exp-webviz-sumo.git@oauth2

# RUN export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa" && \
#     echo $GIT_SSH_COMMAND && \
#     python3 -m pip install git+ssh://git@github.com/equinor/sumo-wrapper-python.git@master

# RUN export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa_sumo_viz_proto" && \
#     echo $GIT_SSH_COMMAND && \
#     python3 -m pip install git+ssh://git@github.com/equinor/sumo-viz-proto.git@aggregation-service

RUN webviz build config/simple_config.yaml --theme equinor --portable app

USER 1001

ENV PREFERRED_URL_SCHEME https
CMD gunicorn \
    --access-logfile "-" \
    --bind 0.0.0.0:5000 \
    --keep-alive 120 \        
    --max-requests 40 \
    --preload \
    --workers 2 \
    --worker-class gthread \
    --worker-tmp-dir /dev/shm \        
    --threads 2 \
    --timeout 100000 \
    "app.webviz_app:server"