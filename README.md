# Cursor + Wails Integration Toolkit

> **Supercharge your Wails development with AI-powered coding assistance**

This repository provides a complete setup toolkit for integrating [Cursor AI](https://cursor.sh) with [Wails](https://wails.io) applications, featuring intelligent code generation, architectural guidance, and macOS-optimized workflows.

## ✨ Features

- **🧠 AI-Powered Architecture**: Cursor rules that understand Wails patterns, Go backend structure, and clean architecture principles
- **⚡ One-Command Setup**: Automated script that configures your entire development environment
- **🧪 TDD-Ready**: Pre-configured testing structure with mocks, unit tests, and integration tests
- **🍎 macOS Optimized**: Native shortcuts, file paths, and development patterns for Mac
- **📁 Smart Code Organization**: Clean architecture with proper separation of concerns
- **🗄️ SQLite Integration**: Ready-to-use database patterns and connection management

## 🚀 Quick Start

### Prerequisites

- [Go](https://golang.org/dl/) 1.19+
- [Wails CLI](https://wails.io/docs/gettingstarted/installation)
- [Cursor Editor](https://cursor.sh)
- macOS (optimized for, but adaptable to other platforms)

### 1. Add to Your Wails Project

```bash
# Navigate to your Wails project root
cd your-wails-project

# Download the setup script
curl -O https://raw.githubusercontent.com/your-username/cursor-wails-toolkit/main/wails-cursor-setup-script.sh

# Make it executable
chmod +x wails-cursor-setup-script.sh

# Run the setup
./wails-cursor-setup-script.sh
```

### 2. Reload Cursor

After setup completes:
1. Open your project in Cursor
2. Press `Cmd+Shift+P` → "Developer: Reload Window"
3. Cursor will now understand your Wails architecture!

## 📋 What Gets Configured

### Directory Structure
```
your-wails-project/
├── .cursor/rules/              # AI architecture rules
│   ├── 00-core-architecture.mdc
│   ├── 01-go-backend.mdc
│   ├── 02-testing-tdd.mdc
│   ├── 03-database-sqlite.mdc
│   ├── 04-service-layer.mdc
│   ├── 05-sub-apps.mdc
│   └── 06-mac-development.mdc
├── tests/
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   ├── mocks/                  # Generated mocks
│   └── fixtures/               # Test helpers
├── internal/
│   ├── service/                # Business logic
│   ├── repository/             # Data access
│   ├── model/                  # Domain models
│   ├── config/                 # Configuration
│   └── connection/             # Database connections
├── .cursorignore              # AI context exclusions
├── .vscode/settings.json      # Editor configuration
└── Makefile                   # Development commands
```

### Configuration Files

- **`.cursor/rules/`**: Intelligent coding rules that teach Cursor about Wails patterns
- **`.cursorignore`**: Excludes build artifacts and dependencies from AI context
- **`.vscode/settings.json`**: Optimized Go development settings
- **`Makefile`**: Common development tasks and shortcuts

## 🎯 Example AI Prompts

Once configured, try these prompts with Cursor:

```
🔥 "Create a new task management sub-app with CRUD operations"
🧪 "Add comprehensive unit tests for the user service"
🔒 "Implement input validation with proper error handling"
🗄️ "Create a migration for adding user preferences table"
📱 "Add macOS native menu integration"
```

## ⌨️ Essential Mac Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘+K` | Inline code editing and generation |
| `⌘+I` | Open Composer/Agent mode |
| `⌘+⇧+P` | Command palette |
| `⌘+J` | Toggle terminal |
| `⌘+B` | Toggle sidebar |
| `⌘+T` | Quick file open |

## 🏗️ Architecture Patterns

### Wails App Layer
```go
// Clean separation between Wails bindings and business logic
func (a *App) UserApp_Create(user model.User) error {
    return a.userSvc.Create(user)
}
```

### Service Layer
```go
// Business logic with proper error handling
func (s *UserService) Create(user model.User) error {
    if err := s.validateUser(user); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    return s.repo.Save(user)
}
```

### Repository Layer
```go
// Data access with interface-driven design
type IUserRepository interface {
    Save(user model.User) (string, error)
    FindByID(id string) (model.User, error)
}
```

## 🧪 Testing Framework

### Unit Tests
```bash
make test-unit          # Run unit tests
make test-coverage      # Generate coverage report
```

### Integration Tests
```bash
make test-integration   # Run integration tests
make test               # Run all tests
```

### Mock Generation
```bash
make generate          # Generate mocks for interfaces
```

## 🔧 Development Commands

```bash
# Development
make dev               # Start Wails dev mode
make build             # Build for production

# Testing
make test              # Run all tests
make test-coverage     # Generate coverage report

# Code Quality
make fmt               # Format code
make lint              # Run linters
make generate          # Generate mocks

# Cleanup
make clean             # Clean build artifacts
make help              # Show all commands
```

## 📁 File Descriptions

| File | Purpose |
|------|---------|
| `Cursor Cheat Sheet.md` | Complete reference for shortcuts and configuration |
| `wails-cursor-setup-script.sh` | Automated setup script |
| `.cursor/rules/*.mdc` | AI architecture rules for different domains |

## 🎨 Customization

### Adding New Sub-Apps

The toolkit includes patterns for easily adding new features:

1. **Ask Cursor**: "Create a new inventory management sub-app"
2. **Follow the Pattern**: Cursor will automatically create:
   - Domain model
   - Repository interface & implementation
   - Service layer with business logic
   - Wails app bindings
   - Comprehensive tests

### Custom Rules

Add your own `.mdc` files to `.cursor/rules/` for project-specific patterns.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test with a real Wails project
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Wails](https://wails.io) - Amazing Go + Web framework
- [Cursor](https://cursor.sh) - Revolutionary AI-powered editor
- [Go](https://golang.org) - Fast, reliable backend language

---

**Ready to build amazing desktop apps with AI assistance?** 🚀

[Get Started](#quick-start) | [View Examples](examples/) | [Report Issues](issues/)
