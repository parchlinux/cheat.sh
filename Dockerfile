FROM alpine:3.20

# runtime deps (rarely change → good cache layer)
RUN apk add --update --no-cache \
    git \
    py3-six \
    py3-pygments \
    py3-yaml \
    py3-gevent \
    libstdc++ \
    py3-colorama \
    py3-requests \
    py3-icu \
    py3-redis \
    py3-jinja2 \
    py3-flask \
    bash \
    gawk \
    sed

WORKDIR /app

# copy ONLY requirements first (better caching)
COPY requirements.txt /app/requirements.txt

# build deps + python installs (heavy layer, cached unless requirements change)
RUN apk add --no-cache --virtual build-deps \
        py3-pip \
        g++ \
        python3-dev \
        libffi-dev \
    && pip3 install --break-system-packages --no-cache-dir --upgrade \
        pip \
        setuptools \
        wheel \
    && pip3 install --break-system-packages --no-cache-dir \
        pygments \
        "MarkupSafe<3.0" \
    && pip3 install --break-system-packages --no-cache-dir -r requirements.txt \
    && apk del build-deps

# now copy source (so code changes don't rebuild deps)
COPY . /app

# fetch cheat sheets (only runs if above layers change)
RUN mkdir -p /root/.cheat.sh/log/ \
    && python3 lib/fetch.py fetch-all

EXPOSE 8002

ENTRYPOINT ["python3", "-u", "bin/srv.py"]
CMD [""]
