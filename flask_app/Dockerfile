FROM python:3.10-alpine3.17
#Chosen for its light weight

WORKDIR /python-docker

COPY requirements.txt requirements.txt 
RUN pip3 install -r requirements.txt

COPY app.py app.py

EXPOSE 5000

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]