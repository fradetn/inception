# Nom du fichier Docker Compose
COMPOSE_FILE=srcs/docker-compose.yml

# Commande par défaut: lance Docker Compose
all: up

# Démarre les conteneurs en arrière-plan
up:
	docker-compose -f $(COMPOSE_FILE) up -d

# Arrête les conteneurs
down:
	docker-compose -f $(COMPOSE_FILE) down

# Redémarre les conteneurs
restart: down up

# Affiche les logs
logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

# Nettoie les volumes et les réseaux associés
clean: down
	docker-compose -f $(COMPOSE_FILE) down --volumes --remove-orphans --rmi all

fclean: clean
	docker system prune -af

.PHONY: all up down restart logs clean fclean