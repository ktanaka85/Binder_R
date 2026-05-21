FROM rocker/binder:latest

# システムパッケージのインストール（apt.txt の内容を含む）
USER root
RUN apt-get update && apt-get install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    libharfbuzz-dev \
    libfribidi-dev \
    libudunits2-dev \
    default-jre \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g \
    zlib1g-dev \
    libv8-dev \
    libcurl4-openssl-dev \
    libmagick++-dev \
    libicu-dev \
    libpoppler-cpp-dev \
    libgmp-dev \
    librsvg2-dev \
    libgdal-dev \
    libsqlite3-dev \
    libgeos-dev \
    libproj-dev \
    libxml2-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Quartoのインストール（root で実行）
RUN curl -LO https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.37/quarto-1.9.37-linux-amd64.deb \
    && dpkg -i quarto-1.9.37-linux-amd64.deb \
    && rm quarto-1.9.37-linux-amd64.deb

USER ${NB_USER}

# リポジトリのファイルをコピー
COPY --chown=${NB_USER}:${NB_USER} . /home/${NB_USER}/

# Rパッケージのインストール
RUN R -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest')); \
    install.packages(c( \
        'tidyverse', 'ragg', 'xlsx', 'readxl', 'haven', 'remotes', 'devtools', 'pacman', \
        'xgboost', 'arm', 'patchwork', 'zoo', 'ggstats', 'S7', 'rngtools', \
        'sandwich', 'GGally', 'doRNG', 'doParallel', 'mvtnorm', 'lfe', 'mitools', \
        'lmtest', 'AER', 'googlePolylines', \
        'naniar', 'fastDummies', \
        'rmarkdown', 'quarto', 'formatR', 'summarytools', 'gtExtras', 'kableExtra', \
        'bookdown', 'xaringan', 'tinytex', \
        'rstan', 'estimatr', 'margins', 'prediction', 'modelsummary', 'marginaleffects', \
        'gmp', 'ggdag', 'dagitty', \
        'ggpubr', 'gghighlight', 'gt', 'ggExtra', 'ggridges', 'ggalluvial', \
        'treemapify', 'ggbump', 'dendextend', 'ggdendro', 'ggmosaic', 'ghibli', \
        'sf', 'rnaturalearth', 'rnaturalearthdata', 'raster', 'terra', 'leaflet', \
        'titanic', \
        'rdrobust', 'gsynth', 'interplot', 'jpmesh' \
    ))"

# GitHubパッケージのインストール
RUN R -e "remotes::install_github('uribo/jpndistrict', upgrade = 'never'); \
          remotes::install_github('ropensci/rnaturalearthhires', upgrade = 'never')"

# rddパッケージのインストール（ローカルtarball）
RUN R -e "install.packages('/home/${NB_USER}/rdd_0.57.tar.gz', type = 'source', repos = NULL)"

# RStudio設定の移植
RUN mkdir -p /home/${NB_USER}/.config/rstudio \
    && cp /home/${NB_USER}/rstudio-prefs.json /home/${NB_USER}/.config/rstudio/rstudio-prefs.json

# r-otel（GitHub版）のインストール
RUN R -e "remotes::install_github('equinor/otel-r', upgrade = 'never')"

# TinyTeXのインストール（PDF出力用）
RUN quarto install tinytex --no-prompt

# jupyterlab-quartoのインストール
RUN pip install jupyterlab-quarto==0.1.45

CMD ["/init"]
