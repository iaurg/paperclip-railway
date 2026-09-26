# Thin wrapper over the official image: adds first-boot config + automatic
# bootstrap-CEO invite so a Railway deploy needs no shell access.
ARG PAPERCLIP_IMAGE_TAG=latest
FROM ghcr.io/paperclipai/paperclip:${PAPERCLIP_IMAGE_TAG}

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

# Railway's edge proxy sits in front of the service; public auth mode is the
# only safe choice for an internet-facing URL.
ENV PAPERCLIP_DEPLOYMENT_MODE=authenticated \
    PAPERCLIP_DEPLOYMENT_EXPOSURE=public \
    PORT=3100 \
    TRUST_PROXY=1

# Keep tini as PID 1 (agent runs spawn processes that must be reaped).
ENTRYPOINT ["/usr/bin/tini", "--", "railway-entrypoint.sh"]
CMD ["node", "--import", "./server/node_modules/tsx/dist/loader.mjs", "server/dist/index.js"]
