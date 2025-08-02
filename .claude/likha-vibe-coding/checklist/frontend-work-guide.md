# Frontend Work Guide for @agent-frontend

This guide provides best practices and references for @agent-frontend when working on frontend tasks from `@.claude/likha-vibe-coding/prod-dev/todo.md`.

## Core References

- **Test-Driven Development**: @.claude/likha-vibe-coding/data/tdd.md
- **Frontend Tech Stack**: @.claude/likha-vibe-coding/data/frontend-tech-stack.md
- **Frontend Best Practices**: @.claude/likha-vibe-coding/data/frontend-best-practices.md
- **Design Best Practices**: @.claude/likha-vibe-coding/data/design-best-practices.md
- **Domain-Driven Design**: @.claude/likha-vibe-coding/data/ddd.md
- **Domain Model Reference**: @docs/domain/domains.md

## Frontend Task Approach

### MANDATORY Pre-Implementation Checklist
Before writing ANY implementation code, you MUST complete these steps IN ORDER:
- [ ] Read and understand the full task requirements from todo.md
- [ ] Create a detailed todo list using TodoWrite tool with your implementation plan
- [ ] Share your implementation plan with the user
- [ ] Write failing tests first (TDD approach - Red phase)
  - Write React Testing Library tests for component behavior
  - Write unit tests for custom hooks and utilities
  - Write integration tests for user workflows
  - Test accessibility requirements (WCAG compliance)
- [ ] Get user confirmation or wait 30 seconds for implicit approval
- [ ] Only then proceed with implementation to make tests pass

**CRITICAL**: If you skip any of these steps, the user will interrupt you and you'll need to start over.

### 1. Pre-Implementation Phase

**Understand the Task Context**
- Review UI/UX requirements and mockups
- Understand user workflows and interactions
- Plan component hierarchy and state management
- Identify API integrations needed

**Test-First Development (TDD)**
- Write component tests first with React Testing Library
- Test user interactions, not implementation details
- Focus on accessibility from the start
- Reference: TDD Best Practices guide

### 2. Implementation Guidelines

**React Architecture**
- Use functional components with hooks
- Implement proper component composition
- Follow single responsibility principle
- Keep components focused and reusable

**TypeScript Best Practices**
```typescript
// Define clear interfaces
interface LicenseProps {
  license: License;
  onEdit: (id: string) => void;
  onDelete: (id: string) => void;
}

// Use proper typing
const LicenseCard: React.FC<LicenseProps> = ({ license, onEdit, onDelete }) => {
  // Implementation
};
```

**Chakra UI Components**
- Use Chakra UI theme system
- Implement responsive designs
- Follow accessibility guidelines
- Maintain consistent spacing

**State Management**
- Use React hooks for local state
- Context API for cross-component state
- Consider React Query for server state
- Avoid unnecessary re-renders

### 3. Collaboration Requirements

**CRITICAL**: Always collaborate with supporting teams when tasks require it!

**When to Collaborate with @agent-backend:**
- API contract definition
- Error handling strategies
- Data format optimization
- Authentication flow implementation
- WebSocket integration

**When to Collaborate with @agent-security:**
- Authentication UI implementation
- Secure data handling in browser
- XSS prevention measures
- Content Security Policy setup
- **IMPORTANT**: Request security review before deploying any forms or data input features
- Security review for any components handling sensitive information

**When to Collaborate with @agent-infra:**
- CDN configuration needs
- Build optimization requirements
- Deployment pipeline setup
- Performance monitoring
- Static asset handling

**When to Collaborate with @agent-designer:**
- UI/UX clarifications
- Design system updates
- Accessibility requirements
- User flow optimization
- Visual consistency

### 4. Testing Strategy

**Component Testing**
```typescript
import { render, screen, userEvent } from '@testing-library/react';

describe('LicenseForm', () => {
  it('should submit form with valid data', async () => {
    const onSubmit = vi.fn();
    render(<LicenseForm onSubmit={onSubmit} />);
    
    const user = userEvent.setup();
    await user.type(screen.getByLabelText('License Name'), 'Test License');
    await user.click(screen.getByRole('button', { name: 'Submit' }));
    
    expect(onSubmit).toHaveBeenCalledWith({
      name: 'Test License'
    });
  });
});
```

