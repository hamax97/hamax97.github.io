# The Asset Pipeline

This is a summary of what the Asset Pipeline is and its important features.

<!-- TOC -->

- [What is it?](#what-is-it)
    - [Features](#features)
    - [Fingerprinting](#fingerprinting)
- [Recommended approaches to the Asset Pipeline](#recommended-approaches-to-the-asset-pipeline)
    - [To avoid node/yarn - The default in Rails 7](#to-avoid-nodeyarn---the-default-in-rails-7)
    - [For building complex assets](#for-building-complex-assets)
- [How to setup?](#how-to-setup)
- [Resources](#resources)

<!-- /TOC -->

## What is it?

- A framework to concatenate/compress/pre-process JavaScript and CSS.
- Adds the ability to write your assets in other languages and pre-processors, such as: CoffeeScript,
  Sass, and ERB.
- Allows you to combine the assets in your application with assets from other gems.

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

The way Sprockets does this is by adding a hash of the contents at the end of the file:

```
global-908e25f4bf641868d8683022a5b62f54.css
```

## Recommended approaches to the Asset Pipeline

### To avoid node/yarn - The default in Rails 7

The default in Rails 7 is **importmaps** and **Sprockets**.

**Propshaft** will replace Sprockets in a future release, Rails 8.

Importmaps introduces a new way of handling JavaScript assets:

- Avoids the need for tooling such as `node/yarn`.
- If not deployed in an HTTP/2 environment, you'll have big performance issues. This due to the fact
  that importmaps will not concatenate your JavaScript modules into one main JavaScript file. This way,
  only the modules that change will be requested by the browser, instead of requesting the entire JavaScript
  code for any change.
- It does NOT have a way to handle CSS assets. You can use Sprockets for that.
- It does NOT have a way to transpile JavaScript code, for instance, you won't be able to use React.

Gems needed:

- importmap-rails.
- sprockets-rails.

### For building complex assets

If you have custom requirements with your assets you can use the **bundling gems**, with your bundler
of choice, and **Sprockets**. `esbuild` is a good bundler option.

The bundling gems are:
- jsbundling-rails.
- cssbundling-rails.
- ...

These bundling gems are basically wrappers around `yarn`.

## How to setup?

To start a new application that uses Bootstrap it's suggested to go with bundling gems, your bundler of
choice, and Sprockets.

Steps:

1. Install dependencies:

   - NodeJS:

     ```bash
     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
     # log out then login to your terminal
     nvm install --lts
     ```

   - Yarn:

     ```bash
     # corepack comes with NodeJS >= 16.10
     corepack enable
     yarn --version
     ```

2. Create gemset and install Rails:

   ```bash
   rvm 3.2.2@bootstrap-project --create
   mkdir bootstrap-project && cd bootstrap-project
   rvm --ruby-version use 3.2.2@bootstrap-project
   ```

3. Create the application:

   ```bash
   gem install rails
   rails new . --javascript=esbuild --css=bootstrap
   ```

   - This will install the bundling gems for you together with the bundler `esbuild`.

4. Start the application with `bin/dev`. It will run the rails server together with two processes of yarn:
   one process will watch for JavaScript changes, the other one will watch for CSS changes:

   ```bash
   bin/dev
   ```

   - If you see the issue `exec: .../ruby: not found`, install `foreman` again. When the `rails new`
     command installs `foreman`, it prepends the installed script with a binstub that will look for
     Ruby in that same directory where `foreman` was installed causing a not found issue.
     Reinstall `foreman` using:

     ```bash
     gem install foreman
     ```

     Now the binstup is gone. Is this a bug of RVM or the RubyInstaller?

5. Make sure Bootstrap is working:

   - Create a new controller.
   - In one of its views add a navigation bar and check if the dropdown works. Copy it from
     [Bootstrap's docs](https://getbootstrap.com/docs/5.2/components/navbar/).

## Resources

- [The Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html)
- [Draft guide to Rails 7 and the Asset Pipeline](https://discuss.rubyonrails.org/t/guide-to-rails-7-and-the-asset-pipeline/80851)
- [By DHH, Modern web apps without JavaScript bundling or transpiling](https://world.hey.com/dhh/modern-web-apps-without-javascript-bundling-or-transpiling-a20f2755)