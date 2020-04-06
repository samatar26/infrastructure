# Infrastructure repo

Infrastructure playground to currently experiment with terraform, gcp and whatever else comes up :sweat_smile:

## Circle Ci Setup

When specifying a job in the config.yml, you must specify an executor for the job, i.e. machine, docker, etc.

Each run declaration represents a new shell. To specify a multi-line command, where each line will be run in the same shell:

```yml
steps:
  - checkout
  - run:
      command: |
        cd blah
        make blah
```

Checkout is used to checkout the project's source code into the job's working directory. The default working directory is `~/project`.
For more detail look into the checkout step of the job, it looks like a bash script which clones the repo and checks out the corresponding branch/commit.

When you don't specify a workflow, circleci will only look for a job called build which will be the default entry point for a run triggered by a push. You can specify additional jobs and run them using the CircleCI api.

When using workflows, you can specify an order of jobs by using requires:

```yml
workflows:
  version: 2
  build_plan:
    jobs:
      - build
      - plan:
          requires:
            - build
```

## Terraform

A backend in terraform is the representation of your state (terraform.tfstate). So it's a good idea to store your state file somewhere where it can persist.
When using the `gcs` backend it's highly recommended to turn object versioning (support for retrieval of objects that are deleted/overwritten) on to allow for state recovery in case of accidental deletion/human error.

Terraform has a list of supported backends here: https://www.terraform.io/docs/backends/types/index.html.

You can configure your backend using the `terraform` section:

```terraform
terraform {
  backend "backend_type" {

  }
}
```
