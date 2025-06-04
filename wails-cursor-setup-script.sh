#!/bin/bash

# Wails + Cursor Setup Script
# Run this in the root of your Wails project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}================================${NC}\n"
}

# Check if we're in a Wails project
check_wails_project() {
    print_header "Checking Wails Project"
    
    if [[ ! -f "wails.json" ]]; then
        print_error "wails.json not found. Are you in a Wails project root?"
        exit 1
    fi
    
    if [[ ! -f "go.mod" ]]; then
        print_error "go.mod not found. This doesn't appear to be a Go project."
        exit 1
    fi
    
    if [[ ! -d "frontend" ]]; then
        print_error "frontend directory not found. This doesn't appear to be a Wails project."
        exit 1
    fi
    
    print_success "Valid Wails project detected"
}

# Create directory structure
create_directories() {
    print_header "Creating Directory Structure"
    
    directories=(
        ".cursor/rules"
        "tests/unit"
        "tests/integration" 
        "tests/mocks"
        "tests/fixtures"
        "internal/model"
        "internal/service"
        "internal/repository"
        "internal/config"
        "internal/connection"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_status "Created directory: $dir"
        else
            print_status "Directory already exists: $dir"
        fi
    done
    
    print_success "Directory structure created"
}

# Create .cursorignore file
create_cursorignore() {
    print_header "Creating .cursorignore"
    
    cat > .cursorignore << 'EOF'
# Dependencies
node_modules/
.pnpm-store/
vendor/
go.sum

# Build outputs
dist/
build/
.next/
target/
frontend/dist/
frontend/node_modules/

# Generated files
*.generated.*
__pycache__/
.cache/
wailsjs/go/
wailsjs/runtime/
tests/mocks/

# Database files
*.db
*.db-shm
*.db-wal

# Test artifacts
coverage.out
*.test
*.prof

# macOS specific
.DS_Store
._*
.Spotlight-V100
.fseventsd
.Trashes

# IDE
.vscode/settings.json
.idea/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Temporary files
*.tmp
*.temp
.cache/
EOF

    print_success ".cursorignore created"
}

# Create Cursor rules files
create_cursor_rules() {
    print_header "Creating Cursor Rules"
    
    # Core Architecture Rules
    cat > .cursor/rules/00-core-architecture.mdc << 'EOF'
---
description: Core Wails Architecture and Clean Code Principles
globs: ["*.go", "**/*.go", "main.go", "wails.json"]
alwaysApply: true
---

# Wails Clean Architecture Standards

## Layer Responsibilities
- **app/**: Wails binding layer - thin controllers that delegate to services
- **internal/service/**: Business logic and orchestration
- **internal/repository/**: Data access and persistence
- **internal/model/**: Domain models and data structures
- **internal/config/**: Configuration management
- **internal/connection/**: Database and external connections

## Dependency Flow
```
main.go → app/ → service/ → repository/ → database
                ↓
              model/ (shared across all layers)
```

## Core Principles
- Dependency injection through constructor functions
- Interface-driven design for testability
- Single responsibility principle
- Error wrapping with context
- Immutable models where possible

## App Layer Pattern (Wails Bindings)
```go
// app/example_app.go
package app

func (a *App) ExampleApp_Create(data model.Example) error {
    return a.exampleSvc.Create(data)
}

func (a *App) ExampleApp_List() ([]model.Example, error) {
    return a.exampleSvc.GetAll()
}

func (a *App) ExampleApp_Update(data model.Example) error {
    return a.exampleSvc.Update(data)
}

func (a *App) ExampleApp_Delete(id string) error {
    return a.exampleSvc.Delete(id)
}
```

## Service Interface Pattern
```go
// internal/service/example_service.go
type IExampleService interface {
    Create(data model.Example) error
    GetAll() ([]model.Example, error)
    Update(data model.Example) error
    Delete(id string) error
}

type ExampleService struct {
    repo repository.IExampleRepository
}

func NewExampleService(repo repository.IExampleRepository) IExampleService {
    return &ExampleService{repo: repo}
}
```

## Repository Interface Pattern
```go
// internal/repository/example_repository.go
type IExampleRepository interface {
    Save(example model.Example) (string, error)
    FindAll() ([]model.Example, error)
    FindByID(id string) (model.Example, error)
    Update(example model.Example) error
    Delete(id string) error
}
```

@app/
@internal/service/
@internal/repository/
@internal/model/
EOF

    # Go Backend Rules
    cat > .cursor/rules/01-go-backend.mdc << 'EOF'
---
description: Go Backend Development Standards for Wails
globs: ["**/*.go", "go.mod", "go.sum"]
alwaysApply: true
---

# Go Backend Standards

## Package Organization
- Use descriptive package names (not generic like `utils`)
- Keep packages focused on single responsibilities
- Avoid circular dependencies
- Use internal/ for private packages

## Error Handling
```go
// Always wrap errors with context
func (s *ExampleService) Create(data model.Example) error {
    if err := s.validateData(data); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    
    if err := s.repo.Save(data); err != nil {
        return fmt.Errorf("failed to save example: %w", err)
    }
    
    return nil
}

// Use custom error types for business logic
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation error on field %s: %s", e.Field, e.Message)
}
```

## Constructor Patterns
```go
// Always return interfaces from constructors
func NewExampleService(repo repository.IExampleRepository) IExampleService {
    return &ExampleService{
        repo: repo,
    }
}
```

## Context Usage
```go
// Pass context through service calls
func (s *ExampleService) ProcessWithContext(ctx context.Context, data model.Example) error {
    // Use context for cancellation and timeouts
    select {
    case <-ctx.Done():
        return ctx.Err()
    default:
    }
    
    // Pass context to repository layer
    return s.repo.SaveWithContext(ctx, data)
}
```

## Wails Runtime Integration
```go
import "github.com/wailsapp/wails/v2/pkg/runtime"

// Use runtime methods with stored context
func (a *App) ShowDialog(message string) {
    runtime.MessageDialog(a.ctx, runtime.MessageDialogOptions{
        Type:    runtime.InfoDialog,
        Title:   "Info",
        Message: message,
    })
}
```

@internal/service/
@internal/repository/
@internal/config/
EOF

    # TDD Rules
    cat > .cursor/rules/02-testing-tdd.mdc << 'EOF'
---
description: Test-Driven Development Standards for Go Backend
globs: ["**/*_test.go", "tests/**/*.go", "mocks/**/*.go"]
alwaysApply: true
---

# TDD Standards for Wails Backend

## Test Structure
```
tests/
├── unit/           # Unit tests for individual functions
├── integration/    # Integration tests with database
├── mocks/          # Generated mocks
└── fixtures/       # Test data and helpers
```

## Unit Test Pattern
```go
// internal/service/example_service_test.go
package service_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    
    "your-project/internal/model"
    "your-project/internal/service"
    "your-project/tests/mocks"
)

func TestExampleService_Create_Success(t *testing.T) {
    // Arrange
    mockRepo := mocks.NewIExampleRepository(t)
    svc := service.NewExampleService(mockRepo)
    
    input := model.Example{
        Title: "Test Example",
        Data:  "test data",
    }
    
    mockRepo.On("Save", mock.MatchedBy(func(e model.Example) bool {
        return e.Title == "Test Example"
    })).Return("123", nil)
    
    // Act
    err := svc.Create(input)
    
    // Assert
    assert.NoError(t, err)
    mockRepo.AssertExpectations(t)
}
```

## Mock Generation
```go
//go:generate mockery --name=IExampleRepository --output=../tests/mocks --outpkg=mocks
type IExampleRepository interface {
    Save(example model.Example) (string, error)
    FindAll() ([]model.Example, error)
}
```

## Integration Test Pattern
```go
// tests/integration/example_integration_test.go
package integration

func TestExampleService_Integration(t *testing.T) {
    // Setup test database
    db := setupTestDB(t)
    defer cleanupTestDB(t, db)
    
    // Initialize real dependencies
    repo := repository.NewExampleRepository(db)
    svc := service.NewExampleService(repo)
    
    // Test with real database
    input := model.Example{
        Title: "Integration Test",
        Data:  "test data",
    }
    
    err := svc.Create(input)
    assert.NoError(t, err)
    
    // Verify persistence
    results, err := svc.GetAll()
    assert.NoError(t, err)
    assert.Len(t, results, 1)
    assert.Equal(t, "Integration Test", results[0].Title)
}
```

@tests/
@mocks/
@**/*_test.go
EOF

    # SQLite Database Rules
    cat > .cursor/rules/03-database-sqlite.mdc << 'EOF'
---
description: SQLite Database Patterns and Best Practices
globs: ["internal/connection/**/*.go", "internal/repository/**/*.go", "migrations/**"]
alwaysApply: true
---

# SQLite Database Standards

## Connection Management
```go
// internal/connection/sqlite.go
package connection

import (
    "database/sql"
    "path/filepath"
    "os"
    
    _ "github.com/mattn/go-sqlite3"
)

var DB *sql.DB

func InitDatabase() error {
    homeDir, err := os.UserHomeDir()
    if err != nil {
        return fmt.Errorf("failed to get home directory: %w", err)
    }
    
    dbDir := filepath.Join(homeDir, "NAS", "sqlite", "yourapp")
    if err := os.MkdirAll(dbDir, 0755); err != nil {
        return fmt.Errorf("failed to create db directory: %w", err)
    }
    
    dbPath := filepath.Join(dbDir, "yourapp.db")
    db, err := sql.Open("sqlite3", dbPath+"?_foreign_keys=on&_journal_mode=WAL")
    if err != nil {
        return fmt.Errorf("failed to open database: %w", err)
    }
    
    if err := db.Ping(); err != nil {
        return fmt.Errorf("failed to ping database: %w", err)
    }
    
    // Configure connection pool
    db.SetMaxOpenConns(1)
    db.SetMaxIdleConns(1)
    
    DB = db
    return createTables()
}
```

## Repository Pattern with Transactions
```go
// internal/repository/example_repository.go
type ExampleRepository struct {
    db *sql.DB
}

func NewExampleRepository(db *sql.DB) IExampleRepository {
    return &ExampleRepository{db: db}
}

func (r *ExampleRepository) Save(example model.Example) (string, error) {
    query := `INSERT INTO examples (title, data) VALUES (?, ?)`
    result, err := r.db.Exec(query, example.Title, example.Data)
    if err != nil {
        return "", fmt.Errorf("failed to insert example: %w", err)
    }
    
    id, err := result.LastInsertId()
    if err != nil {
        return "", fmt.Errorf("failed to get last insert id: %w", err)
    }
    
    return fmt.Sprintf("%d", id), nil
}
```

## Migration System
```go
func createTables() error {
    migrations := []string{
        `CREATE TABLE IF NOT EXISTS examples (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            data TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )`,
        `CREATE INDEX IF NOT EXISTS idx_examples_title ON examples(title)`,
    }
    
    for _, migration := range migrations {
        if _, err := DB.Exec(migration); err != nil {
            return fmt.Errorf("failed to run migration: %w", err)
        }
    }
    
    return nil
}
```

@internal/connection/
@internal/repository/
@migrations/
EOF

    # Service Layer Rules
    cat > .cursor/rules/04-service-layer.mdc << 'EOF'
---
description: Service Layer Architecture and Business Logic Patterns
globs: ["internal/service/**/*.go"]
alwaysApply: true
---

# Service Layer Standards

## Service Interface Design
```go
// internal/service/interfaces.go
type IExampleService interface {
    // CRUD operations
    Create(example model.Example) error
    GetByID(id string) (model.Example, error)
    GetAll() ([]model.Example, error)
    Update(example model.Example) error
    Delete(id string) error
    
    // Business operations
    ProcessExample(id string) error
    ValidateExample(example model.Example) error
}
```

## Service Implementation Pattern
```go
// internal/service/example_service.go
type ExampleService struct {
    repo   repository.IExampleRepository
    config *config.Config
    logger *log.Logger
}

func NewExampleService(repo repository.IExampleRepository) IExampleService {
    return &ExampleService{
        repo:   repo,
        logger: log.New(os.Stdout, "[ExampleService] ", log.LstdFlags),
    }
}

func (s *ExampleService) Create(example model.Example) error {
    // 1. Validation
    if err := s.validateExample(example); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    
    // 2. Business logic
    example.CreatedAt = time.Now()
    
    // 3. Persistence
    id, err := s.repo.Save(example)
    if err != nil {
        return fmt.Errorf("failed to save example: %w", err)
    }
    
    s.logger.Printf("Created example with ID: %s", id)
    return nil
}
```

## Error Handling Strategy
```go
// Custom business errors
type BusinessError struct {
    Code    string
    Message string
    Field   string
}

func (e BusinessError) Error() string {
    return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

// Error factory functions
func NewValidationError(field, message string) error {
    return BusinessError{
        Code:    "VALIDATION_ERROR",
        Message: message,
        Field:   field,
    }
}
```

@internal/service/
@internal/model/
EOF

    # Sub-App Addition Rules
    cat > .cursor/rules/05-sub-apps.mdc << 'EOF'
---
description: Pattern for Adding New Sub-Applications to Wails Project
globs: ["app/*_app.go", "internal/service/*", "internal/repository/*"]
alwaysApply: true
---

# Sub-App Addition Pattern

## Checklist for New Sub-App
1. Create domain model in `internal/model/`
2. Create repository interface and implementation
3. Create service interface and implementation  
4. Create Wails app binding layer
5. Add to main app dependency injection
6. Create tests for all layers
7. Add database migration if needed

## Template: Wails App Binding
```go
// app/task_app.go
package app

import "your-project/internal/model"

// TaskApp_Create creates a new task
func (a *App) TaskApp_Create(task model.Task) error {
    return a.taskSvc.CreateTask(task)
}

// TaskApp_List returns all tasks
func (a *App) TaskApp_List() ([]model.Task, error) {
    return a.taskSvc.GetAllTasks()
}

// TaskApp_GetByID returns a task by ID
func (a *App) TaskApp_GetByID(id string) (model.Task, error) {
    return a.taskSvc.GetTaskByID(id)
}

// TaskApp_Update updates an existing task
func (a *App) TaskApp_Update(task model.Task) error {
    return a.taskSvc.UpdateTask(task)
}

// TaskApp_Delete deletes a task by ID
func (a *App) TaskApp_Delete(id string) error {
    return a.taskSvc.DeleteTask(id)
}
```

## Naming Convention
- App methods: `{SubAppName}App_{Action}`
- Service interfaces: `I{SubAppName}Service`
- Repository interfaces: `I{SubAppName}Repository`
- Models: Clear, descriptive names in `model` package

@app/
@internal/service/
@internal/repository/
@internal/model/
EOF

    # Mac Development Rules
    cat > .cursor/rules/06-mac-development.mdc << 'EOF'
---
description: macOS-specific Development Patterns for Wails Applications
globs: ["*.go", "frontend/**/*", "wails.json"]
alwaysApply: true
---

# macOS Development Standards for Wails

## Mac-Specific Features
- Implement native menu bar integration
- Support dark/light mode switching
- Use macOS file dialogs and notifications
- Handle window management properly

## Native Menu Integration
```go
import "github.com/wailsapp/wails/v2/pkg/menu"

func (a *App) createMenu() *menu.Menu {
    appMenu := menu.NewMenu()
    
    fileMenu := appMenu.AddSubmenu("File")
    fileMenu.AddText("New", keys.CmdOrCtrl("n"), func(ctx context.Context) {
        // Handle new file
    })
    fileMenu.AddSeparator()
    fileMenu.AddText("Quit", keys.CmdOrCtrl("q"), func(ctx context.Context) {
        runtime.Quit(ctx)
    })
    
    return appMenu
}
```

## macOS File Paths
```go
func (a *App) getAppDataPath() (string, error) {
    homeDir, err := os.UserHomeDir()
    if err != nil {
        return "", err
    }
    
    // Use Application Support directory on macOS
    appSupportDir := filepath.Join(homeDir, "Library", "Application Support", "YourAppName")
    err = os.MkdirAll(appSupportDir, 0755)
    return appSupportDir, err
}
```

## File Dialog Integration
```go
func (a *App) OpenFileDialog() (string, error) {
    return runtime.OpenFileDialog(a.ctx, runtime.OpenDialogOptions{
        Title: "Select File",
        Filters: []runtime.FileFilter{
            {DisplayName: "Text Files", Pattern: "*.txt"},
            {DisplayName: "All Files", Pattern: "*.*"},
        },
    })
}
```

@build/
@icons/
@wails.json
EOF

    print_success "Cursor rules created"
}

# Create VSCode/Cursor settings
create_vscode_settings() {
    print_header "Creating VSCode/Cursor Settings"
    
    mkdir -p .vscode
    
    cat > .vscode/settings.json << 'EOF'
{
  "go.testFlags": ["-v", "-race"],
  "go.coverOnSave": true,
  "go.coverOnSingleTest": true,
  "go.testOnSave": false,
  "go.buildOnSave": "off",
  "go.lintOnSave": "package",
  "go.formatTool": "gofmt",
  "go.useLanguageServer": true,
  "go.toolsManagement.autoUpdate": true,
  "go.generateTestsFlags": ["-template", "testify"],
  "files.watcherExclude": {
    "**/.DS_Store": true,
    "**/._*": true,
    "**/node_modules/**": true,
    "**/.git/**": true,
    "**/build/**": true,
    "**/dist/**": true,
    "**/wailsjs/**": true,
    "**/*.db": true,
    "**/*.db-shm": true,
    "**/*.db-wal": true
  },
  "files.exclude": {
    "**/wailsjs/go": true,
    "**/wailsjs/runtime": true
  },
  "cursor.ai.shareContext": "workspace-only",
  "cursor.ai.excludePatterns": [
    "**/.env*",
    "**/secrets/**",
    "**/*.key",
    "**/private/**",
    "**/.aws/**",
    "**/.ssh/**",
    "**/*.db",
    "**/node_modules/**"
  ],
  "cursor.ai.anonymizeCode": false,
  "cursor.ai.privacyMode": false
}
EOF

    print_success "VSCode/Cursor settings created"
}

# Install Go tools and dependencies
install_go_tools() {
    print_header "Installing Go Tools and Dependencies"
    
    # Check if Go is installed
    if ! command -v go &> /dev/null; then
        print_error "Go is not installed. Please install Go first."
        exit 1
    fi
    
    print_status "Go version: $(go version)"
    
    # Install testing tools
    print_status "Installing mockery for mock generation..."
    go install github.com/vektra/mockery/v2@latest
    
    print_status "Installing testify for testing..."
    go get github.com/stretchr/testify/assert
    go get github.com/stretchr/testify/mock
    go get github.com/stretchr/testify/require
    
    # Add common dependencies if not present
    if ! grep -q "github.com/mattn/go-sqlite3" go.mod; then
        print_status "Adding SQLite driver..."
        go get github.com/mattn/go-sqlite3
    fi
    
    if ! grep -q "github.com/wailsapp/wails/v2" go.mod; then
        print_warning "Wails v2 not found in go.mod. This might not be a Wails project."
    fi
    
    # Tidy up dependencies
    go mod tidy
    
    print_success "Go tools and dependencies installed"
}

# Create sample test files
create_sample_tests() {
    print_header "Creating Sample Test Files"
    
    # Create a sample service test if internal/service exists
    if [[ -d "internal/service" ]]; then
        cat > tests/unit/sample_service_test.go << 'EOF'
package unit

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestSampleService(t *testing.T) {
    // This is a sample test file to verify the testing setup
    assert.True(t, true, "Sample test should pass")
}
EOF
        print_status "Created sample unit test"
    fi
    
    # Create a sample integration test
    cat > tests/integration/sample_integration_test.go << 'EOF'
package integration

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestSampleIntegration(t *testing.T) {
    // This is a sample integration test
    assert.True(t, true, "Sample integration test should pass")
}
EOF
    
    # Create test helper
    cat > tests/fixtures/test_helpers.go << 'EOF'
package fixtures

import (
    "database/sql"
    "testing"
    
    _ "github.com/mattn/go-sqlite3"
    "github.com/stretchr/testify/require"
)

// SetupTestDB creates an in-memory SQLite database for testing
func SetupTestDB(t *testing.T) *sql.DB {
    db, err := sql.Open("sqlite3", ":memory:")
    require.NoError(t, err)
    
    // Add your table creation SQL here
    // _, err = db.Exec(`CREATE TABLE ...`)
    // require.NoError(t, err)
    
    return db
}

// CleanupTestDB closes the test database
func CleanupTestDB(t *testing.T, db *sql.DB) {
    err := db.Close()
    require.NoError(t, err)
}
EOF
    
    print_success "Sample test files created"
}

# Create Makefile for common tasks
create_makefile() {
    print_header "Creating Makefile"
    
    cat > Makefile << 'EOF'
.PHONY: dev build test test-unit test-integration test-coverage clean generate help

# Development
dev:
	wails dev

# Build
build:
	wails build

build-debug:
	wails build -debug

# Testing
test:
	go test -v ./...

test-unit:
	go test -v ./tests/unit/... ./internal/...

test-integration:
	go test -v ./tests/integration/...

test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Code generation
generate:
	go generate ./...

# Cleanup
clean:
	rm -rf build/
	rm -rf frontend/dist/
	rm -f coverage.out coverage.html

# Install dependencies
install:
	go mod download
	cd frontend && npm install

# Format code
fmt:
	go fmt ./...
	cd frontend && npm run format

# Lint
lint:
	golangci-lint run
	cd frontend && npm run lint

# Help
help:
	@echo "Available commands:"
	@echo "  dev              - Run in development mode"
	@echo "  build            - Build for production"
	@echo "  build-debug      - Build with debug symbols"
	@echo "  test             - Run all tests"
	@echo "  test-unit        - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  test-coverage    - Run tests with coverage report"
	@echo "  generate         - Generate mocks and other code"
	@echo "  clean            - Clean build artifacts"
	@echo "  install          - Install dependencies"
	@echo "  fmt              - Format code"
	@echo "  lint             - Run linters"
	@echo "  help             - Show this help"
EOF
    
    print_success "Makefile created"
}

# Run tests to verify setup
verify_setup() {
    print_header "Verifying Setup"
    
    print_status "Running sample tests..."
    if go test -v ./tests/unit/... ./tests/integration/...; then
        print_success "Sample tests passed"
    else
        print_warning "Some tests failed, but this is expected with sample data"
    fi
    
    print_status "Generating mocks (if any interfaces exist)..."
    go generate ./... 2>/dev/null || true
    
    print_status "Checking Wails build..."
    if wails doctor &>/dev/null; then
        print_success "Wails is properly configured"
    else
        print_warning "Wails doctor found issues. Run 'wails doctor' for details."
    fi
    
    print_success "Setup verification complete"
}

# Show next steps
show_next_steps() {
    print_header "Setup Complete! 🚀"
    
    echo -e "${GREEN}Your Wails project is now configured with Cursor AI assistance!${NC}\n"
    
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Reload Cursor: Cmd+Shift+P → 'Developer: Reload Window'"
    echo "2. Try asking Cursor: 'Create a new user management sub-app following the established patterns'"
    echo "3. Run tests: make test"
    echo "4. Start development: make dev"
    echo
    
    echo -e "${BLUE}Available Commands:${NC}"
    echo "  make dev              - Start development mode"
    echo "  make test             - Run all tests" 
    echo "  make test-coverage    - Generate coverage report"
    echo "  make generate         - Generate mocks"
    echo "  make help             - See all available commands"
    echo
    
    echo -e "${BLUE}Example Cursor Prompts to Try:${NC}"
    echo "  • 'Add a new task management sub-app with CRUD operations'"
    echo "  • 'Create unit tests for the existing anime prompt service'"
    echo "  • 'Add validation to the report service with proper error handling'"
    echo "  • 'Create an integration test for the user repository'"
    echo "  • 'Add a new migration for a comments table'"
    echo
    
    echo -e "${BLUE}Project Structure Created:${NC}"
    echo "  .cursor/rules/        - Cursor AI configuration"
    echo "  tests/               - Test organization"
    echo "  internal/            - Go backend structure"
    echo "  .cursorignore        - Files to exclude from AI context"
    echo "  .vscode/settings.json - Editor configuration"
    echo "  Makefile             - Common development tasks"
    echo
    
    echo -e "${GREEN}Happy coding with Cursor + Wails! 🎉${NC}"
}

# Main execution
main() {
    print_header "🚀 Wails + Cursor Setup Script"
    
    # Run all setup steps
    check_wails_project
    create_directories
    create_cursorignore
    create_cursor_rules
    create_vscode_settings
    install_go_tools
    create_sample_tests
    create_makefile
    verify_setup
    show_next_steps
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi