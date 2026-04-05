.PHONY: help init validate plan apply destroy output

# Configuration
REGION ?= ap-southeast-1
ENVIRONMENT ?= dev

# Colors
GREEN  = \033[0;32m
YELLOW = \033[1;33m
RED    = \033[0;31m
BLUE   = \033[0;34m
NC     = \033[0m

# Targets
help: ## Show this help message
	@echo "$(BLUE)=== Viral Content Predictor Infrastructure Makefile ===$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "Use 'make <$(YELLOW)target$(NC)>' to run a target."
	@echo "Use 'make help' to show the targets and their descriptions."
	@echo ""
	@echo "$(YELLOW)Targets:$(NC)"
	@echo "  make init 			# Initialize OpenTofu"
	@echo "  make validate 		# Validate OpenTofu configuration"
	@echo "  make plan 			# Show execution plan"
	@echo "  make apply 			# Apply infrastructure changes"
	@echo "  make destroy 			# Destroy all infrastructure (WARNING: Destructive)"
	@echo "  make output 			# Display all OpenTofu outputs"
	@echo "  make upload-spotify-raw 	# Upload the Spotify raw dataset to S3"

init: ## Initialize OpenTofu 
	@echo "${YELLOW}Initializing OpenTofu...${NC}"
	tofu init
	@echo "${GREEN}✓ OpenTofu initialized successfully!${NC}"

validate: ## Validate OpenTofu configuration
	@echo "${YELLOW}Validating OpenTofu configuration...${NC}"
	tofu validate
	@echo "${GREEN}✓ OpenTofu configuration is valid!${NC}"

plan: ## Show execution plan
	@echo "${YELLOW}Creating execution plan...${NC}"
	tofu plan
	@echo "${GREEN}✓ Execution plan complete.${NC}"

apply: ## Apply infrastructure changes
	@echo "${YELLOW}Applying infrastructure changes...${NC}"
	tofu apply
	@echo "${GREEN}✓ Infrastructure changes applied successfully!${NC}"
	@echo "" 
	@echo "$(YELLOW)Important outputs:$(NC)"
	@$(MAKE) output

destroy: ## Destroy all infrastructure (WARNING: Destructive)
	@echo "$(RED)WARNING: This wil destroy all infrastructure and data!$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to cancel, or wait 5 seconds to continue...$(NC)"
	@sleep 5
	@echo "${YELLOW}Destroying all infrastructure...${NC}"
	tofu destroy
	@echo "${GREEN}✓ Infrastructure destroyed successfully!${NC}"

plan-destroy: ## Show execution plan for destroy
	@echo "${YELLOW}Previewing execution plan for destroy...${NC}"
	@echo "$(RED)WARNING: This will show what resources will be destroyed.$(NC)"
	@echo ""
	tofu plan -destroy
	@echo "${GREEN}✓ Execution plan for destroy complete.${NC}"

output: ## Display all OpenTofu outputs
	@tofu output


# ------------------------------------------------------------
# Custom targets
# ------------------------------------------------------------

upload-spotify-raw: ## Upload the Spotify raw dataset to S3
	@echo "${YELLOW} Uploading Spotify raw dataset to S3...${NC}"
	@test -f ../data/raw/spotify_tracks.csv || (echo "$(RED)Error: Spotify raw dataset not found!$(NC)"; exit 1)
	@aws s3 cp ../data/raw/spotify_tracks.csv \
		"s3://$$(tofu output -raw bucket_id)/data/raw/spotify_tracks.csv"
	@echo "${GREEN}Spotify raw dataset uploaded successfully!${NC}"
