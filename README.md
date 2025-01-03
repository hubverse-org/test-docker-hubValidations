# hubValidations in a tin

This packages hubValidations in a docker container so they can be run without
requiring R to be installed on a machine.

The main motivation for this image is to simplify the validation process for
our workflows.

## Using the Image

To validate a Pull Request locally, you can use this image like so: 

```bash
docker run \
--platform=linux/amd64 \
--rm \
-it \
-v "/path/to/hub":"/project" \
ghcr.io/hubverse-org/test-docker-hubValidations:main \
validate.R . <org/repo> <PR>
```

## Building the Docker Container


The docker container will be built automatically on GitHub. It can also be built
locally to an image called hubvalidaitons with:

```bash
docker build --platform=linux/amd64 -t hubvalidations .
```
