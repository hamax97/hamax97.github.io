# Operating Systems lessons learned

<!-- TOC -->

- [How to calculate memory usage in Unix servers](#how-to-calculate-memory-usage-in-unix-servers)
    - [node_exporter](#node_exporter)
- [Performance analysis in Linux](#performance-analysis-in-linux)

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

## Performance analysis in Linux

Source: [Shaik Anwar](https://www.linkedin.com/feed/update/urn:li:activity:7091790393821855744/).

<div align="center">
    <img src="./images/linux-observability-tools.png"/>
</div>

1. `uptime`

   This is a quick way to view the load averages, which indicate the number of tasks (processes)
   wanting to run.

2. `dmesg | tail`

   This views the last 10 system messages, if there are any. Look for errors that can cause performance issues.

3. `vmstat 1`

   Short for virtual memory stat, vmstat(8) is a commonly available tool (first created for BSD decades ago).
   It prints a summary of key server statistics on each line.

4. `mpstat -P ALL 1`

   This command prints CPU time breakdowns per CPU, which can be used to check for an imbalance.
   A single hot CPU can be evidence of a single-threaded application.

5. `pidstat 1`

   Pidstat is a little like top’s per-process summary, but prints a rolling summary instead of clearing
   the screen. This can be useful for watching patterns over time, and also recording what you saw
   (copy-n-paste) into a record of your investigation.

6. `iostat -xz 1`

   This is a great tool for understanding block devices (disks), both the workload applied and the resulting performance.

7. `free -m`

8. `sar -n DEV 1`

   Check network interface throughput: rxkB/s and txkB/s, as a measure of workload, and also to check if any
   limit has been reached.

9. `sar -n TCP,ETCP 1`

   This is a summarized view of some key TCP metrics.

10. `top`

    The top command includes many of the metrics we checked earlier. It can be handy to run it to see
    if anything looks wildly different from the earlier commands, which would indicate that load is variable.
