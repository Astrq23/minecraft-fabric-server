FROM eclipse-temurin:25-jre

WORKDIR /server
COPY . /server
RUN chmod +x /server/start.sh
EXPOSE 25565
CMD ["/server/start.sh"]