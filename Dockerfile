FROM ubuntu:latest

WORKDIR /workapp
COPY . /workapp/
RUN apt-get update -y && apt-get install -y python3 && apt-get install -y python3-pip && \ 
    pip3 install python-dotenv --break-system-packages && \ 
    pip3 install requests --break-system-packages && \ 
    apt-get install -y curl && apt-get install -y unzip && apt-get install less
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


CMD ["python3", "updater.py"]