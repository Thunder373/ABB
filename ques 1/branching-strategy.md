# Branching Strategy

## Branch Types

1. **Main Branch**: 
   - The `main` branch is the production-ready state of the code.
   - Only stable code should be merged into this branch.

2. **Development Branch**:
   - The `develop` branch is where the latest development changes are made.
   - Features are merged into this branch before being merged into `main`.

3. **Feature Branches**:
   - Each new feature should be developed in its own branch.
   - Naming convention: `feature/<feature-name>`

4. **Bugfix Branches**:
   - Bug fixes should also be developed in their own branches.
   - Naming convention: `bugfix/<bug-name>`

## Workflow

1. Create a new branch for each feature or bugfix.
2. Make changes and commit them to the branch.
3. Push the branch to GitHub.
4. Create a pull request to merge changes into the `develop` branch.
5. Conduct code reviews on the pull request.
6. Once approved, merge the pull request into `develop`.
7. Periodically merge `develop` into `main` for production releases.