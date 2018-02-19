# ValidateMyRoutes transformation rules

```ruby
# Register ValidateMyRoutes Sinatra extension
register ValidateMyRoutes::Validatable

# Add validation rules on class level
extend ValidateMyRoutes::ValidationRules

# Add validation rules on instance level (for in-line validation)
include ValidateMyRoutes::ValidationRules
```

## Transformation `value_as`

```ruby
param_validation :my_param, value_as(Integer, greater_than(5))

get '/my_path/:my_param' do |my_param|
  "validation succeeded for rule: #{value_as(Integer, greater_than(5)).description}"
end
```

* returns rule description `greater than <5>` in body
* with parameter with correct type and transformed value satisfying the rule
  * succeeds validation
* with parameter with a wrong type (foo)
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be of type <Integer>, but was <foo>` in body
* with parameter with correct type but transformed value failing the rule (2)
  * fails validation
  * returns 404 Not Found
  * returns `was expected my_param parameter to be greater than <5>, but was <2>` in body

## Transformation `transform`

### for a single parameter validation

```ruby
class Order
  def initialize(order_type)
    @order_type = order_type
  end
end

module OrderTypesFactory
  def self.load_order(order_type)
    # load order configurations from config or database
    # in our case it is simplified to return a Hash if order type is valied
    fail 'order type "bar" is unsupported!' if order_type == 'bar'
    Order.new(order_type) if ['buy_a_pet'].include? order_type
  end
end

def_single_param_validator :order_validator do
  validate { |order, _| order.is_a? Order }
end

to_order = ->(order_type) { OrderTypesFactory.load_order(order_type) }
param_validation :order_type, transform(to_order, order_validator)

get '/orders/:order_type' do
  "validation succeeded for rule: #{transform(to_order, order_validator).description}"
end
```

* returns rule description `Order validator` in body
* with parameter passing transformation and transformed value satisfying the rule
  * succeeds validation
* with parameter failing the transformation proc
  * fails validation
  * returns 404 Not Found
  * returns `order type "bar" is unsupported!` in body
* with parameter passing transformation but failing the rule (foo)
  * fails validation
  * returns 404 Not Found
  * returns `parameter order_type was expected to satisfy: Order validator but was <>` in body

### for all parameters validation

```ruby
def_all_params_validator :search_criteria do |allowed_keys|
  validate { |params| params.keys.all? { |key| allowed_keys.include?(key.to_sym) } }
  description { "only #{allowed_keys.join(', ')} search criterias allowed" }
end

# :q parameter in the query string identifies that it's a search request but it is not a
# part of search criteria
orders_search_transform = ->(params) do
  fail 'could not extract orders search criteria' if params['fail'] == 'true'
  params.select { |key| key.to_sym != :q }
end

SEARCH_PARAMS = %i(order_type order_date)
all_params_validation transform(orders_search_transform, search_criteria(SEARCH_PARAMS))

get '/orders' do
  rule = transform(orders_search_transform, search_criteria(SEARCH_PARAMS))
  "validation succeeded for rule: #{rule.description}"
end
```

* returns rule description `only order_type, order_date search criterias allowed` in body
* with valid search criteria (`q&order_type=buy_a_pet`)
  * succeeds validation
* with parameters failing transformation
  * fails validation
  * returns 400 Bad Request
  * returns `could not extract orders search criteria` in body
* with parameters passing transformation but failing the rule (`foo`)
  * fails validation
  * returns 400 Bad Request
  * returns `parameters were expected to satisfy: only order_type, order_date search criterias allowed but were <{"foo"=>nil}>` in body



