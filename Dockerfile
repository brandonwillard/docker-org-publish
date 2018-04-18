# VERSION 0.0.1
# AUTHOR: Brandon T. Willard
# DESCRIPTION: Image for org-mode, Python and LaTeX document generation.
# BUILD: docker build --rm -t org-publish .
# SOURCE: https://github.com/brandonwillard/docker-org-publish

FROM ubuntu:17.10

MAINTAINER brandonwillard

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

ENV TINI_VERSION v0.17.0

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV PATH /opt/conda/bin:/root/.cask/bin:$PATH

RUN set -ex \
  && buildDeps=' \
  libkrb5-dev \
  libsasl2-dev \
  libssl-dev \
  libffi-dev \
  build-essential \
  libblas-dev \
  liblapack-dev \
  libpq-dev \
  curl \
  grep \
  sed \
  dpkg \
  wget \
  bzip2 \
  ca-certificates \
  libglib2.0-0 \
  libxext6 \
  libsm6 \
  libxrender1 \
  ' \
  && apt-get update -yqq \
  && apt-get install -yqq --no-install-recommends \
  $buildDeps \
  git \
  ssh \
  make \
  apt-utils \
  rsync \
  locales \
  && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Texlive
RUN set -ex \
  && apt-get install -yqq --no-install-recommends \
  texlive-latex-base \
  texlive-pictures \
  texlive-latex-extra \
  poppler-utils \
  latexmk

# Conda
RUN set -ex && \
  wget --quiet https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh -O ~/anaconda.sh && \
  /bin/bash ~/anaconda.sh -b -p /opt/conda && \
  rm ~/anaconda.sh && \
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
  echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
  echo "conda activate base" >> ~/.bashrc

# Emacs
RUN set -ex \
  && apt-get install -yqq --no-install-recommends \
  emacs25-nox \
  && curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
  # && curl -fsSkL https://raw.github.com/cask/cask/master/go | python

# Tini
RUN set -ex && \
  TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
  curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
  dpkg -i tini.deb && \
  rm tini.deb && \
  apt-get clean

# Cleanup
RUN set -ex \
  && apt-get purge --auto-remove -yqq $buildDeps \
  && apt-get clean \
  && rm -rf \
  /var/lib/apt/lists/* \
  /tmp/* \
  /var/tmp/* \
  /usr/share/man \
  /usr/share/doc \
  /usr/share/doc-base

ENTRYPOINT ["/tini", "--"]
CMD [ "/bin/bash" ]