# ValidateMyRoutes custom validation

```ruby
# Register ValidateMyRoutes Sinatra extension
register ValidateMyRoutes::Validatable

# Add validation rules on class level
extend ValidateMyRoutes::ValidationRules

# Add validation rules on instance level (for in-line validation)
include ValidateMyRoutes::ValidationRules
```

## In-line validation

```ruby
post '/my_path' do
  body = request.body.read

  ValidateMyRoutes::Validate.validate!(self, of_type(Integer), body, false, 'body') do |msg|
    halt 401, "not authorised because #{msg}"
  end

  'OK!'
end
```

* with valid data
  * succeeds validation
* with invalid data
  * fails validation
  * returns 401 Unauthorized (as specified in route code)
  * returns `not authorised because was expected body parameter to be of a type <Integer>, but was <foo>` in body

## Conditional validation

```ruby
param_validation :my_param, conditional(eql('foo'))
get '/my_path/:my_param' do |_|
  "validation succeeded for rule: #{conditional(eql('foo')).description}"
end

param_validation :my_param, anything
get '/my_path/:my_param' do |_|
  "another path choosen after conditional validation failed"
end
```

* with my_param set to "foo"
  * succeeds validation
  * returns rule description `conditional, equal to <foo>` in body
* with parameter set to "bar"
  * succeeds validation
  * returns text from second route

## URL vs QUERY STRING parameters

```ruby
param_validation :path_parameter, eql('foo')

all_params_validation required(:query_parameter)
get '/my_path/:path_parameter' do
  'OK!'
end
```

* when path and query string parameters are invalid
  * fails validation
  * returns 404 Not Found
  * returns `was expected path_parameter parameter to equal <foo>, but was <bar>` in body
* when path parameter is valid but query string parameters is invalid
  * fails validation
  * returns 400 Bad Request
  * returns `parameter <query_parameter> was expected to be present` in body
* with both parameters valid
  * succeeds validation

## custom validation

### for single parameter validation

#### with only required declaration used

```ruby
def_single_param_validator :custom_eql do |expected|
  validate { |actual, name| actual == expected }
end

param_validation :my_param, custom_eql('foo')

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{custom_eql('foo').description}"
end
```

* returns rule description `Custom eql` in body
* with invalid data used
  * fails validation
  * returns 404 Not Found
  * returns `parameter my_param was expected to satisfy: Custom eql but was <bar>` in body
##### when used as negated rule

```ruby
param_validation :my_param_2, custom_eql('foo').negate

get '/my_path_2/:my_param_2' do |my_param_2|
  "validation succeeded for rule: #{custom_eql('foo').negate.description}"
end
```

* returns rule description `NOT Custom eql` in body
* with invalid data used
  * fails validation
  * returns 404 Not Found
  * returns `parameter my_param_2 was expected not to satisfy: Custom eql but was <foo>` in body


#### with everything overriden

```ruby
def_single_param_validator :custom_eql_with_overrides do |expected|
  validate do |actual, name|
    actual == expected
  end

  description do
    "custom description with expected #{expected}"
  end

  failure_message do |actual, name|
    "custom failure for #{name} with expected #{expected} and actual #{actual}"
  end

  failure_message_when_negated do |actual, name|
    "custom negated failure for #{name} with expected #{expected} and actual #{actual}"
  end

  failure_code do |parameter_is_in_path|
    parameter_is_in_path ? 401 : 409
  end
end

param_validation :my_param, custom_eql_with_overrides('foo')

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{custom_eql_with_overrides('foo').description}"
end
```

* returns rule description `custom description with expected foo` in body
* with invalid data used
  * fails validation
  * returns 401 Our custom defined code
  * returns `custom failure for my_param with expected foo and actual bar` in body
##### when used as negated rule

```ruby
param_validation :my_param_2, custom_eql_with_overrides('foo').negate

get '/my_path_2/:my_param_2' do |my_param_2|
  rule = custom_eql_with_overrides('foo').negate
  "validation succeeded for rule: #{rule.description}"
end
```

* returns rule description `NOT custom description with expected foo` in body
* with invalid data used
  * fails validation
  * returns 401 Our custom defined code
  * returns `custom negated failure for my_param_2 with expected foo and actual foo` in body



### for all parameters validation

#### with only required declaration used

```ruby
def_all_params_validator :custom_required do |expected|
  validate { |params| params.key? expected }
end

all_params_validation custom_required('my_param')

get '/my_path' do
  "validation succeeded for rule: #{custom_required('my_param').description}"
end
```

* returns rule description `Custom required` in body
* with invalid data used
  * fails validation
  * returns 400 Bad Request
  * returns `parameters were expected to satisfy: Custom required but were <{"not_my_param"=>nil}>` in body
##### when used as negated rule

```ruby
all_params_validation custom_required('my_param_2').negate
get '/my_path_2' do
  rule = custom_required('my_param_2').negate
  "validation succeeded for rule: #{rule.description}"
end
```

* returns rule description `NOT Custom required` in body
* with invalid data used
  * fails validation
  * returns 400 Bad Request
  * returns `parameters were expected not to satisfy: Custom required but were <{"my_param_2"=>nil}>` in body


#### with everything overriden

```ruby
def_all_params_validator :custom_required_with_overrides do |expected|
  validate do |params|
    params.key? expected
  end

  description do
    "custom description with expected #{expected}"
  end

  failure_message do |params|
    "custom failure for expected #{expected} and params #{params}"
  end

  failure_message_when_negated do |params|
    "custom negated failure for expected #{expected} and params #{params}"
  end

  failure_code do |parameter_is_in_path|
    parameter_is_in_path ? 401 : 409
  end
end

all_params_validation custom_required_with_overrides('my_param')
get '/my_path' do
  rule = custom_required_with_overrides('my_param')
  "validation succeeded for rule: #{rule.description}"
end
```

* returns rule description `custom description with expected my_param` in body
* with invalid data used
  * fails validation
  * returns 409 Our custom defined code
  * returns `custom failure for expected my_param and params {"not_my_param"=>nil}` in body
##### when used as negated rule

```ruby
all_params_validation custom_required_with_overrides('my_param_2').negate

get '/my_path_2' do
  rule = custom_required_with_overrides('my_param_2').negate
  "validation succeeded for rule: #{rule.description}"
end
```

* returns rule description `NOT custom description with expected my_param_2` in body
* with invalid data used
  * fails validation
  * returns 409 Our custom defined code
  * returns `custom negated failure for expected my_param_2 and params {"my_param_2"=>nil}` in body



### with using built-in validation rules inside custom validation rule

```ruby
def_single_param_validator :with_build_in_eql_to do |expected|
  validate do |actual, name|
    check(ValidateMyRoutes::ValidationRules.eql(expected), actual, name)
  end
end

param_validation :my_param, with_build_in_eql_to('foo')
get '/my_path/:my_param' do
  "validation succeeded for rule: #{with_build_in_eql_to('foo').description}"
end
```

* returns rule description `With build in eql to` in body
* with valid data passed in
  * succeeds validation
* with invalid data passed in
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to equal <foo>, but was <bar>` in body

### can access application scope

```ruby
def services
  'my services'
end

def_all_params_validator :can_access_app_scope do
  validate { |_| services == 'my services' }
end

all_params_validation can_access_app_scope
get '/my_path' do
  'OK!'
end
```

* succeeds validation



