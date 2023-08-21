FROM debian:11-slim as build
RUN set -xe \
    && apt-get update \
    && apt-get install --no-install-recommends -y build-essential gcc zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
# libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev
RUN wget --no-check-certificate https://www.python.org/ftp/python/3.10.11/Python-3.10.11.tgz
RUN tar -xf Python-3.10.*.tgz 
RUN rm Python-3.10.11.tgz
RUN cd Python-3.10.* \
    && ./configure --prefix=/usr/local --enable-optimizations --enable-ipv6 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
RUN cd Python-3.10.* \
    && make -j $(nproc)
RUN cd Python-3.10.* \
    && make altinstall
RUN python3.10 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel
# pip-tools
RUN apt clean && rm -rf /var/lib/apt/lists/*

# sudo apt install build-essential  libssl-dev 
# libpython3-dev python3-venv python3-pip python-dev-is-python3

FROM build as build-env
COPY requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check --no-cache-dir -r /requirements.txt

FROM build-env AS build-sec
ARG FASTAPI_TEMP_DIR
RUN mkdir -p /tmp/${FASTAPI_TEMP_DIR}
# RUN adduser --no-create-home --disabled-login --shell /bin/nologin cgc
RUN chown nobody:nogroup -R /tmp/

FROM gcr.io/distroless/python3-debian11:latest as base
COPY --from=build-sec /tmp /tmp
# Copy libraries
COPY --from=build-sec /usr/local/bin/python3.10 /usr/local/bin/python3.10
COPY --from=build-sec /usr/local/lib /usr/local/lib
COPY --from=build-env /venv /venv
# Copy the source code
WORKDIR /usr/app
COPY ./models ./models
COPY ./custom_nodes ./custom_nodes
COPY ./comfy ./comfy
COPY ./comfy_extras ./comfy_extras
COPY ./notebooks ./notebooks
COPY ./input ./input
COPY ./output ./output
COPY ./script_examples ./script_examples
COPY ./web ./web
COPY *.py ./
# Run the application
USER nobody
ENTRYPOINT ["/venv/bin/python3"]
#CMD ["main.py"]
