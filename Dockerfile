FROM golang:latest AS builder

RUN go install github.com/gohugoio/hugo@latest
RUN git clone https://github.com/chrsm/dubya.git /git && \
	cd /git && \
	hugo --minify

FROM nginx:latest

COPY --from=builder /go/bin/hugo /usr/bin/hugo
COPY --from=builder /git/public /usr/share/nginx/html
COPY nginx/default.template /etc/nginx/conf.d/default.template

CMD envsubst < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf && \
	exec nginx -g 'daemon off;'
