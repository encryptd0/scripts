#!/bin/bash

# Fedora Data Science & Data Analysis Setup Script (with checks)
# Run this script as root or with sudo

set -e

#echo "Checking environment..."
#os_name=$(hostnamectl | grep "Operating System" | cut -d':' -f2 | awk '{print $1}')

#pkg_mngr=""

#if [[ "$os_name" == "Ubuntu" ]]; then
#    pkg_mngr=apt
#elif [[ "$os_name" == "Fedora" ]]; then
#    pkg_mngr=dnf
#else
#    echo "Other Linux distro: $os_name"
#fi

echo "Updating system..."
sudo dnf update -y

echo "Installing git..."
sudo dnf install -y git

echo "Installing core development tools..."
if ! dnf group list installed | grep -q "Development Tools"; then
    sudo dnf groupinstall -y "Development Tools"
fi
sudo dnf install -y git wget curl make cmake gcc-c++ unzip bzip2 htop tmux || true

echo "Installing Python and tools..."
if ! command -v python3 &>/dev/null; then
    sudo dnf install -y python3 python3-pip python3-virtualenv
fi
if ! command -v spyder &>/dev/null; then
    sudo dnf install -y spyder
fi
if ! command -v jupyter-notebook &>/dev/null; then
    sudo dnf install -y jupyter-notebook
fi

# Upgrade pip
python3 -m pip install --upgrade pip

echo "Installing Python data science & analysis libraries via pip..."
PY_LIBS="numpy pandas matplotlib seaborn scikit-learn scipy jupyterlab notebook statsmodels plotly \
tensorflow torch torchvision torchaudio xgboost dask[complete] pyspark openpyxl networkx nltk spacy \
sqlalchemy psycopg2-binary mysqlclient"

for lib in $PY_LIBS; do
    if ! python3 -c "import $lib" &>/dev/null; then
        python3 -m pip install $lib
    fi
done

# Download spaCy model if not installed
if ! python3 -c "import spacy; spacy.load('en_core_web_sm')" &>/dev/null; then
    python3 -m spacy download en_core_web_sm
fi

echo "Installing R and RStudio..."
if ! command -v R &>/dev/null; then
    sudo dnf install -y R
fi
if ! command -v rstudio &>/dev/null; then
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://download1.rstudio.org/desktop/centos8/x86_64/rstudio.repo
    sudo dnf install -y rstudio
fi

echo "Installing VS Code..."
if ! command -v code &>/dev/null; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf install -y code
fi

echo "Installing editors..."
for editor in vim nano bat; do
    if ! command -v $editor &>/dev/null; then
        sudo dnf install -y $editor
    fi
done

echo "Installing Docker..."
if ! command -v docker &>/dev/null; then
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
fi

echo "Installing Miniconda..."
if [ ! -d "$HOME/miniconda" ]; then
    cd /tmp
    curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
    export PATH="$HOME/miniconda/bin:$PATH"
    echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc
fi

echo "Creating conda environment: datasci"
if ! $HOME/miniconda/bin/conda env list | grep -q "datasci"; then
    $HOME/miniconda/bin/conda create -y -n datasci python=3.11 \
        numpy pandas matplotlib seaborn scikit-learn scipy \
        jupyterlab notebook spyder statsmodels plotly \
        tensorflow pytorch torchvision torchaudio cpuonly -c pytorch \
        xgboost dask pyspark \
        openpyxl networkx nltk spacy sqlalchemy psycopg2 mysqlclient r-essentials r-base
    # Download English model for spaCy in conda env
    $HOME/miniconda/bin/conda run -n datasci python -m spacy download en_core_web_sm
fi

echo "Cleaning up..."
sudo dnf clean all

echo "Setup complete!"
echo "To activate your environment, run:"
echo "   conda activate datasci"
echo "Log out and back in (or run 'newgrp docker') to use Docker without sudo."
echo "Run 'conda init bash' if you want conda to auto-activate in your shell."
