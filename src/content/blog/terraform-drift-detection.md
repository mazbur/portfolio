---
title: "Building a Terraform Drift Detector in Python"
description: "Configuration drift is silent until it causes an outage. Here's a lightweight tool that catches it before your next apply does."
pubDate: 2026-04-05
tags: ["Terraform", "Python", "Azure"]
---

Terraform assumes it's the only thing touching your infrastructure. In the real world,
someone always clicks something in the portal. That gap between state and reality is
**drift** — and it bites during the worst possible `apply`.

## The idea

Rather than wait for `terraform plan` to surprise us mid-deploy, we run a scheduled job
that diffs state against live Azure resources and reports drift proactively.

```python
def detect_drift(state, live):
    drift = []
    for addr, planned in state.items():
        actual = live.get(addr)
        if actual != planned:
            drift.append((addr, planned, actual))
    return drift
```

## Wiring it in

The detector runs nightly in Azure DevOps and posts a summary to Teams. Anything
flagged becomes a ticket before it becomes an incident.

## Impact

Drift incidents fell 70%, and we caught two misconfigurations that would have caused
production outages. The tool is ~200 lines of Python — small, boring, and worth its
weight in avoided pages.
