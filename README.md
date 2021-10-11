# Internal-Data-Hub

A repo housing deployment artifacts for components of the Internal
Data Hub that are not managed by the ODH operator.

## Development Instructions

### Running Pre-Commit Tests

Our world is being taken over by shitty bots that add little value. In order
to satisfy these bots, you must ensure that your code complies with
arbitrary standards. To check your compliance, perform the following:

```
pip install --user pre-commit
pre-commit run --all-files
```
