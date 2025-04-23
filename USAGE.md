# MAGMA Visual Reasoning Testing

This project implements a testing framework for evaluating MAGMA's visual reasoning capabilities via Azure AI Foundry, focusing on the robotic alignment scenario described in the main README.

## Setup

1. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Create a `.env` file with your Azure AI Foundry credentials:
   ```
   # Your Azure API key for MAGMA access
   AZURE_API_KEY=your_api_key_here
   
   # The Azure AI Foundry endpoint for MAGMA
   AZURE_ENDPOINT=your_endpoint_here
   ```

3. Add the `.env` file to your `.gitignore` to prevent accidental exposure of credentials:
   ```bash
   echo ".env" >> .gitignore
   ```

## Authentication Alternatives

For production scenarios, consider these more secure authentication alternatives:

1. **Managed Identity**: For applications hosted in Azure, use Managed Identity instead of API keys.

2. **Azure Key Vault**: Store credentials in Azure Key Vault and access them securely in your application.

3. **Microsoft Entra ID (Azure AD)**: For user applications, consider Azure AD authentication with appropriate scopes.

## Running the Tests

### Step 1: Run the MAGMA API tests with the alignment images

Run the tests with the Chain-of-Thought (CoT) prompt:
```bash
python src/test_magma.py --prompt-type cot --output-dir results
```

Or with the Zero-Shot prompt:
```bash
python src/test_magma.py --prompt-type zero-shot --output-dir results
```

### Step 2: Analyze the results

After running the tests, analyze the results:
```bash
python src/analyze_results.py --results-dir results --output-file analysis_summary.json
```

This will generate a detailed analysis of MAGMA's performance on the alignment tasks.

## Security Considerations

This implementation follows secure practices for accessing Azure AI Foundry:

1. **API Key Security**: 
   - API keys are loaded from environment variables, not hardcoded in source code
   - Keys should be rotated regularly according to your organization's security policies
   - In production, store API keys in Azure Key Vault

2. **Authentication & Authorization**:
   - Follow principle of least privilege when creating Azure service credentials
   - For production deployments, prefer Managed Identity over API keys when possible
   - Implement regular access reviews for all Azure credentials

3. **HTTPS Communication**: 
   - All requests to Azure AI Foundry use HTTPS
   - TLS 1.2 or later is enforced for all communications

4. **Error Handling**: 
   - Comprehensive error handling to prevent exposing sensitive information
   - Implement retry logic with exponential backoff for transient failures
   - Log errors appropriately without exposing sensitive data

5. **Logging & Monitoring**:
   - Request tracing IDs are used for debugging and auditing
   - Implement appropriate logging levels (INFO for normal operations, ERROR for issues)
   - Don't log sensitive information such as credentials or personally identifiable information

6. **Input Validation**:
   - All user inputs are validated before processing
   - File paths are sanitized to prevent path traversal attacks
   - Image inputs are validated before processing

7. **Resource Management**:
   - Properly clean up resources after use
   - Handle connection lifecycle appropriately

For more information on Azure security best practices, refer to the [Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/fundamentals/).

## Test Coverage

The test suite covers all 6 images from the dataset:
- 1 aligned image (`aligned.png`)
- 5 misaligned images (`misalignment_1.png` through `misalignment_5.png`)

Each image is tested with two different prompt strategies:
1. **Zero-Shot**: A simple prompt asking for alignment analysis
2. **Chain-of-Thought (CoT)**: A structured prompt guiding MAGMA through the reasoning process

## Analysis and Evaluation

The analysis script evaluates MAGMA's performance based on:
1. Correctly identifying the alignment status (aligned/misaligned)
2. For misaligned images, correctly identifying the axis of misalignment (x, y, z, yaw)
3. For misaligned images, correctly identifying the direction of correction

Results are provided as both structured JSON and human-readable console output.

## Security Disclosure

If you discover a security vulnerability in this sample, please follow responsible disclosure practices and report it to the maintainers via email at [security@example.com](mailto:security@example.com).