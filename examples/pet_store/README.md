# Simple example

In this example you can see how you can use `validate_my_routes` on simple Pet store rest api
application.

Application provides REST resource `pet`:

* `GET /pet` - returns all pets stored in a pet store (searchable by status with possible values: `available`, `unavailable` and `sold`)
* `POST /pet` - creates a new pet and requires to have json pet in body with status `available`
* `GET /pet/:pet_id` - returns pet with specified integer id if it is present
* `DELETE /pet/:pet_id` - deletes pet with specified integer id if it is present

To test it simply install dependencies:

```bash
bundle install
```

And start the webserver:

```bash
bundle exec ruby app.rb
```

After you can test your application by sending http requests to `http://localhost:8080/`.

There are some examples of http requests in `tests.http` file.
