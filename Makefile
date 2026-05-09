all:
	@mkdir -p /home/amsaq/data/wordpress
	@mkdir -p /home/amsaq/data/mariadb
	@docker compose -f srcs/docker-compose.yml up -d --build

down:
	@docker compose -f srcs/docker-compose.yml down

re: fclean all

clean:
	@docker compose -f srcs/docker-compose.yml down --rmi all

fclean: clean
	@docker system prune -af
	@rm -rf /home/amsaq/data/wordpress/*
	@rm -rf /home/amsaq/data/mariadb/*

logs:
	@docker compose -f srcs/docker-compose.yml logs -f

ps:
	@docker compose -f srcs/docker-compose.yml ps

.PHONY: all down re clean fclean logs ps
