# hubValidations in a tin

This packages hubValidations in a docker container so they can be run without
requiring R to be installed on a machine.

The main motivation for this image is to simplify the validation process for
our workflows.

## Using the Image

### On GitHub

Images on GitHub need to be run at the job level. You can use the `container`
key for this. For this container, the working directory is `/project`, so you
need to link your github workspace the working directory using the `volumes`
keyword.

```yaml
jobs:
  validate-submission:
    runs-on: ubuntu-latest
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
    container:
      image: ghcr.io/hubverse-org/test-docker-hubvalidations:main
      ports:
        - 80
      volumes:
        - ${{ github.workspace }}:/project
```

After that, you only need 2 steps: checkout and validate:

```yaml
    steps:
      - name: Checkout Pull Request
        uses: actions/checkout@v4
      - name: Run validations
        run: |
          # R code you want to run
        shell: Rscript {0}
```

### Locally

To run locally, you can use this incantation with any command or script to run

```bash
docker run \
--platform=linux/amd64 \
--rm \
-it \
-v "/path/to/hub":"/project" \
ghcr.io/hubverse-org/test-docker-hubvalidations:main \
# script to run
```

## Helper Scripts

### Pull Request Validations

```bash
validate.R . <org/repo> <PR>
```

This script will run `hubValidations::validate_pr()` with the local pull request
and it will also print any error attributes to the console on failure when they
exist so that it's easier to determine exactly what caused the error.

## Building the Docker Container


The docker container will be built automatically on GitHub. It can also be built
locally to an image called hubvalidaitons with:

```bash
docker build --platform=linux/amd64 -t hubvalidations .
```
