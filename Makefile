.PHONY: help setup venv cleanup check-kaggle init-kaggle download-spotify

# Colors
GREEN  = \033[0;32m
YELLOW = \033[1;33m
RED    = \033[0;31m
BLUE   = \033[0;34m
NC     = \033[0m

# Targets
VENV_DIR := .venv
PYTHON := ${VENV_DIR}/bin/python
PIP := ${VENV_DIR}/bin/pip

help: ## Show the commands and their descriptions
	@echo "$(BLUE)=== Makefile Commands ===$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "Use 'make <command>' to run a command."
	@echo "Use 'make help' to show the commands and their descriptions."

venv: ## Create a virtual environment if it doesn't exist
	@if [ ! -d "${VENV_DIR}" ]; then \
		echo "${YELLOW}Creating virtual environment...${NC}"; \
		${PYTHON} -m venv ${VENV_DIR}; \
		echo "${GREEN}Virtual environment created successfully!${NC}"; \
	fi

setup: venv ## Install the dependencies, if venv doesn't exist
	@echo "${YELLOW}Installing dependencies...${NC}"
	${PIP} install -r requirements.txt
	@echo "${GREEN}Dependencies installed successfully!${NC}"

check-kaggle: ## Check the Kaggle credentials
	@if [ -z "$$KAGGLE_USERNAME" ] || [ -z "$$KAGGLE_KEY" ]; then \
		echo "$(RED)Error: KAGGLE_USERNAME and KAGGLE_KEY must be set.$(NC)"; \
		echo ""; \
		echo "${YELLOW}Next steps:$(NC)"; \
		echo "  1) Run 'make init-kaggle'"; \
		echo "  2) Edit secrets.sh with your Kaggle credentials"; \
		echo "  3) Run 'source secrets.sh'"; \
		echo "  4) Run your command again"; \
		echo ""; \
		exit 1; \
	fi
	@echo "${GREEN}Kaggle credentials checked successfully!${NC}"

init-kaggle:
	@if [ ! -f "secrets.sh" ]; then \
		echo "$(YELLOW)Creating secrets.sh from template...$(NC)"; \
		cp scripts/secrets.sh.example secrets.sh; \
		echo "$(GREEN)Created secrets.sh. Edit it with your Kaggle username and key.$(NC)"; \
	else \
		echo "$(YELLOW)secrets.sh already exists. Edit it if needed.${NC}"; \
	fi
	@echo ""; 
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1) Open secrets.sh and fill in your Kaggle credentials."
	@echo "  2) Run: 'source secrets.sh'"
	@echo "  3) Run: 'make check-kaggle'"

download-spotify: setup ## Download the Spotify dataset from Kaggle
	@echo "${YELLOW}Downloading Spotify dataset...${NC}"
	${PYTHON} scripts/spotify-download.py
	@echo "${GREEN}Spotify dataset downloaded successfully!${NC}"

cleanup: ## Clean up the project
	@echo "${YELLOW}Cleaning up...${NC}"
	rm -rf ${VENV_DIR}
	rm -f data/raw/*.csv
	rm -f data/raw/*.zip
	rm -f data/raw/*.gz
	rm -f data/raw/*.bz2
	rm -f data/raw/*.tar
	rm -f data/raw/*.tgz
	rm -f data/raw/*.tar.gz
	rm -f data/raw/*.tar.bz2
	rm -f data/raw/*.tar.gz
	rm -f data/processed/*.csv
	rm -f data/processed/*.zip
	rm -f data/processed/*.gz
	rm -f data/processed/*.bz2
	rm -f data/processed/*.tar
	rm -f data/processed/*.tgz
	rm -f data/processed/*.tar.gz
	rm -f data/processed/*.tar.bz2
	rm -f data/processed/*.tar.gz
	rm -f secrets.sh
	@echo "${GREEN}Cleaned up successfully!${NC}"