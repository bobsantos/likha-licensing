# GitHub Actions CI/CD Pipeline

This directory contains the CI/CD pipeline configuration for the Likha Licensing Platform, designed for a multi-tenant B2B SaaS application built with Spring Boot and React.

> **🚧 Development Status**: Currently only CI and code quality pipelines are active. Deployment workflows are controlled via repository variables and can be enabled when ready for staging/production deployment.

## Pipeline Overview

### 🚀 Workflows

#### 1. **CI Pipeline** (`ci.yml`)
**Trigger:** Pull requests to `main`/`develop` branches
**Purpose:** Continuous integration with comprehensive testing and quality checks

**Jobs:**
- **Backend CI**: Tests Spring Boot application with PostgreSQL integration
- **Frontend CI**: Tests React/TypeScript application with linting and type checking
- **Security**: OWASP dependency scanning and npm audit
- **Integration Build**: Full application build combining backend + frontend
- **CI Success**: Status check aggregation for PR requirements

#### 2. **Deploy Pipeline** (`deploy.yml`) - CONDITIONALLY ENABLED
**Status:** Deployment pipeline is controlled by the `DEPLOY_ENABLED` repository variable
**Purpose:** Automated deployment to staging and production environments

**Note:** Deployment workflows are disabled by default and require the `DEPLOY_ENABLED` repository variable to be set to `'true'`. They can also be triggered manually via workflow dispatch. Only CI and code quality pipelines run unconditionally.

#### 3. **Code Quality & Security** (`code-quality.yml`)
**Trigger:** PR/push events, scheduled daily scans
**Purpose:** Advanced static analysis, security scanning, and compliance checks

**Jobs:**
- **Code Analysis**: SpotBugs, Checkstyle, static analysis
- **Security Scan**: OWASP, Trivy, vulnerability assessments
- **Container Security**: Docker image security scanning
- **License Check**: OSS license compliance validation
- **Coverage**: Code coverage analysis and reporting
- **Performance**: Bundle size analysis and JMH benchmarks

## 🏗️ Architecture & Technology Stack

### Backend
- **Java 21** with Spring Boot 3.2+
- **Maven** build system with multi-module structure
- **Spring Modulith** for modular monolith architecture
- **PostgreSQL 15+** with Testcontainers for integration tests
- **JUnit 5** + Mockito + AssertJ for testing

### Frontend
- **React 18+** with TypeScript 5.2+
- **Vite** for build tooling and development server
- **ESLint** for code linting
- **Node.js 20** with npm package management

### Infrastructure
- **Docker** containerization with multi-stage builds
- **GitHub Container Registry** (GHCR) for image storage
- **AWS ECS** deployment target (configurable)
- **PostgreSQL** managed database service

## 🔧 Setup Instructions

### Prerequisites
1. **Repository Variables**: Configure deployment control in GitHub repository settings:
   ```
   # Deployment Control Variable (Repository Variables tab):
   DEPLOY_ENABLED            # Set to 'true' to enable deployments, 'false' or unset to disable
   ```

2. **Repository Secrets**: Configure the following in GitHub repository settings:
   ```
   # Currently only needed for code quality integrations:
   SONAR_TOKEN               # SonarCloud integration (optional)
   CODECOV_TOKEN             # Codecov integration (optional)
   
   # Deployment secrets (needed only when DEPLOY_ENABLED is 'true'):
   AWS_ACCESS_KEY_ID          # AWS deployment credentials
   AWS_SECRET_ACCESS_KEY      # AWS deployment credentials  
   AWS_REGION                 # AWS region (e.g., us-east-1)
   ```

2. **Branch Protection**: Enable branch protection rules on `main` branch:
   - Require status checks: `CI Success`
   - Require up-to-date branches
   - Require review from code owners

### Local Development Setup
```bash
# Clone and setup
git clone <repository-url>
cd likha-licensing

# Backend setup
mvn clean install -Dfrontend.skip=true

# Frontend setup
cd frontend
npm install
npm run build
cd ..

# Full build test
mvn clean package -Pci
```

### Environment Configuration

#### Development
```bash
# Run with development profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

#### Testing
```bash
# Run all tests
mvn clean verify -Pci

# Run only backend tests
mvn clean test -Dfrontend.skip=true

