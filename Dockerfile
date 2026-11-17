FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CI=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    sudo \
    gnupg \
    fd-find \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Force the installer to run without an interactive terminal prompt
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && pi install npm:billion-context \
    && pi install npm:pi-markitdown

CMD [ "pi" ]
