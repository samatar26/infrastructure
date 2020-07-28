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

Note - When starting a new service/project you'd most likely want to push your container to GCR and in order to do this, it's probably wise to create a SA specifically for that purpose.
The role `storage.objectViewer` seems to be sufficient.

Question - Is it necessary to create an entire project for the container registry? Answer: The reason for this in our previous project was because of a separation of concerns.

Here's a list of built-in environment variables: https://circleci.com/docs/2.0/env-vars/#built-in-environment-variables

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

Note - There's a list of canonical apis that should be turned on for the project. It looks like all the services are turned off by default once you create a project through terraform. The essential ones are:

- cloudresourcemanager.googleapis.com
- cloudbilling.googleapis.com
- iam.googleapis.com

If you forget to do this during the bootstrapping process, you can either enable the required API with gcloud, or create a new SA and enable the required APIs.

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

## Meta commands

`count` is useful to create multiple copies of a resource, and you have access to `count.index`, which is useful to differentiate unique fields.

### Google container registry

In order to push images to GCR, there's several steps required:

- You need to enable the container registry api: `containerregistry.googleapis.com`
- You need have permission to push and pull from the registry:
  - For push permissions (read and write) you need a role of `storage.admin`.
  - For pull permissions (read only) you need a role of `storage.objectViewer`.
- Configure docker to use gcloud as a credential helper, this is as simple as running: `gcloud auth configure-docker`. This results in the following settings being added to your Docker config file:

```json
{
  "credHelpers": {
    "gcr.io": "gcloud",
    "us.gcr.io": "gcloud",
    "eu.gcr.io": "gcloud",
    "asia.gcr.io": "gcloud",
    "staging-k8s.gcr.io": "gcloud",
    "marketplace.gcr.io": "gcloud"
  }
}
```

Which looks like it's saying if you push to X hostname, use the following tool/SDK.

You will also have to tag the image with the registry name: `HOSTNAME/PROJECT-ID/IMAGE`
And then all you need to do is: `docker push [TAGGED-IMAGE]`

For more info, see: https://cloud.google.com/container-registry/docs/pushing-and-pulling

### Gcloud auth

`gcloud auth` is used to authorize access to Google Cloud platform. So far I've used:

- gcloud auth login - Authorizes gcloud to access GCP with my google user credentials
- gcloud auth activate-service-account - Authorize access to GCP with a service account. Useful for any CI/CD pipeline, i.e. pulling and pushing an image from GCR.

# HTTPS

An internet connection can be tapped just like a telephone line. Anyone else can _eavesdrop_ on your connection if they've got the right hard- and software, i.e. overhearing your conversation with the server.

With HTTPS, the server holds a private key on the server and sends you a box along with a public key that can be used to lock the box the client is sending.
The client's data is stored inside this "box" along with the client's key to open their data. Only the server can open the original box using their **private key** stored on the server.
One key note to takeaway is that this only happens once, so after the initial which I guess is referred to as the handshake, no keys need to be sent across the connection anymore, since the server has got the client's key to open their box!

Amazing explanation on the topic: https://www.youtube.com/watch?v=w0QbnxKRD0w

Now to find out - what is this box? Aaah is it encrypted data?

HTTPS also _impacts seo_ and _prevents you from using many new features, such as SW_.

Note - look into DNS

Note - Using GCS directly via CNAME redirects only allows HTTP traffic

## Kubernetes

Notes following Kubernetes the hard way

- Kubernetes requires a set of machines to host the Kubernetes control plane and the worker nodes (where the containers are ultimately run).
- The Kubernetes networking model assumes a flat network in which each container and node can communicate with eachother. **Where this is not required you can set _network policies_**.

### Setting up the network

Google cloud provides a **Virtual Private Cloud** network and it's literally a _virtual_ version of a physical network.

See `network.tf` for how we've set up the network to host our Kubernetes cluster.

Port 22 is widely used for SSH.

Kubernetes default api server port is on 6443.

0.0.0.0/0 represents all poosible IP addresses, hence why it's used for the source range in our firewall rule allowing external communication with the Kubernetes api/cluster.

- Note - Subnets? - A smaller network inside a large network.

### Questions I should try and answer:

#### Terraform

When adding a provider, why does it have to be in two separate steps?:

```
provider "google" {
  alias = "seed"
}

provider "google" {
  project = google_project.samatar_dev.project_id
}
```

Does it matter that I did it after creating the project?
