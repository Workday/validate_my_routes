# ValidateMyRoutes built-in validation rules for all parameters validation

```ruby
# Register ValidateMyRoutes Sinatra extension
register ValidateMyRoutes::Validatable

# Add validation rules on class level
extend ValidateMyRoutes::ValidationRules

# Add validation rules on instance level (for in-line validation)
include ValidateMyRoutes::ValidationRules
```

## Validation rule `anything`

```ruby
all_params_validation anything

get '/my_path/?' do
  "validation succeeded for rule: #{anything.description}"
end
```

* can be used for all parameters validation
* can be used for single parameter validation
* returns rule description `anything` in body
* with parameter set to something
  * succeeds validation
* with parameter not set
  * succeeds validation

## Validation rule `required`

```ruby
all_params_validation required(:my_param)

get '/my_path/?' do
  "validation succeeded for rule: #{required(:my_param).description}"
end
```

* can be used for all parameters validation
* can not be used for single parameter validation
* returns rule description `parameter <my_param> is required` in body
* with required parameter specified
  * succeeds validation
* with required parameter missing
  * fails validation
  * returns 400 Bad Request
  * returns `parameter <my_param> was expected to be present` in body

## Validation rules for parameters inclusion

### Validation rule `only_one_of`

```ruby
all_params_validation only_one_of(%i[foo bar])

get '/my_path/?' do
  "validation succeeded for rule: #{only_one_of(%i[foo bar]).description}"
end
```

* can be used for all parameters validation
* can not be used for single parameter validation
* returns rule description `only one of <foo, bar> parameters` in body
* with <foo> only provided
  * succeeds validation
* with <bar> only provided
  * succeeds validation
* with <another> only provided
  * succeeds validation
* with both parameters <foo> and <bar> provided
  * fails validation
  * returns 400 Bad Request
  * returns `was expected to have only one of <foo, bar> parameters, but <foo, bar> were provided` in body

### Validation rule `exactly_one_of`

```ruby
all_params_validation exactly_one_of(%i[foo bar])

get '/my_path/?' do
  "validation succeeded for rule: #{exactly_one_of(%i[foo bar]).description}"
end
```

* can be used for all parameters validation
* can not be used for single parameter validation
* returns rule description `exactly one of <foo, bar> parameters` in body
* with <foo> only provided
  * succeeds validation
* with <bar> only provided
  * succeeds validation
* with both parameters <foo> and <bar> provided
  * fails validation
  * returns 400 Bad Request
  * returns `was expected to have exactly one of <foo, bar> parameters, but <foo, bar> were provided` in body
* with none of specified parameters provided
  * fails validation
  * returns 400 Bad Request
  * returns `was expected to have exactly one of <foo, bar> parameters, but <another> was provided` in body

### Validation rule `at_least_one_of`

```ruby
all_params_validation at_least_one_of(%i[foo bar])

get '/my_path/?' do
  "validation succeeded for rule: #{at_least_one_of(%i[foo bar]).description}"
end
```

* can be used for all parameters validation
* can not be used for single parameter validation
* returns rule description `at least one of <foo, bar> parameters` in body
* with <foo> only provided
  * succeeds validation
* with <bar> only provided
  * succeeds validation
* with both parameters <foo> and <bar> provided
  * succeeds validation
* with none of specified parameters provided
  * fails validation
  * returns 400 Bad Request
  * returns `was expected to have at least one of <foo, bar> parameters, but <another> was provided` in body



