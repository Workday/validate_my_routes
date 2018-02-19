# ValidateMyRoutes validation rules combinators

```ruby
# Register ValidateMyRoutes Sinatra extension
register ValidateMyRoutes::Validatable

# Add validation rules on class level
extend ValidateMyRoutes::ValidationRules

# Add validation rules on instance level (for in-line validation)
include ValidateMyRoutes::ValidationRules
```

## Combinator `and`

```ruby
param_validation :my_param, of_type(Integer).and(eql('5'))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{of_type(Integer).and(eql('5')).description}"
end
```

* returns rule description `(of a type <Integer> AND equal to <5>)` in body
* with parameter satisfying both validations (5)
  * succeeds validation
* with parameter failing first rule (foo)
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of a type <Integer>, but was <foo>` in body
* with parameter failing second rule (15)
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to equal <5>, but was <15>` in body

## Combinator `or`

```ruby
param_validation :my_param, eql('foo').or(eql('bar'))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{eql('foo').or(eql('bar')).description}"
end
```

* returns rule description `(equal to <foo> OR equal to <bar>)` in body
* with parameter satisfying first rule (foo)
  * succeeds validation
* with parameter satisfying second rule (bar)
  * succeeds validation
* with parameter failing both rules (another)
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to equal <bar>, but was <another>` in body

## Combinator `not`

```ruby
param_validation :my_param, eql('foo').negate

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{eql('foo').negate.description}"
end
```

* returns rule description `NOT equal to <foo>` in body
* with parameter satisfying negated rule (bar)
  * succeeds validation
* with parameter failing both rules (foo)
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to not equal <foo>, but was <foo>` in body


