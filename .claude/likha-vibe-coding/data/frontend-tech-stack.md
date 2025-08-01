# Technology Stack

## Frontend

- **React 18+** with TypeScript
- **Vite** as build tool and development server
- **Chakra UI** for component library
- **TanStack Table** for advanced data grid functionality
- **Axios** for HTTP client
- **React Router** for client-side routing

## Testing Strategy & Methodologies

### Unit & Component Testing
- **Vitest** as primary test runner (Vite-native, fast execution)
- **@testing-library/react** for component testing with user-centric approach
- **@testing-library/jest-dom** for enhanced DOM assertions
- **@testing-library/user-event** for realistic user interaction simulation

### Test-Driven Development (TDD)
- **Red-Green-Refactor cycle** for component and utility development
- **React Testing Library** for component behavior-driven testing
- **Custom hooks testing** with @testing-library/react-hooks

### Behavior-Driven Development (BDD)
- **Cucumber.js** for acceptance testing with Gherkin syntax
- **User story mapping** to test scenarios
- **Business-readable test specifications**

### Integration & API Testing
- **MSW (Mock Service Worker)** for API mocking and contract testing
- **Axios interceptor testing** for authentication and error handling
- **React Query integration testing** (if implemented)

### End-to-End Testing
- **Playwright** for cross-browser E2E testing
- **User journey testing** for critical business flows
- **Visual regression testing** with Playwright screenshots

### Contract Testing
- **Pact.js** for consumer-driven contract testing with backend APIs
- **OpenAPI specification validation** for API contracts
- **Schema validation** for request/response payloads

### Accessibility Testing
- **@axe-core/react** for automated accessibility auditing
- **WCAG 2.1 AA compliance** testing
- **Keyboard navigation** and screen reader testing

### Performance Testing
- **Lighthouse CI** for performance regression testing
- **Bundle analyzer** for code splitting optimization
- **React DevTools Profiler** for component performance analysis

### Smoke Testing
- **Critical path verification** after deployments
- **Basic functionality validation** in production
- **Health check endpoints** monitoring

## Infrastructure & Deployment

- **Docker** for containerization
- **AWS Fargate** for serverless container deployment
- **Application Load Balancer (ALB)** for load balancing
- **AWS RDS** for managed PostgreSQL
- **AWS S3** for object storage

## Development & Operations

- **Docker Compose** for local development environment
- **GitHub Actions** for CI/CD pipeline
- **AWS CloudWatch** for monitoring and logging
