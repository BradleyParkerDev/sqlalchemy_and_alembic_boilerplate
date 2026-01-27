.PHONY: env clean install freeze db-revision db-up db-down

help:
	@echo ""
	@echo "Available make commands:"
	@echo ""
	@echo "  make env      Create a virtual environment"
	@echo "  make clean    Remove build artifacts and caches"
	@echo "  make install  Python dev deps"
	@echo "  make freeze   Export Python deps to requirements.txt"
	@echo "  make db-revision MSG=\"message\"  Create alembic migration"
	@echo "  make db-up    Apply all pending migrations"
	@echo "  make db-down  Revert the last migration"
	@echo ""
	@echo ""

env:
	python -m venv venv

clean:
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	rm -rf logs


install:
	pip install -e .[dev]
	pip freeze > requirements.txt

freeze:
	pip freeze > requirements.txt

# Alembic helpers
db-revision:
	alembic revision --autogenerate -m "$(MSG)"

db-up:
	alembic upgrade head

db-down:
	alembic downgrade -1
