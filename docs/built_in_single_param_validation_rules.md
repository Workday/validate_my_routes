# ValidateMyRoutes built-in validation rules for single parameter validation

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
param_validation :my_param, anything

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{anything.description}"
end
```

* can be used for all parameters validation
* can be used for single parameter validation
* with parameter set to something
  * returns rule description `anything` in body
  * succeeds validation

## Validation rule `from_enum`

```ruby
param_validation :my_param, from_enum(%w(foo bar))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{from_enum(%w(foo bar)).description}"
end
```

* can not be used for all parameters validation
* can be used for single parameter validation
* returns rule description `of enum type with values: foo, bar` in body
* with parameter set to foo
  * succeeds validation
* with parameter set to bar
  * succeeds validation
* with parameter set to something else
  * fails validation
  * returns 404 Not Found
  * returns `parameter <my_param> was expected to have one of following values: <foo, bar>, but was <foobar>` in body

## Validation rules for comparison

### Validation rule `eql`

```ruby
param_validation :my_param, eql('foo')

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{eql('foo').description}"
end
```

* can not be used for all parameters validation
* can be used for single parameter validation
* returns rule description `equal to <foo>` in body
* with parameter set to `foo`
  * succeeds validation
* with parameter set to `bar`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to equal <foo>, but was <bar>` in body

### Validation rule `greater_than`

```ruby
param_validation :my_param, value_as(Integer, greater_than(5))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{value_as(Integer, greater_than(5)).description}"
end
```

* can not be used for all parameters validation
* can be used for single parameter validation
* returns rule description `greater than <5>` in body
* with parameter set to `10`
  * succeeds validation
* with parameter set to `5`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be greater than <5>, but was <5>` in body
* with parameter set to `2`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be greater than <5>, but was <2>` in body

### Validation rule `greater_than_or_equal_to`

```ruby
param_validation :my_param, value_as(Integer, greater_than_or_equal_to(5))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{value_as(Integer, greater_than_or_equal_to(5)).description}"
end
```

* can not be used for all parameters validation
* can be used for single parameter validation
* returns rule description `greater than or equal to <5>` in body
* with parameter set to `10`
  * succeeds validation
* with parameter set to `5`
  * succeeds validation
* with parameter set to `2`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be greater than or equal to <5>, but was <2>` in body

### Validation rule `less_than`

```ruby
param_validation :my_param, value_as(Integer, less_than(5))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{value_as(Integer, less_than(5)).description}"
end
```

* can not be used for all parameters validation
* can be used for single parameter validation
* returns rule description `less than <5>` in body
* with parameter set to `2`
  * succeeds validation
* with parameter set to `5`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be less than <5>, but was <5>` in body
* with parameter set to `10`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be less than <5>, but was <10>` in body

### Validation rule `less_than_or_equal_to`

```ruby
param_validation :my_param, value_as(Integer, less_than_or_equal_to(5))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{value_as(Integer, less_than_or_equal_to(5)).description}"
end
```

* can not be used for all parameters validation
* can be used for single parameter validation
* returns rule description `less than or equal to <5>` in body
* with parameter set to `2`
  * succeeds validation
* with parameter set to `5`
  * succeeds validation
* with parameter set to `10`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be less than or equal to <5>, but was <10>` in body

### Validation rule `between`

```ruby
param_validation :my_param, value_as(Integer, between(5, 10))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{value_as(Integer, between(5, 10)).description}"
end
```

* can not be used for all parameters validation
* can be used for single parameter validation
* returns rule description `between <5> and <10>` in body
* with parameter set to `5`
  * succeeds validation
* with parameter set to `7`
  * succeeds validation
* with parameter set to `10`
  * succeeds validation
* with parameter set to `2`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be between <5> and <10>, but was <2>` in body
* with parameter set to `15`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be between <5> and <10>, but was <15>` in body


## Validation rule `of_type`

### for type `String` _(similar to anything as any object can be converted to String)_

```ruby
param_validation :my_param, of_type(String)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(String).description}"
end
```

* returns rule description `of a type <String>` in body
* with parameter set to `foo`
  * succeeds validation
* with parameter set to `15`
  * succeeds validation

### for type `Integer`

```ruby
param_validation :my_param, of_type(Integer)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(Integer).description}"
end
```

* returns rule description `of a type <Integer>` in body
* with parameter set to `15`
  * succeeds validation
* with parameter set to `foo`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Integer>, but was <foo>` in body
* with parameter set to `15.3`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Integer>, but was <15.3>` in body

### for type `Float`

```ruby
param_validation :my_param, of_type(Float)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(Float).description}"
end
```

* returns rule description `of a type <Float>` in body
* with parameter set to `15.3`
  * succeeds validation
* with parameter set to `15`
  * succeeds validation
* with parameter set to `foo`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Float>, but was <foo>` in body

### for type `Date`

```ruby
param_validation :my_param, of_type(Date)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(Date).description}"
end
```

* returns rule description `of a type <Date>` in body
* with parameter set to `2017-07-26`
  * succeeds validation
* with parameter set to `foo`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Date>, but was <foo>` in body

### for type `Time`

```ruby
param_validation :my_param, of_type(Time)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(Time).description}"
end
```

* returns rule description `of a type <Time>` in body
* with parameter set to `22:34:33`
  * succeeds validation
* with parameter set to `foo`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Time>, but was <foo>` in body

### for type `DateTime`

```ruby
param_validation :my_param, of_type(DateTime)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(DateTime).description}"
end
```

* returns rule description `of a type <DateTime>` in body
* with parameter set to `2017-07-27 22:34:33`
  * succeeds validation
* with parameter set to `foo`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <DateTime>, but was <foo>` in body

### for type `Array`

```ruby
param_validation :my_param, of_type(Array)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(Array).description}"
end
```

* returns rule description `of a type <Array>` in body
* with parameter set to `1,2,3`
  * succeeds validation

### for type `Hash`

```ruby
param_validation :my_param, of_type(Hash)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(Hash).description}"
end
```

* returns rule description `of a type <Hash>` in body
* with parameter set to `a:A,b:B,c:C`
  * succeeds validation
* with parameter set to `a:b,,::,`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Hash>, but was <a:b,,::,>` in body

### for type `:Boolean`

```ruby
param_validation :my_param, of_type(:Boolean)

get '/my_path/:my_param' do
  "validation succeeded for rule: #{of_type(:Boolean).description}"
end
```

* returns rule description `of a type <Boolean>` in body
* with parameter set to `true`
  * succeeds validation
* with parameter set to `false`
  * succeeds validation
* with parameter set to `TrUe`
  * succeeds validation
* with parameter set to `FAlsE`
  * succeeds validation
* with parameter set to `1`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Boolean>, but was <1>` in body
* with parameter set to `0`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Boolean>, but was <0>` in body
* with parameter set to `y`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Boolean>, but was <y>` in body
* with parameter set to `n`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Boolean>, but was <n>` in body
* with parameter set to `foo`
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Boolean>, but was <foo>` in body



