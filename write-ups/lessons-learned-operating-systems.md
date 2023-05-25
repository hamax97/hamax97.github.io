# Operating Systems lessons learned

<!-- TOC -->

- [How to calculate memory usage in Unix servers](#how-to-calculate-memory-usage-in-unix-servers)
    - [node_exporter](#node_exporter)

<!-- /TOC -->

## How to calculate memory usage in Unix servers

To calculate the percentage of memory used by a server you can use the following formula:

```
(memory used / total memory) * 100
```

Where `memory used` can be calculated as:

```
memory used = MemTotal - MemFree - Cached - SReclaimable - Buffers
```

- This is how the command `free` calculates memory used.

These values can be obtained from `/proc/meminfo`.

### node_exporter

If you are using Prometheus, `node_exporter` will get these values for you, you just have to use
the proper query:

```
((node_memory_MemTotal_bytes{instance=~"$node"} - node_memory_MemFree_bytes{instance=~"$node"} - node_memory_Buffers_bytes{instance=~"$node"} - node_memory_Cached_bytes{instance=~"$node"} - node_memory_SReclaimable_bytes{instance=~"$node"}) / node_memory_MemTotal_bytes{instance=~"$node"}) * 100
```

Replace `$node` with a regular expresion like: `hostXYZ:9100|hostABC:9100`. Grafana will do it for you.
