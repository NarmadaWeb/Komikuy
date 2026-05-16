## 2025-05-22 - [Parallelize Network Requests]
**Learning:** Sequential network requests in scrapers (like fetching page 1 then page 2) are a major bottleneck. Parallelizing them with `Future.wait` reduces wall-clock time by ~50% in multi-page fetching scenarios.
**Action:** Always look for serial `for` loops containing asynchronous I/O (HTTP requests, DB queries) and convert them to concurrent execution when order is not strictly required or can be handled after completion.
