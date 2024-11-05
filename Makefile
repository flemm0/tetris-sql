# Makefile

.PHONY: setup input game

up_db:
	@if [ $$(docker ps -q -f name=pgdb) ]; then \
		echo "pgdb is already running, skipping up_db"; \
	else \
		docker run -d \
			--name pgdb \
			-p 5432:5432 \
			-e POSTGRES_USER=postgres \
			-e POSTGRES_PASSWORD=postgres \
			-v ./:/home \
			--rm \
			postgres:16; \
		echo "Waiting for Postgres to be ready..."; \
		until docker exec pgdb pg_isready -U postgres; do \
			echo "Waiting for Postgres..."; \
			sleep 1; \
		done; \
		echo "Postgres is ready!"; \
	fi

up_input:
	echo "Bringing up input container"
	docker compose up -d input

install_deps:
	docker exec -it pgdb apt update
	docker exec -it pgdb apt install -y python3-psycopg2

setup:
	$(MAKE) up_db
	$(MAKE) install_deps

input:
	echo "Running init script"
	docker exec -it pgdb python3 /home/input.py

game:
	echo "Executing SQL script in postgres container..."
	docker exec pgdb psql -U postgres -d postgres -f /home/game.sql
