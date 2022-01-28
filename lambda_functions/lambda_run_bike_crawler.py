import logging
import os
import time

import boto3

logger = logging.getLogger()
client = boto3.client("glue")
crawler = os.getenv('bike_crawler')
timeout_sec = int(os.getenv('timeout_sec'))
duration_wait_time = int(os.getenv('duration_wait_time'))


def run_crawler(crawler, timeout_seconds):
    start_time = time.perf_counter()
    abort_time = start_time + timeout_seconds
    
    def wait_until_ready(crawler):
        state_previous = None
        while True:
            response_get = client.get_crawler(Name=crawler)
            current_state = response_get["Crawler"]["State"]
            if current_state != state_previous:
                print(f"Crawler {crawler} is {current_state}.")
                state_previous = current_state
            if current_state == "READY":
                return
            if time.perf_counter() > abort_time:
                raise TimeoutError(
                    f"Timeout was reached: {timeout_seconds}.")
            time.sleep(duration_wait_time)

    print("{} crawler started".format(crawler))
    response_start = client.start_crawler(Name=crawler)
    print("Crawling {}.".format(crawler))
    wait_until_ready(crawler)
    print("{} crawler finished".format(crawler))


def lambda_handler(event, context):
    run_crawler(crawler, timeout_sec)
    return True
