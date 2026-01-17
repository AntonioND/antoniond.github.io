# SkyLyrac website

This website is built with [Hugo](https://gohugo.io).

## Prerequisites

- **Hugo**

  Follow the [installation guide](https://gohugo.io/categories/installation/).
  You need the extended version of Hugo.

- **hugo-theme-stack**

  Download the theme by cloning the repository in `themes`:

  ```bash
  cd themes
  git clone https://github.com/CaiJimmy/hugo-theme-stack
  ```

## Testing the website locally

If you have made some change to the documentation and want to check the output
locally, simply run the following command from the root of the repository:

```bash
hugo server
```

That command will print a URL that you can open from a browser to see the
results.

You can also run the following command to only generate the static website
without a web server:

```bash
hugo
```

## Deploying the website

The script `build.sh` downloads the theme and builds the website. Note that
this sets the base URL of the documentation to `https://skylyrac.net/`, so
this script is only useful to deploy the website.
