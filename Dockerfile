FROM python:3.8-buster

RUN apt-get update -y && apt-get install -y --no-install-recommends --allow-downgrades \
    libev-dev=1:4.25-1 \
    wget=1.20.1-1.1 \
    python=2.7.16-1 \
    nginx=1.14.2-2+deb10u1 \
    ca-certificates=20190110 \
    && rm -rf /var/lib/apt/lists/*

# Here we get all python packages.
COPY requirements.txt .
RUN pip install -r requirements.txt

# Set some environment variables. PYTHONUNBUFFERED keeps Python from
# buffering our standard output stream, which means that logs can be
# delivered to the user quickly. PYTHONDONTWRITEBYTECODE keeps Python
# from writing the .pyc files which are unnecessary in this case. We
# also update PATH so that the train and serve programs are found when
# the container is invoked.
ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program/:${PATH}"
ENV ML_PREFIX="/opt/ml/"
ENV ENVIRON="DOCKER"

# Set up the program and config in the image
COPY src /opt/program

WORKDIR /opt/program
RUN chmod +x /opt/program/train

EXPOSE 8080
