# Publishing Guide

## Prerequisites

1. Create an npm account at https://www.npmjs.com/signup
2. Login to npm from your terminal:
   ```bash
   npm login
   ```

## Before Publishing

1. **Update package.json** with your information:

   - Change `author` to your name
   - Update `repository.url` with your GitHub repository URL
   - Update `bugs.url` with your GitHub issues URL
   - Update `homepage` with your GitHub repository URL

2. **Check package name availability**:

   ```bash
   npm search git-walkthrough
   ```

   If the name is taken, choose a different name in `package.json` (e.g., `@yourusername/git-walkthrough`)

3. **Test the package locally**:

   ```bash
   npm link
   cd /path/to/any/git/repo
   git-walkthrough
   ```

4. **Commit your changes to git**:
   ```bash
   git add .
   git commit -m "Prepare for npm publish"
   git push origin main
   ```

## Publishing Steps

1. **Ensure you're logged in to npm**:

   ```bash
   npm whoami
   ```

2. **Publish to npm**:

   ```bash
   npm publish
   ```

   If you want to use a scoped package (recommended for first-time publishing):

   ```bash
   npm publish --access public
   ```

## After Publishing

1. **Test the published package**:

   ```bash
   npm install -g git-walkthrough
   # or with your scoped package name:
   npm install -g @yourusername/git-walkthrough
   ```

2. **Try it out**:
   ```bash
   cd /path/to/any/git/repo
   git-walkthrough
   ```

## Updating the Package

When you make changes:

1. Update the version in `package.json`:

   - Patch release (bug fixes): `1.0.0` → `1.0.1`
   - Minor release (new features): `1.0.0` → `1.1.0`
   - Major release (breaking changes): `1.0.0` → `2.0.0`

2. Or use npm's version command:

   ```bash
   npm version patch  # for bug fixes
   npm version minor  # for new features
   npm version major  # for breaking changes
   ```

3. Commit and push:

   ```bash
   git push origin main --tags
   ```

4. Publish the update:
   ```bash
   npm publish
   ```

## Troubleshooting

- **Name already exists**: Change the package name or use a scoped package (`@yourusername/git-walkthrough`)
- **Permission denied**: Make sure you're logged in with `npm login`
- **Script not executable**: The `postinstall` script in package.json will handle this automatically

## Optional: Add Postinstall Script

If users report permission issues, add this to `package.json`:

```json
"scripts": {
  "postinstall": "chmod +x git-walkthrough.sh"
}
```
