---
title : "Monitoring"
weight : 140
---

Now that we sent few samples requests in the previous chapter, let us visualize using Grafana and AWS CloudWatch that we setup previously.

Let us send some more requests , which will help us visualize the data.

#### Generate Load

Below command will generate load at /bar endpoint for 10 minutes

```bash
siege -t 600S -c 255 -i $DATA_PLANE_LB/bar
```

Let this load keep getting generated and you can move on to the next module and start visualizing data.