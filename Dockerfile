# Docker image for base R with renv and targets
FROM docker.io/rocker/r-base:4.0.4

RUN set -ex; \
	apt-get -q update; \
	DEBIAN_FRONTEND=noninteractive \
	ACCPET_EULA=y \
		apt-get update && apt-get install -q -y --no-install-recommends \
		libcurl4-openssl-dev \
		libssl-dev \
		libxml2-dev \
		unixodbc-dev \
		msodbcsql17 \
		python3-minimal \
	; \
	rm -rf /var/lib/apt/lists/*;

# The 'docker' user is created by rocker/r-base and is a member of the 'staff'
# group, and is thereby allowed to install stuff to /usr/local.
USER docker

# install renv
RUN Rscript --vanilla --verbose -e \
	"install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# create a working directory for the project within the container
WORKDIR /project

# The cgroup-limits script is taken from
# it is a script for parsing out system limits to the container
RUN curl https://raw.githubusercontent.com/sclorg/s2i-base-container/master/core/root/usr/bin/cgroup-limits -O cgroup-limits

# copy the renv lockfile to ensure package dependencies are installed
COPY renv.lock  .
COPY .Rprofile .

# _R_SHLIB_STRIP_ doesn't actally seem to do anything. And there's no apparant
# way to tell renv to call R CMD INSTALL with the --strip option. So instead
# we'll run strip by hand.
RUN ["/bin/bash", \
	"-c", \
	"set -ex; limit_vars=$(python3 cgroup-limits); declare $limit_vars; MAKEFLAGS=-j${NUMBER_OF_CORES:-1} Rscript -e 'options(renv.consent = TRUE, renv.settings.use.cache = FALSE)' -e 'renv::restore()'; rm -rf ~/.local/share/renv; rm -rf /usr/local/lib/R/site-library/*/{help,doc,include,tinytest}; find /usr/local/lib/R -name '*.so' -exec strip --strip-unneeded {} +"]

# copy the relevant data files
COPY _targets.R .
COPY R R
COPY data data

# this reads the _targets.R file and launches the pipeline
RUN Rscript --vanilla --verbose -e "targets::tar_make()"

