COMPOSE = docker-compose.yml

all: up

up: 
	docker compose up -d

clean:
	docker compose down

fclean:
	docker compose down --volumes --remove-orphans
