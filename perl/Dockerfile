FROM perl:5.24.0

RUN cpanm Carton

RUN mkdir /app
RUN mkdir /app/logs
WORKDIR /app

COPY cpanfile cpanfile.snapshot /app/
#RUN carton install --deployment
RUN carton install

COPY . /app

CMD carton exec -- plackup -p 80 -s Starlet -E production
