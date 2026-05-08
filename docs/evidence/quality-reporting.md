# Quality Reporting Evidence

## Purpose

This document records the quality-reporting evidence used for the BidMart final project rubric.

## Backend Quality Reports

The backend services generate the following reports:

~~~text
build/reports/tests/test
build/reports/pmd
build/reports/jacoco/test
~~~

Covered backend repositories:

~~~text
bidmart-auth-service
bidmart-api-gateway
~~~

Validation commands:

~~~bash
./gradlew clean generateProto test jacocoTestReport pmdMain pmdTest
./scripts/verify-quality-reports.sh
./scripts/print-coverage-summary.sh
~~~

## Frontend Quality Artifacts

The frontend repository generates:

~~~text
reports/eslint-report.json
dist
~~~

Validation commands:

~~~bash
npm ci
./scripts/generate-quality-reports.sh
./scripts/verify-quality-reports.sh
~~~

## CI Artifacts

GitHub Actions uploads quality artifacts for:

~~~text
bidmart-auth-service
bidmart-api-gateway
frontend-bidmart
bidmart-deployment
~~~

## Rubric Mapping

### Software Quality

- Unit/integration tests are executed in CI.
- PMD static analysis is executed for Java backend services.
- JaCoCo coverage reports are generated for backend services.
- ESLint report and build artifacts are generated for the frontend.
- Quality reports are uploaded as GitHub Actions artifacts.

### Testing

- Existing behavior is protected with regression tests.
- New gRPC and deployment work has red-green-refactor evidence.
- Docker Compose smoke test validates service integration.

### CI/CD

- Each core repository runs quality checks automatically.
- Deployment repository validates the integrated Docker Compose stack.
