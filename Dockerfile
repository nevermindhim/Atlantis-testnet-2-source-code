FROM golang:stretch AS build-env

WORKDIR /go/src/github.com/defi-ventures/blockx-test-5

RUN apt-get update -y
RUN apt-get install git -y

COPY . .

RUN make build

FROM golang:stretch

RUN apt-get update -y
RUN apt-get install ca-certificates jq -y

WORKDIR /root

COPY --from=build-env /go/src/github.com/defi-ventures/blockx-test-5/build/blockxd /usr/bin/blockxd

EXPOSE 26656 26657 1317 9090

CMD ["blockxd"]
