FROM rocker/r-ver:4.3.2

LABEL org.opencontainers.image.description="hubValidations in a tin"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="Zhian N. Kamvar <zkamvar@umass.edu>"

# install general OS utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    git

# install OS binaries required by R packages - via rocker-versioned2/scripts/install_tidyverse.sh
RUN apt-get install -y --no-install-recommends \
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libxtst6 \
    libcurl4-openssl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /project

# install required R packages using renv
COPY "renv.lock" "renv.lock"
ENV RENV_PATHS_LIBRARY=renv/library
RUN Rscript -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN Rscript -e "renv::restore()"
COPY "validate.R" "/bin/validate.R"
