FROM ubuntu:latest

WORKDIR /workapp
COPY . /workapp/
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN pip3 install python-dotenv --break-system-packages
RUN pip3 install requests --break-system-packages
RUN apt-get install -y curl
RUN apt-get install -y unzip
# Run different commands based on the system architecture
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
        # For x86_64 here
    elif [[ "$ARCH" == i*86 ]]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
        # For 32-bit x86 here
    elif [ "$ARCH" = "aarch64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
        # For aarch64 here
    else \
        echo "Unsupported architecture: $ARCH"; \
        # For other unsupported architectures
    fi
RUN unzip awscliv2.zip
RUN ./aws/install
RUN apt-get install less


CMD ["python3", "updater.py"]