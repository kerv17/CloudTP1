from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
@app.route('/cluster1')
@app.route('/cluster2')
def my_app():
    return "I am instance {}".format(get_instance_id()) # Instance returns its ID

def get_instance_id(): 
    return os.environ['instanceId'] #Get the AWS instance ID

if __name__ == '__main__':
    app.run()