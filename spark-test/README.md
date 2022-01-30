## Steps:

- build the image:
  docker build -t pyspark --build-arg PYTHON_VERSION=3.7.10 --build-arg IMAGE=buster .
- Run the container:
  docker run -it -v $(pwd)/library/python:/library/python -w /library/python --entrypoint=pytest pyspark

  Alternatively: docker-compose up

  The unit tests should pass. You can also develop the module and test just running the second command, as long as the dependencies don't change. Rebuild the image when new dependencies are added to the library.
