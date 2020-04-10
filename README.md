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
For more detail look into the checkout step of the job, it looks like a bash script which clones the repo into the working_directory and checks out the corresponding branch/commit.

When you don't specify a workflow, circleci will only look for a job called build which will be the default entry point for a run triggered by a push. You can specify additional jobs and run them using the CircleCI api.

When using workflows, you can specify an order of jobs (| -> | -> |) by using requires:

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

If a job requires manual approval from a developer you can add a type of of approval to a purely review job in the workflow. Because the approval type job doesn't actually correspond to the jobs specified in the jobs section:

```yml
workflows:
  version: 2
  build_plan:
    jobs:
      - plan
      - review_plan:
          type: approval
          requires:
            - build
      - apply:
          requires:
            - build
```

`persist_to_workspace` is handy for persisting a temporary file(s) to be used by another job in the workflow.

It's used in conjuction with `attach_workspace` in the required job.

Note - You probably want to persist after you run your (build) commands and generate the files you need in your subsequent job!

## Terraform

A backend in terraform is the representation of your state (terraform.tfstate). So it's a good idea to store your state file somewhere where it can persist, so that your state doesn't get created from scratch every time you run your ci/cd pipeline!
When using the `gcs` backend it's highly recommended to turn object versioning (support for retrieval of objects that are deleted/overwritten) on to allow for state recovery in case of accidental deletion/human error.

Terraform has a list of supported backends here: https://www.terraform.io/docs/backends/types/index.html.

You can configure your backend using the `terraform` section:

```terraform
terraform {
  backend "backend_type" {

  }
}
```

🥚 vs 🐔 problem - How to create the infrastructure for the remote Terraform backend with Terraform?

First you run terraform init and plan with **only** the project and bucket creation.

Then you reinitialize terraform with the remote backend, which will prompt you to copy the existing state to the remote and voila you have the current state containing project an all in your gcs bucket!

Once you've done this, it's probably best to create a service account specifically for terraform, see `(iam.tf)`. I've given it a role of owner for now, but will have to look into whether it can have more granular permissions. In order to retrieve the account's authorisation keys, you can run:

```bash
gcloud iam service-accounts keys create [file-name].json --iam-account [service-account-email]
```

You can then save the contents of the credentials.json in any automation pipeline!

### Common Terraform commands:

#### Terraform init

Terraform init is used to initialize a working directory containing `.tf` files.
It's the first command you should run after writing a new Terraform configuration or cloning one. It's also safe to run multiple times.

During init, the root configuation directory is consulted for backed configuration and the chosen backend is initialized.

#### Terraform plan

Terraform plan is used to create an execution plan (to update the current state based on the changes in your configuration).
It's also really nice to see whether the changes you're about to make match you expectations without making any changes to real resources or to the state.

The `-out` argument can be used to save the generated plan for later execution, super useful in automation (i.e. circleci) as I guess you'd want to separate your plan and apply step.

## Google cloud platform

You need to enable billing before you can create a bucket and probably much more. :sweat_smile:

![roll_thase](https://user-images.githubusercontent.com/22747985/78833336-9b1b8d80-79e4-11ea-9025-a44a2a6a558b.png)

Even though I want do everything with terraform,
it seems like even in the terraform docs for the google provider, that before you begin, you should create a project and add a billing account.

When trying to create a bucket to store my terraform state file, I got a 409 error from googlapi. It looks like GCS bucket names are globablly unique and they are publicly visible. See naming best practices: https://cloud.google.com/storage/docs/best-practices#naming. Luckily my name is pretty unique :smile:.

Another thing about buckets is that even though the project field is optional, it will try and find the project_id from the provider.
So it looks like it's best to set the project_id on that level as other resources may need it too.
