FROM python:3.10-alpine3.17

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY requests.py requests.py

CMD [ "python3", "requests.py"]