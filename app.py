from flask import Flask
import requests

app = Flask(__name__)
dns = "" #DNS of the EC2 instance

if __name__ == '__main__':
    # Set the port to 80
    app.run(host='0.0.0.0', port=80)


@app.route('/')
def my_app():
    return get_instance_id()

def get_instance_id(): #Get the AWS instance ID
    url = "http://" + dns + "/latest/meta-data/instance-id"
    r = requests.get(url)
    return r.text

