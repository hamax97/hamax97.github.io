# Ruby on Rails lessons learned

<!-- TOC -->

- [Ruby on Rails lessons learned](#ruby-on-rails-lessons-learned)
    - [Setup application](#setup-application)
    - [Controller's actions naming](#controllers-actions-naming)
    - [Form builders and routes helpers](#form-builders-and-routes-helpers)
    - [Controller's life cycle](#controllers-life-cycle)
    - [Request params](#request-params)
    - [Rendering views](#rendering-views)
    - [Migrations helpers](#migrations-helpers)
    - [Building forms](#building-forms)
    - [How to use Active Storage for local storage](#how-to-use-active-storage-for-local-storage)
    - [How to reset db delete data and have schemas recreated](#how-to-reset-db-delete-data-and-have-schemas-recreated)
    - [Databases SQLite3 and PostgreSQL](#databases-sqlite3-and-postgresql)

<!-- /TOC -->

## Setup application

1. Setup rvm gemset first, read [here](./how-to-use-rvm.md#create-a-gemset-for-a-specific-project-or-environment):

2. Then rails:

```bash
gem install rails
rails new app-name
```

## Controller's actions naming

Never create a controller's action with a name that already exists in the Base controller.
For example:

```ruby
def process
  ...
end
```

You will get an error like: `Wrong number of arguments(given 1, expected 0)`.

## Form builders and routes helpers

- The form builder `form_with model: @some_model` requires the model to have a `post` route to `/some_model`.
  Otherwise you'll get the error `some_model_path` method not found.

- How to make the `some_model_url` helper available?

  Naming routes:

  - adding `as` as keyword argument to your route will generate helper methods for your route:

    ```ruby
    get "videos/:id", to: "videos#show", as: :video
    ```

    will generate `video_path` and `video_url` helpers.

    Docs: https://guides.rubyonrails.org/routing.html#naming-routes

## Controller's life cycle

A controller instance is created per request.

## Request params

- Rails doesn't make a distinction between query params and POST params, all go inside the `params` hash.
- Parameters in `params` are always `string`s, Rails doesn't try to cast or guess the data type.

## Rendering views

- Why is it required to instantiate the model when rendering a view (for example the `new` view)?

  - TODO.

- Rendering a view using `render` will NOT call the action associated to the view, therefore:
  - You have to define the instance variables used by the view.

- Rendering or redirecting won't stop the action, expressions after the rendering will be evaluated.
  - Whatchout, you can't `render`/`redirect` twice.

- What is record identification? https://guides.rubyonrails.org/form_helpers.html#relying-on-record-identification

## Migrations helpers

- Update schema:

  ```bash
  # Add multiple columns to table.
  bin/rails generate migration AddNameToVideosAndSizeToVideos name:string size:string
  ```

- To change a column from nullable to non-null you have to do it manually:

  - Open the migration file that corresponds to the table creation (or column addition)
  - Modify the required column by adding the keyword argument `null: false`. For example:

    ```ruby
    # from
    t.string :name

    # to
    t.string :name, null: false
    ```

- Create one-to-many association in already existing models:

  1. You'll have to create the migration code manually:

     - Create an empty migration file:

       ```bash
       bin/rails g migration AddOwnerTableFkToOwnedTable
       ```

     - Where `OwnerTable` is the table that `has_many` `OwnedTable`.
     - This will generate for you an empty migration file with the proper timestamp.

  2. Edit the `change` method and add:

     ```ruby
     add_reference :owned_table_in_plural, :owner_table, foreign_key: true, null: false
     ```

  3. Run migration:

     ```bash
     bin/rails db:migrate
     ```

  3. Edit the model files to add associations:

     ```ruby
     # Owner.rb
     class Owner < ApplicationRecord
       ...
       has_many :owned_table_in_plural, dependent: :destroy
       ...
     end

     # Owned.rb
     class Owned < ApplicationRecord
       ...
       belongs_to :owner
       ...
     end
     ```

  4. Add/delete data:

     ```ruby
     @owner = Owner.find
     @owner.owneds.create(...)
     @owner.destroy # will delete the objects it has too.
     ```

- Running `rollback` will rollback only one migration.

## Building forms

When building a form input field passing a symbol as parameter, that symbol does not have to be
defined in the model. It can be anything. Using an attribute that's in the model will be helpful
to avoid boilerplate code when extracting from `params` in the controller. Example:

```ruby
<%= form_with model: @video do |form| %>
<%= form.file_field :video_file %>
<%= form.submit %>
<% end %>
```

`video_file` doesn't have to be an attribute in `@video`.

## How to use Active Storage for local storage

1. Set up:

   ```bash
   bin/rails active_storage:install
   bin/rails db:migrate
   ```

   This will create three tables in your db: `active_storage_blobs`, `active_storage_attachments`,
   and `active_storage_variant_records`.

2. Set storage service. Edit file `config/storage.yml`:

   ```ruby
   local:
     service: Disk
     root: <%= Rails.root.join("storage") %>
   ```

3. Tell active storage which service to use. Edit `config/environment.rb`:

   ```ruby
   Rails.application.config.active_storage.service = :local
   ```

4. Attach files to records. Example:

   A `Video` record with many `Image`s records, and each `Image` with one file attached:

   Define the associations:

   ```ruby
   class Video < ApplicationRecord
     has_many :images, dependent: :destroy
   end

   class Image < ApplicationRecord
     has_one_attached :image_file # bin/rails g model Image image_file:attachment
     belongs_to :video
   end
   ```

   Create the migrations. Refer to the section on creating a foreign key in
   [migrations helpers](#migrations-helpers).

   Attach files:

   ```ruby
   @video = Video.create
   @image = @video.images.create

   # For attaching a file created in the server:
   @image.image_file.attach(
     io: File.open(file_path),
     filename: "somename.jpg",
     content_type: "image/jpeg",
    identify: false
   )

   # For attaching a file uploaded through the request:
   # Read here: https://edgeguides.rubyonrails.org/active_storage_overview.html#has-one-attached
   ```

   Delete files:

   ```ruby
   # This will delete all images and their attachments too.
   @video.destroy
   ```

Docs: https://edgeguides.rubyonrails.org/active_storage_overview.html

Example project: https://github.com/hamax97/coordinates-reader

## How to reset db (delete data and have schemas recreated)

```bash
bin/rails db:reset
```

## Databases (SQLite3 and PostgreSQL)

- SQLite3 fails with: `SQLite3::BusyException: database is locked` when using Active Storage
  to store a relatively big amount of images, for instance, about 60 images sequentially.

  - Seems like Active Storage makes two or three `SELECT`s before `INSERT`, per image, which might cause this.
  - When using PostgreSQL, this issue is fixed.

- Things to have in mind when setting up PostgreSQL:

  - Default role used? https://stackoverflow.com/questions/24038316/rails-connects-to-database-without-username-or-password
  - The option `host` must be defined if using `config/database.yml`, otherwise you won't be able to connect,
    with an error that doesn't specify that the `host` option should be set, something like:

    ```ruby
    ActiveRecord::DatabaseConnectionError: There is an issue connecting to your database with your username/password, username: <username>.

    Please check your database configuration to ensure the username/password are valid.
    ```

- Useful commands:

  ```bash
  bin/rails db:drop # delete databases for all envs
  bin/rails db:truncate_all # truncate all tables
  ```