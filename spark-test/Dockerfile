FROM godatadriven/pyspark 

RUN pip install pytest

COPY /library/python /library/python
WORKDIR /library/python

RUN pip install .

WORKDIR /

RUN rm -r library
