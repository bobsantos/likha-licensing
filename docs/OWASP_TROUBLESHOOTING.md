# OWASP Dependency Check Troubleshooting Guide

## Overview

This guide provides solutions for common OWASP Dependency Check failures, particularly NVD API authentication issues that result in 403/404 errors.

## Current Configuration

Our project uses OWASP Dependency Check Maven plugin version 9.0.9 with the following optimizations:

### Maven Configuration
- **NVD API Delay**: 16 seconds (16000ms) - increased from default 2 seconds
- **Max Retry Count**: 5 attempts with exponential backoff  
- **API Timeout**: 60 seconds (60000ms)
- **Cache Valid**: 24 hours to reduce API calls
- **Data Directory**: Persistent caching enabled

### GitHub Workflow Strategy
- **Primary Attempt**: Uses NVD API key with enhanced timeouts
- **Fallback Method**: Runs without API key using local database
- **Performance Monitoring**: Tracks scan duration and success rates

## Common Issues and Solutions

### 1. NVD API 403/404 Errors

**Symptoms:**
```
Error: UpdateException: Error updating the NVD Data; the NVD returned a 403 or 404 error
```

**Root Causes:**
- Invalid or expired NVD API key
- Rate limiting from multiple concurrent builds
- Temporary NVD service issues
- API key not properly configured in GitHub Secrets

**Solutions:**

#### A. Verify API Key Configuration
1. Check GitHub repository secrets for `NVD_API_KEY`
2. Ensure API key is activated (check email from NIST)
3. Test API key manually:
   ```bash
   curl -H "Accept: application/json" \
        -H "apiKey: YOUR_API_KEY" \
        -v "https://services.nvd.nist.gov/rest/json/cves/2.0?cpeName=cpe:2.3:o:microsoft:windows_10:1607:*:*:*:*:*:*:*"
   ```

#### B. Local Testing
```bash
# Test with API key
mvn dependency-check:check -DnvdApiKey="YOUR_API_KEY" -DnvdApiDelay=16000 -Dfrontend.skip=true

# Test without API key (fallback)
mvn dependency-check:check -DnvdApiDelay=20000 -DskipNvdApiWait=true -Dfrontend.skip=true
```

#### C. Manual Workflow Trigger Options
Use workflow dispatch with these options:
- **Skip OWASP**: `true` - Temporarily skip security scans
- **Force Full Scan**: `true` - Clear cache and run fresh scan

### 2. Rate Limiting Issues

**Symptoms:**
- Intermittent 403 errors
- Multiple builds failing simultaneously

**Solutions:**
- Stagger build times to avoid concurrent API calls
- Use cache effectively with `nvdValidForHours=24`
- Consider dedicated NVD API key per environment

### 3. Cache Issues

**Symptoms:**
- Long scan times
- Repeated downloads of NVD database

**Solutions:**
- Verify cache directory permissions
- Check if GitHub Actions cache is properly configured
- Clear cache manually if corrupted:
  ```bash
  rm -rf ~/.m2/repository/org/owasp/dependency-check-data
  rm -rf target/dependency-check-data
  ```

## Emergency Procedures

### Quick Fix for CI Failures

1. **Immediate workaround**: Use workflow dispatch and set "Skip OWASP" to true
2. **Temporary fix**: Run OWASP scan manually after CI completes
3. **Long-term fix**: Follow troubleshooting steps above

### Alternative Security Scanning

If OWASP continues to fail, we have backup security scanning:
- **Trivy**: Filesystem and container vulnerability scanning
- **npm audit**: Frontend dependency scanning  
- **License compliance**: Maven and npm license checking

## Monitoring and Reporting

### Performance Metrics Tracked
- Scan duration and success rate
- Cache hit/miss ratios
- API vs fallback method usage
- Error patterns and frequency

### Artifacts Generated
- `backend/target/dependency-check-report.html` - Detailed vulnerability report
- `owasp-performance.md` - Performance and troubleshooting data
- Console logs with detailed error information

## Getting Help

### Internal Resources
1. Check workflow artifacts for detailed error logs
2. Review `owasp-performance.md` for scan status
3. Check GitHub Actions logs for specific error messages

### External Resources
1. [NIST NVD API Documentation](https://nvd.nist.gov/developers/request-an-api-key)
2. [OWASP Dependency Check Documentation](https://jeremylong.github.io/DependencyCheck/)
3. [Community Issues Tracker](https://github.com/dependency-check/DependencyCheck/issues)

## Configuration Reference

### Maven Plugin Settings
```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>9.0.9</version>
    <configuration>
        <nvdApiKey>${nvdApiKey}</nvdApiKey>
        <nvdApiDelay>16000</nvdApiDelay>
        <nvdMaxRetryCount>5</nvdMaxRetryCount>
        <nvdApiTimeout>60000</nvdApiTimeout>
        <nvdValidForHours>24</nvdValidForHours>
        <skipNvdApiWait>false</skipNvdApiWait>
        <failBuildOnCVSS>7</failBuildOnCVSS>
    </configuration>
</plugin>
```

### Environment Variables
- `NVD_API_KEY`: Your NIST NVD API key
- `nvdApiKey`: Maven property (can override via -DnvdApiKey)

## Version History

- **v1.0**: Initial troubleshooting guide with fallback strategy
- **Latest**: Enhanced timeout settings and dual-method approach