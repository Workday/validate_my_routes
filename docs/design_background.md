# ValidateMyRoutes design decisions

This is a document explaining why **ValidateMyRoutes** done the way it is.

While working on service with big REST API backed on top of Sinatra we hit number of issues
related to validation of parameters and those lead to some decisions made for **ValidateMyRoutes**.

## Using Sinatra conditions for parameter validations

**ValidateMyRoutes** uses Sinatra conditions for validation

### Why?

Sinatra conditions allow to have 3-way result:

- success and proceed to the route
- fail soft and ask Sinatra to find another route that will succeed validation
- fail hard and return error to the user

Also this allows to define validations separately from the route and share validation
between different routes.

## Separate validation for single parameter and all parameters

**ValidateMyRoutes** provide conditions:

- `validate_params` - map of parameter names to their validations for a route
- `validate_all_params` - list of validations for all parameters for a route

and helper methods:

- `param_validation` - to define validation for single parameter shared across all the following routes
- `all_params_validation` - to define validation for all parameters specific for one following route

### Why?

Usually REST api includes resources with their IDs and query string/body parameters to either
select specific subset of resources or pass values for specific fields.

Resource IDs validation in most cases is the same for any route:

```http
GET /orders/:order_id
POST /orders/:order_id/approve
DELETE /orders/:order_id
```

In the example above every route that has `:order_id` parameter refers to the same resource so ID
validation will be the same. So defining such validation once and then use in every other route
make sense.

For search parameters validation can differ from route to route as you maybe want to allow cancel
all **new** orders but not ones that are **complete** already.

> **Note:** we still have to find a nice way to define query parameters validation that is shared
> across all routes and uses single parameter validation rules.
> Currently this can be achieved by adding validation into `validate_params` sinatra condition,
> but this requires knowledge on how this condition is structured.

## Separate validation rule definitions

**ValidateMyRoutes** provide separate methods to define validations:

- `def_single_param_validator` - validation rule for single parameter that always take parameter
  value and it's name
- `def_all_params_validator` - validation rule for all parameters that takes only single VALUE
  that represents parameters hash
- `def_validation_rule` - agnostic of parameters and passes arguments into `validate` block as is,
  can be used to validate single or all parameters and it is up to the rule validation block to
  deal with different input for single or all parameters validation.

### Why?

Trying to deal with possible different inputs in the validation rule flow control is very complex
and can easily get broken. But if we have separated types of rules, then rule flow control need
only to check if current rule is compatible with input that need to be validated.

On the other side if validation rule is agnostic to the input (like `anything` validation rule),
defining different rules for it is not good, so the third option is needed.

This adds flexibility to the framework for operating and validating rules for different input.
