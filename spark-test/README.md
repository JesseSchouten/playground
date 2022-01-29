## Steps:

- build the image:
  docker build -t pyspark --build-arg PYTHON_VERSION=3.7.10 --build-arg IMAGE=buster .
- Run the container:
  docker run -it -v $(pwd)/library/python:/library/python -w /library/python pyspark

  The unit tests should pass.