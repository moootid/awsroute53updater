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
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN apt-get install less


CMD ["python3", "updater.py"]