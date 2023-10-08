
from requests_futures.sessions import FuturesSession
import threading
import time
import os

def thread1_requests(url, headers):
    """
    thread1_requests    is a function that sends 1000 requests to the given url asynchronously
    :url:               The url where the requests are sent (with ALB DNS name)
    :headers:           Headers sent with the requests
    """
    session = FuturesSession()
    print("thread 1")
    for _ in range(1000):
        session.get(url, headers=headers)
    print("thread 1 finished")


def thread2_requests(url, headers):
    """
    thread2_requests    is a function that sends 1500 requests to the given url asynchronously
    :url:               The url where the requests are sent (with ALB DNS name)
    :headers:           Headers sent with the requests
    """
    session = FuturesSession()
    print("thread 2")
    for _ in range(500):
        session.get(url, headers=headers)

    time.sleep(60)

    for _ in range(1000):
        session.get(url, headers=headers)
    print("thread 2 finished")
    

if __name__ == '__main__':


    # The URL is passed as an environment variable when running the script.sh. It's the ALB DNS name that is outputted from main.tf
    url = "http://" + os.environ['url']
    headers = {"content-type": "application/json"}

    requests1 = threading.Thread(target=thread1_requests, args=(url + "/cluster1", headers))
    requests2 = threading.Thread(target=thread2_requests, args=(url + "/cluster2", headers))

    # Start the requests thread
    requests1.start()
    requests2.start()

    requests1.join() # Wait for termination of requests1 thread
    requests2.join() # Wait for termination of requests2 thread