**Integration Testing**
- Test API integration with MSW
- Validate error scenarios
- Test loading states
- Verify data transformations

**Accessibility Testing**
```typescript
it('should be keyboard navigable', async () => {
  render(<Navigation />);
  const user = userEvent.setup();
  
  await user.tab();
  expect(screen.getByRole('link', { name: 'Home' })).toHaveFocus();
});
```

### 5. Component Patterns

**Custom Hooks**
```typescript
function useLicenses() {
  const [licenses, setLicenses] = useState<License[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchLicenses()
      .then(setLicenses)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  return { licenses, loading, error };
}
```

**Error Boundaries**
```typescript
class ErrorBoundary extends React.Component {
  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }
    return this.props.children;
  }
}
```

**Data Tables with TanStack**
```typescript
const columns = useMemo<ColumnDef<License>[]>(
  () => [
    {
      accessorKey: 'name',
      header: 'License Name',
      cell: info => info.getValue(),
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: info => <StatusBadge status={info.getValue()} />,
    },
  ],
  []
);
```

## UI/UX Best Practices

**Responsive Design**
```typescript
<Box
  display={{ base: 'block', md: 'flex' }}
  padding={{ base: 4, md: 8 }}
  gap={4}
>
  {/* Responsive content */}
</Box>
```

**Loading States**
```typescript
if (loading) {
  return (
    <Center height="200px">
      <Spinner size="xl" />
    </Center>
  );
}
```

**Error Handling**
```typescript
if (error) {
  return (
    <Alert status="error">
      <AlertIcon />
      <AlertTitle>Error loading licenses</AlertTitle>
      <AlertDescription>{error.message}</AlertDescription>
    </Alert>
  );
}
```

## Performance Optimization

**Code Splitting**
```typescript
const AdminPanel = lazy(() => import('./AdminPanel'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <AdminPanel />
    </Suspense>
  );
}
```

**Memoization**
```typescript
const MemoizedLicenseList = memo(LicenseList, (prevProps, nextProps) => {
  return prevProps.licenses.length === nextProps.licenses.length;
});
```

**Image Optimization**
- Use appropriate image formats
- Implement lazy loading
- Provide responsive images
- Optimize bundle size

## Accessibility Standards

**ARIA Labels**
```typescript
<IconButton
  aria-label="Delete license"
  icon={<DeleteIcon />}
  onClick={() => handleDelete(license.id)}
/>
```

**Keyboard Navigation**
- Ensure all interactive elements are keyboard accessible
- Implement proper focus management
- Provide skip links
- Test with screen readers

**Color Contrast**
- Meet WCAG 2.1 AA standards
- Test with contrast checking tools
- Provide high contrast mode
- Don't rely on color alone

## Security Considerations

**Input Sanitization**
- Validate all user inputs
- Prevent XSS attacks
- Use Content Security Policy
- Avoid dangerouslySetInnerHTML

**Secure Storage**
- Don't store sensitive data in localStorage
- Use secure cookies for auth tokens
- Implement proper CORS handling
- Validate data from APIs

## Documentation Standards

**Component Documentation**
```typescript
/**
 * LicenseTable displays a paginated list of licenses with sorting and filtering.
 * 
 * @example
 * <LicenseTable 
 *   licenses={licenses}
 *   onEdit={handleEdit}
 *   onDelete={handleDelete}
 * />
 */
```

**Storybook Stories**
```typescript
export default {
  title: 'Components/LicenseTable',
  component: LicenseTable,
} as Meta;

export const Default: Story = {
  args: {
    licenses: mockLicenses,
  },
};
```

## Monitoring & Analytics

**Performance Metrics**
- Core Web Vitals (LCP, FID, CLS)
- Bundle size monitoring
- Runtime performance
- Error tracking

**User Analytics**
- Track user interactions
- Monitor feature usage
- Measure task completion
- A/B testing support

## Continuous Improvement

**Code Reviews**
- Focus on component reusability
- Check accessibility compliance
- Verify responsive design
- Ensure proper error handling

**Stay Updated**
- Keep up with React updates
- Monitor security advisories
- Learn new patterns
- Share knowledge with team

Remember: The frontend is the user's window into the application. Focus on usability, performance, and accessibility. Always test from the user's perspective and collaborate closely with design and backend teams!