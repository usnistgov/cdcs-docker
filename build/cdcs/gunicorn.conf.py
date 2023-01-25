from multiprocessing import cpu_count
from os import getenv

bind = "0.0.0.0:8000"
worker_class = "gthread"
workers = getenv("PROCESSES", cpu_count() * 2 + 1)
threads = getenv("THREADS", 8)
