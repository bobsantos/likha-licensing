# Test Driven Development Checklist

## Core Principles

- [ ] **Red-Green-Refactor**: Write failing test, make it pass, then refactor
- [ ] **Test First**: Always write tests before implementation code
- [ ] **Small Steps**: Take the smallest possible steps to make tests pass
- [ ] **Continuous Refactoring**: Improve code structure after each passing test

## Test Writing Guidelines

- [ ] **Single Responsibility**: Each test should verify one specific behavior
- [ ] **Descriptive Names**: Test names clearly describe what is being tested
- [ ] **Arrange-Act-Assert**: Structure tests with clear setup, execution, and verification
- [ ] **Independent Tests**: Tests should not depend on each other's state

## Test Coverage

- [ ] **Happy Path**: Test expected behavior with valid inputs
- [ ] **Edge Cases**: Test boundary conditions and limits
- [ ] **Error Conditions**: Test invalid inputs and exception scenarios
- [ ] **Business Rules**: Verify all domain constraints and invariants

## Implementation Strategy

- [ ] **Minimal Implementation**: Write only enough code to make tests pass
- [ ] **Avoid Over-Engineering**: Don't implement features until tests require them
- [ ] **Incremental Development**: Add functionality one test at a time
- [ ] **Refactor Regularly**: Clean up code after each successful test

## Test Quality

- [ ] **Fast Execution**: Tests should run quickly to enable frequent execution
- [ ] **Deterministic**: Tests should have consistent, predictable results
- [ ] **Maintainable**: Tests should be easy to understand and modify
- [ ] **Isolated**: Tests should not have external dependencies when possible

## Feedback Loop

- [ ] **Frequent Test Runs**: Run tests continuously during development
- [ ] **Clear Failure Messages**: Test failures should clearly indicate the problem
- [ ] **Quick Fixes**: Address failing tests immediately
- [ ] **Test Suite Health**: Keep all tests passing at all times

## Integration with Development

- [ ] **Version Control**: Commit tests and code together
- [ ] **Code Reviews**: Include test quality in review process
- [ ] **Documentation**: Tests serve as living documentation of behavior
- [ ] **Regression Prevention**: Tests protect against future breaking changes