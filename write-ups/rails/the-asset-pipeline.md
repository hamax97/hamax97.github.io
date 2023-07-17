# The Asset Pipeline

This is a summary of what the Asset Pipeline is and its important features.

<!-- TOC -->

- [What is it?](#what-is-it)
    - [Features](#features)
    - [Fingerprinting](#fingerprinting)
- [Different options available](#different-options-available)
- [How to use?](#how-to-use)

<!-- /TOC -->

## What is it?

- A framework to concatenate/compress/pre-process JavaScript and CSS.
- Adds the ability to write your assets in other languages and pre-processors, such as: CoffeeScript,
  Sass, and ERB.
- Allows you to combine the assets in your application with assets from other gems.
- *Prior Rails 7*, implemented by the `sprockets-rails` gem.

> From Rails 7 and forwards, the default is `importmap-rails`.
> - Avoids the need for tooling such as `node/yarn`.
> - If not deployed in an HTTP/2 environment, you'll have big performance issues.

### Features

- Concatenation of assets:
  - All JavaScript into one master `.js` file.
  - All CSS into one master `.css` file.

- Compression of assets for JavaScript and CSS.

- You can code your assets in other higher-level languages: Sass for CSS, CoffeeScript for JavaScript, and
  ERB for both.

### Fingerprinting

Fingerprinting is a technique that makes the name of a file dependent on the contents of the file.
When the file contents change, the filename is also changed.

This enables a technique called **cache busting**. Read my write-up on
[how Rails implements cache busting](http-response-lifecycle.md#for-static-content---cache-busting).

You can enable or disable fingerprinting with the config option `config.assets.digest`.

## Different options available

TODOs:

- Finish reading here: https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851
- Understand how esbuild (jsbundling) realtes to the asset pipeline.
- Understand how bootstrap is included in Rails (why prefer esbuild over importmap for this?)

## How to use?