# Run only frontend tests
cd frontend && npm test
```

## 📊 Pipeline Features

### Performance Optimizations
- **Parallel Jobs**: Backend, frontend, and security jobs run concurrently
- **Maven Caching**: Dependencies cached between runs (~2-3min savings)
- **Node Modules Caching**: npm dependencies cached (~1-2min savings)  
- **Docker Layer Caching**: Multi-stage build optimization
- **Conditional Execution**: Skip jobs for draft PRs

### Security & Compliance
- **OWASP Dependency Check**: Vulnerability scanning for Java dependencies
- **npm audit**: Security audit for Node.js dependencies
- **Trivy**: Container and filesystem vulnerability scanning
- **License Compliance**: Automated OSS license validation
- **SARIF Integration**: Security findings in GitHub Security tab

### Quality Gates
- **Test Coverage**: JaCoCo coverage reporting with Codecov integration
- **Code Quality**: SpotBugs and Checkstyle analysis
- **Type Safety**: TypeScript compilation and strict type checking
- **Bundle Size**: Frontend bundle size monitoring and limits
- **Performance**: JMH benchmark integration (when configured)

### Multi-Tenant Considerations
- **Schema Isolation**: PostgreSQL service container for tenant testing
- **Connection Pooling**: HikariCP configuration validation
- **Cross-Tenant Security**: Automated security boundary testing
- **Performance Isolation**: Tenant-specific performance monitoring

## 🚦 Status Checks & Gates

### Required Status Checks
- **Backend CI**: All backend tests pass
- **Frontend CI**: Linting, type checking, and tests pass  
- **Security**: No high/critical vulnerabilities (configurable)
- **Integration Build**: Full application builds successfully

### Quality Thresholds
- **Test Coverage**: Minimum 80% line coverage (configurable)
- **Bundle Size**: Frontend assets under 500KB gzipped
- **Vulnerability Severity**: Block high/critical CVEs
- **Build Time**: Target <10 minutes total pipeline time

## 📈 Monitoring & Observability

### Build Metrics
- Pipeline execution time and success rates
- Test execution time and flakiness detection
- Dependency resolution time and cache hit rates
- Security scan results and trend analysis

### Artifact Management
- **Docker Images**: Multi-architecture builds (AMD64/ARM64)
- **Build Artifacts**: JAR files with retention policies
- **Test Reports**: JUnit, coverage, and security scan results
- **Release Assets**: Automated GitHub releases for tags

## 🔄 Deployment Strategy - CONDITIONALLY ENABLED

**Current Status**: Deployment workflows are controlled by the `DEPLOY_ENABLED` repository variable and can be enabled/disabled as needed.

### Deployment Control

#### Enabling Deployments
1. **Via Repository Variable** (Recommended):
   - Go to repository **Settings > Secrets and variables > Actions**
   - Click on the **Variables** tab
   - Add a new repository variable named `DEPLOY_ENABLED` with value `'true'`
   - All future pushes to `main` and version tags will trigger deployments

2. **Via Manual Trigger** (Override):
   - Go to **Actions > Deploy Pipeline**
   - Click **Run workflow**
   - Select environment and trigger manually
   - This works regardless of the `DEPLOY_ENABLED` variable setting

#### Disabling Deployments
- Set `DEPLOY_ENABLED` to `'false'` or delete the variable entirely
- Deployments will be skipped with a clear explanation in the workflow logs
- Manual triggers will still work as an override

### Deployment Strategy
When deployments are enabled, the following strategy is implemented:

#### Staging Environment (To Be Configured)
- **Trigger**: Push to `main` branch
- **Purpose**: Integration testing and QA validation
- **Database**: Dedicated staging PostgreSQL instance
- **Monitoring**: Observability stack with alerts

#### Production Environment (To Be Configured)
- **Trigger**: Git tags (`v*`) or manual workflow dispatch
- **Strategy**: Blue-green deployment with automated rollback
- **Database**: High-availability PostgreSQL with multi-AZ
- **Monitoring**: Production SLAs with escalation policies

#### Rollback Procedures (To Be Implemented)
- **Automatic**: Triggered on deployment failure
- **Manual**: Workflow dispatch with previous version selection
- **Database**: Schema migration rollback strategies
- **Monitoring**: Health check validation and alerting

**Note**: The `deploy.yml` workflow uses the `DEPLOY_ENABLED` repository variable to control execution. Set this variable to `'true'` in repository settings when deployment infrastructure is ready.

## 🐛 Troubleshooting

### Common Issues

#### Build Failures
```bash
# Check Maven dependencies
mvn dependency:tree -Dfrontend.skip=true

# Verify Node.js setup
node --version && npm --version

# Test database connectivity
docker-compose up postgres -d
mvn test -Dtest=DatabaseConnectionValidationTest
```

#### Test Failures
```bash
# Run specific test class
mvn test -Dtest=YourTestClass -Dfrontend.skip=true

# Debug Testcontainers issues
export TESTCONTAINERS_RYUK_DISABLED=true
mvn test -Dfrontend.skip=true

# Frontend test debugging
cd frontend && npm test -- --verbose
```

#### Security Scan Issues
```bash
# Update dependency suppressions
vim .github/dependency-check-suppressions.xml

# Check specific CVE details
mvn org.owasp:dependency-check-maven:check -Dfrontend.skip=true
```

#### Docker Build Issues
```bash
# Test local Docker build
docker build -t likha-licensing:test .

# Check multi-stage build layers
docker build --target production -t likha-licensing:prod .
```

### Performance Optimization
- **Cache Strategy**: Leverage GitHub Actions cache for dependencies
- **Resource Allocation**: Use appropriate runner sizes for jobs  
- **Parallel Execution**: Maximize concurrent job execution
- **Early Termination**: Fail fast on critical errors

### Monitoring & Alerts
- **GitHub Actions**: Built-in workflow run monitoring
- **External Integrations**: Slack/Teams notifications on failures
- **Metrics Collection**: Custom metrics for build performance
- **SLA Tracking**: Pipeline SLA monitoring and alerting

## 📚 Additional Resources

- [Spring Boot Testing Guide](https://spring.io/guides/gs/testing-web/)
- [Testcontainers Documentation](https://www.testcontainers.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Multi-stage Builds](https://docs.docker.com/develop/dev-best-practices/dockerfile_best-practices/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)

## 🤝 Contributing

1. Create feature branch from `develop`
2. Implement changes with tests
3. Ensure all quality gates pass locally
4. Submit pull request with comprehensive description
5. Address code review feedback
6. Merge after all status checks pass

For questions or support, please refer to the project documentation or create an issue in the repository.