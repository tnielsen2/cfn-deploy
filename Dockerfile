FROM alpine:3

RUN apk --no-cache add bash python3 jq
RUN pip3 --no-cache-dir install awscli

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
