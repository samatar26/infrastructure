# Infrastructure repo

Infrastructure playground to currently experiment with terraform, gcp and whatever else comes up :sweat_smile:

## Circle Ci Setup

When specifying a job in the config.yml, you must specify an executor for the job, i.e. machine, docker, etc.

Each run declaration represents a new shell. To specify a multi-line command, where each line will be run in the same shell:

```yml
- run:
    command: |
      cd blah
      make blah
```

Checkout is used to checkout the project's source code into the job's working directory.
